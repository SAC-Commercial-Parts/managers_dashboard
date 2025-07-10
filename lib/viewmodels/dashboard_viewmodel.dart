// lib/viewmodels/dashboard_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type

import '../models/performance_data.dart'; // Assuming FilterPeriod is here
import '../models/sales_call.dart';     // Import your SalesCall model
import '../models/rep.dart';           // Import your Salesman/Rep model
import '../services/auth_service.dart';
import '../utils/loading_and_states.dart';

////////////////////////////////////////////////////////////////////////////
//                          DASHBOARD VIEW MODEL                          //
////////////////////////////////////////////////////////////////////////////
class DashboardViewModel extends ChangeNotifier
{
  final LoadingAndStates _loader = LoadingAndStates();
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add Firestore instance

  FilterPeriod _selectedPeriod = FilterPeriod.last30Days;
  Map<String, double> _branchSummary = {};
  bool _isLoading = false;

  User? get _currentUser => _authService.currentUser;
  String? _userBranch;
  String get currentBranch {
    return _userBranch ?? 'Loading Branch...';
  }

  String? _managerName;
  String get managerName {
    return _managerName ?? 'Loading Name...';
  }

  // --- Search related properties ---
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController(); // Initialize controller
  List<SalesCall> _allSalesCalls = []; // Stores all sales calls for the branch
  List<Salesman> _allSalesmen = []; // Stores all salesmen for the branch
  // --- End Search related properties ---


  FilterPeriod get selectedPeriod => _selectedPeriod;
  Map<String, double> get branchSummary => _branchSummary;
  bool get isLoading => _isLoading;

  // --- Search related getters ---
  TextEditingController get searchController => _searchController;
  String get searchQuery => _searchQuery;

  // Returns the filtered list of sales calls
  List<SalesCall> get salesCalls => _getFilteredSalesCalls();
  // Returns all salesmen (you might add filtering for salesmen later if needed)
  List<Salesman> get salesmen => _allSalesmen;


  ////////////////////////////////////////////////////////////////////////////
  //                               CONSTRUCTOR                              //
  ////////////////////////////////////////////////////////////////////////////
  DashboardViewModel(this._authService)
  {
    _loadInitialData();
    // Listen to changes in the search controller
    _searchController.addListener(_onSearchChanged);
  }

  ////////////////////////////////////////////////////////////////////////////
  //                              SEARCH METHODS                            //
  ////////////////////////////////////////////////////////////////////////////
  void _onSearchChanged()
  {
    _searchQuery = _searchController.text;
    notifyListeners(); // Re-filter and update UI when search query changes
  }
  // Method to manually set search query if needed (e.g., from an external button)
  void setSearchQuery(String query)
  {
    _searchQuery = query;
    _searchController.text = query; // Keep controller in sync
    notifyListeners();
  }
  // The actual filtering logic for sales calls
  List<SalesCall> _getFilteredSalesCalls()
  {
    if (_searchQuery.isEmpty) {
      return _allSalesCalls; // Return all calls if no search query
    }

    final query = _searchQuery.toLowerCase();
    return _allSalesCalls.where((call) {
      // Check client name, account number, and salesman name
      final clientName = call.clientName.toLowerCase();
      final accountNumber = call.clientAccountNumber.toLowerCase();

      // Combine salesman name and surname for searching
      final salesmanFullName = '${call.salesmanName ?? ''} ${call.salesmanSurname ?? ''}'.toLowerCase();

      return clientName.contains(query) ||
          accountNumber.contains(query) ||
          salesmanFullName.contains(query);
    }).toList();
  }
  // --- End of Search methods ---


