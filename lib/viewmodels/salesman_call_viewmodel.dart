// lib/viewmodels/salesman_call_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance_data.dart';
import '../models/rep.dart'; // Reusing Rep model for salesmen
import '../models/sales_call.dart';
import '../services/auth_service.dart';
import '../utils/loading_and_states.dart';

////////////////////////////////////////////////////////////////////////////
//                        SALESMAN CALL VIEWMODEL                         //
////////////////////////////////////////////////////////////////////////////
class SalesmanCallViewModel extends ChangeNotifier
{
  final LoadingAndStates _loader = LoadingAndStates();
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Salesman> _salesmen = [];
  Salesman? _selectedSalesman;
  List<SalesCall> _selectedSalesmanCalls = [];
  bool _isLoading = false;
  FilterPeriod _selectedPeriod = FilterPeriod.last30Days; // Default period

  String? _currentBranch;

  ////////////////////////////////////////////////////////////////////////////
  //                               CONSTRUCTOR                              //
  ////////////////////////////////////////////////////////////////////////////
  SalesmanCallViewModel(this._authService)
  {
    _init();
  }

  List<Salesman> get salesmen => _salesmen;
  Salesman? get selectedSalesman => _selectedSalesman;
  List<SalesCall> get selectedSalesmanCalls => _selectedSalesmanCalls;
  bool get isLoading => _isLoading;
  FilterPeriod get selectedPeriod => _selectedPeriod;
  String? get currentBranch => _currentBranch;

  ////////////////////////////////////////////////////////////////////////////
  //                                   INIT                                 //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> _init() async
  {
    await _fetchCurrentBranch();
    if (_currentBranch != null) {
      await fetchSalesmen();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                            FETCH BRANCH DATA                           //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> _fetchCurrentBranch() async
  {
    _currentBranch = await _authService.getUserBranch();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                           FETCH SALESMAN DATA                          //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> fetchSalesmen() async
  {
    if (_currentBranch == null) {
      _loader.showError("Error: Current branch not set. Cannot fetch salesmen.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('user_details')
          .where('role', isEqualTo: 'salesMan') // Filter by 'salesman' role
          .where('branch', isEqualTo: _currentBranch)
          .get();

      _salesmen = querySnapshot.docs.map((doc) => Salesman.fromFirestore(doc)).toList();
      _salesmen.sort((a, b) => a.name.compareTo(b.name));

      if (_selectedSalesman == null || !_salesmen.any((salesman) => salesman.id == _selectedSalesman!.id)) {
        if (_salesmen.isNotEmpty) {
          _selectedSalesman = _salesmen.first;
          await fetchCallsForSelectedSalesman(); // Call the public method
        } else {
          _selectedSalesman = null;
          _selectedSalesmanCalls = [];
        }
      } else {
        await fetchCallsForSelectedSalesman(); // Call the public method
      }

    } catch (e) {
      _salesmen = [];
      _selectedSalesman = null;
      _selectedSalesmanCalls = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                         SHOWING SALESMAN DATA                          //
  ////////////////////////////////////////////////////////////////////////////
  void selectSalesman(Salesman salesman)
  {
    if (_selectedSalesman?.id != salesman.id) {
      _selectedSalesman = salesman;
      fetchCallsForSelectedSalesman(); // Call the public method
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                              FILTER PERIOD                             //
  ////////////////////////////////////////////////////////////////////////////
  void setPeriod(FilterPeriod? newPeriod)
  {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      _selectedPeriod = newPeriod;
      fetchCallsForSelectedSalesman(); // Call the public method
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                       CALLS FOR SELECTED SALESMAN                      //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> fetchCallsForSelectedSalesman() async
  {
    if (_selectedSalesman == null) {
      _selectedSalesmanCalls = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
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
          startDate = DateTime.now();
          break;
      }

      String startDateString = "${startDate.year}-${_twoDigits(startDate.month)}-${_twoDigits(startDate.day)}";
      String endDateString = "${endDate.year}-${_twoDigits(endDate.month)}-${_twoDigits(endDate.day)}";

      Query query = _firestore
          .collection('sales_man_calls')
          .where('user', isEqualTo: _selectedSalesman!.id)
          .where('call_date', isGreaterThanOrEqualTo: startDateString) // <--- IMPORTANT: Changed field name
          .where('call_date', isLessThanOrEqualTo: endDateString)     // <--- IMPORTANT: Changed field name
          .orderBy('call_date', descending: true)
          .orderBy('call_window_closed', descending: true); // Assuming this is the time field

      final querySnapshot = await query.get();

      _selectedSalesmanCalls = querySnapshot.docs.map((doc) {
        try {
          return SalesCall.fromFirestore(doc);
        } catch (e) {
          _loader.showError("Error parsing SalesCall document ID: ${doc.id}. Error: $e");
          return null;
        }
      }).where((call) => call != null).cast<SalesCall>().toList();

    } catch (e) {
      _selectedSalesmanCalls = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}