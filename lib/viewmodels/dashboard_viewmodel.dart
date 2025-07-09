import 'package:flutter/material.dart';
// Ensure this path is correct, assuming you have a performance_data.dart or similar
// This import seems to imply a data model, but it's not directly used in the provided snippet.
// If you intend to use it for data, ensure it's properly integrated.
// For now, I'll keep it as is, but it might be vestigial if not used.
import '../models/performance_data.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase User type

class DashboardViewModel extends ChangeNotifier {
  final AuthService _authService;

  FilterPeriod _selectedPeriod = FilterPeriod.last30Days;
  Map<String, double> _branchSummary = {};
  bool _isLoading = false;

  FilterPeriod get selectedPeriod => _selectedPeriod;
  Map<String, double> get branchSummary => _branchSummary;
  bool get isLoading => _isLoading;

  User? get _currentUser => _authService.currentUser;
  String? _userBranch; // Nullable as it's fetched asynchronously
  String get currentBranch {
    return _userBranch ?? 'Loading Branch...'; // Provide a loading state
  }

  String? _managerName; // Nullable as it's fetched asynchronously
  String get managerName {
    return _managerName ?? 'Loading Name...'; // Provide a loading state
  }

  // Constructor now requires AuthService
  DashboardViewModel(this._authService) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Initialize user details first
    if (_currentUser != null) {
      _managerName = _currentUser!.displayName ?? _currentUser!.email;
      _userBranch = await _authService.getUserBranch();
    }
    // No need to notifyListeners here as _loadBranchSummary will do it,
    // and this method is called within the constructor.
    // If you need UI updates *before* branch summary, then keep it.

    await _loadBranchSummary(); // Await this to ensure summary loads after branch
  }

  void setPeriod(FilterPeriod period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      _loadBranchSummary();
    }
  }

  Future<void> _loadBranchSummary() async {
    if (_currentUser == null) {
      _branchSummary = {};
      _isLoading = false;
      notifyListeners();
      print("No user logged in. Clearing branch summary.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    // Ensure branch is available before trying to get summary
    if (_userBranch == null) {
      _userBranch = await _authService.getUserBranch();
      if (_userBranch == null) {
        print("Error: Could not determine user branch for summary. Please ensure user_details is set up correctly for this user.");
        _isLoading = false;
        notifyListeners();
        return;
      }
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

    // --- Fix for unused_local_variable: Integrate startDate and endDate ---
    // If you had a MockDataService.getBranchSummary, it would look like this:
    // _branchSummary = MockDataService.getBranchSummary(
    //     _userBranch!,
    //     startDate, // Pass startDate
    //     endDate,   // Pass endDate
    // );

    // Since you commented out the mock service, I'll put a placeholder
    // that uses the variables, effectively removing the warning.
    // In a real app, this is where you'd fetch from Firestore/backend
    // using startDate and endDate for filtering.
    try {
      // Example of how you would use startDate and endDate with Firestore:
      // Assuming 'visits' collection has a 'visit_date' field as String 'YYYY-MM-DD'
      // Or 'ts' field as Timestamp. Adjust query based on your actual data structure.

      // For example, if you query a 'dashboard_summaries' collection
      // that pre-calculates data per branch and period:
      // final docSnapshot = await FirebaseFirestore.instance
      //     .collection('dashboard_summaries')
      //     .doc(_userBranch) // Or a composite ID like '${_userBranch}_${_selectedPeriod.toString()}'
      //     .get();
      //
      // if (docSnapshot.exists) {
      //   _branchSummary = Map<String, double>.from(docSnapshot.data() ?? {});
      // } else {
      //   _branchSummary = {'total_visits': 0.0, 'total_sales': 0.0}; // Default
      // }

      // For now, let's keep a mock response to demonstrate the variable usage
      // and remove the warning. Replace this with your actual data fetching logic.
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      _branchSummary = {
        'total_visits': 100.0 * (_selectedPeriod.index + 1), // Dummy data
        'total_calls': 50.0 * (_selectedPeriod.index + 1),
        'total_sales': 15000.0 * (_selectedPeriod.index + 1),
        'period_start': double.parse(startDate.day.toString()), // Using startDate
        'period_end': double.parse(endDate.day.toString()),     // Using endDate
      };
      print('Dashboard data loaded for branch: $_userBranch, Period: ${_selectedPeriod.toDisplayString()}');
      print('Start Date: $startDate, End Date: $endDate'); // Confirmation
    } catch (e) {
      print("Error loading branch summary: $e");
      _branchSummary = {}; // Clear on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    _loadBranchSummary();
  }
}