  ////////////////////////////////////////////////////////////////////////////
  //                              INITIAL DATA                              //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> _loadInitialData() async
  {
    _isLoading = true; // Set loading true at the very beginning
    notifyListeners(); // Notify listeners to show loading state

    try {
      if (_currentUser != null) {
        _managerName = _currentUser!.displayName ?? _currentUser!.email;
        _userBranch = await _authService.getUserBranch();
      } else {
        // If no user, reset relevant states and return
        _managerName = null;
        _userBranch = null;
        _allSalesCalls = [];
        _allSalesmen = [];
        _branchSummary = {};
        _isLoading = false;
        notifyListeners();
        return;
      }

      // If branch still null after trying to fetch
      if (_userBranch == null) {
        _loader.showError("Branch information not found for the current user.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load sales calls and salesmen (needed for search and display)
      await _fetchSalesCallsAndSalesmen();

      // Load branch summary (this will also call notifyListeners)
      await _loadBranchSummary();

    } catch (e) {
      _loader.showError("Error loading initial data: $e");
      _isLoading = false;
      notifyListeners();
    }
  }


  ////////////////////////////////////////////////////////////////////////////
  //                           FETCH SALES CALLS                            //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> _fetchSalesCallsAndSalesmen() async
  {
    if (_userBranch == null) return; // Cannot fetch without a branch

    try {
      // Fetch sales calls for the current branch
      final callsSnapshot = await _firestore
          .collection('sales_man_calls')
          .where('branch', isEqualTo: _userBranch)
          .orderBy('call_date', descending: true) // Example: order by date
          .get();

      _allSalesCalls = callsSnapshot.docs.map((doc) => SalesCall.fromFirestore(doc)).toList();

      // Fetch salesmen for the current branch
      final salesmenSnapshot = await _firestore
          .collection('user_details')
          .where('branch_name', isEqualTo: _userBranch)
          .where('role', isEqualTo: 'salesMan') // Only fetch salesmen
          .get();

      _allSalesmen = salesmenSnapshot.docs.map((doc) => Salesman.fromFirestore(doc)).toList();

      // Notify listeners here if you want UI to update as soon as calls/salesmen are loaded,
      // even before the summary.
      // notifyListeners(); // Or wait for _loadBranchSummary to do it.

    } catch (e) {
      _loader.showError("Error fetching sales calls and salesmen: $e");
      _allSalesCalls = []; // Clear on error
      _allSalesmen = [];
    }
  }


  ////////////////////////////////////////////////////////////////////////////
  //                               SEARCH PERIOD                            //
  ////////////////////////////////////////////////////////////////////////////
  void setPeriod(FilterPeriod period)
  {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      _loadBranchSummary(); // This will trigger notifyListeners
    }
  }


  ////////////////////////////////////////////////////////////////////////////
  //                               BRANCH SUMMARY                           //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> _loadBranchSummary() async
  {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }


    if (_userBranch == null) {
      _branchSummary = {};
      _isLoading = false;
      notifyListeners();
      return;
    }

    DateTime endDate = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case FilterPeriod.last7Days:
        startDate = endDate.subtract(const Duration(days: 7));
        break;
      case FilterPeriod.last30Days:
        startDate = endDate.subtract(const Duration(days: 30));
        break;
      case FilterPeriod.currentMonth:
        startDate = DateTime(endDate.year, endDate.month, 1);
        break;
      case FilterPeriod.lastMonth:
        startDate = DateTime(endDate.year, endDate.month - 1, 1);
        endDate = DateTime(endDate.year, endDate.month, 0);
        break;
      case FilterPeriod.currentYear:
        startDate = DateTime(endDate.year, 1, 1);
        break;
      case FilterPeriod.today:
        startDate = DateTime(endDate.year, endDate.month, endDate.day); // Start of today
        endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59); // End of today
        break;
    }

    try {
      // --- IMPORTANT: Replace this mock data fetching with your actual Firestore queries ---
      // This part needs to be implemented to fetch real data based on _userBranch, startDate, and endDate.
      // Example for fetching counts from 'sales_man_calls':
      // You'll need to count documents within the date range and for the specific branch.
      // This often involves aggregation queries or fetching all relevant docs and counting client-side.

      // For total calls:
      final salesCallsCountSnapshot = await _firestore
          .collection('sales_man_calls')
          .where('branch', isEqualTo: _userBranch)
          .where('ts', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('ts', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
      final totalCalls = salesCallsCountSnapshot.docs.length;

      // You would do similar queries for 'total_visits', 'total_sales', etc.,
      // based on how your data is structured. If 'total_sales' is not a direct field
      // in 'sales_man_calls', you'd need another collection or different logic.

      // For demonstration, still using dummy data with the totalCalls
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      _branchSummary = {
        'total_visits': totalCalls.toDouble(), // Example: using totalCalls as visits
        'total_calls': totalCalls.toDouble(),
        'total_sales': 15000.0 * (totalCalls > 0 ? (totalCalls / 50) : 1), // Dummy sales based on calls
        'period_start': double.parse(startDate.day.toString()),
        'period_end': double.parse(endDate.day.toString()),
      };
    } catch (e) {
      _loader.showError("Error loading branch summary: $e");
      _branchSummary = {}; // Clear on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                              REFRESH DATA                              //
  ////////////////////////////////////////////////////////////////////////////
  void refresh()
  {
    _loadInitialData(); // This will re-fetch everything including branch summary
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                  DISPOSE                               //
  ////////////////////////////////////////////////////////////////////////////
  @override
  void dispose()
  {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}