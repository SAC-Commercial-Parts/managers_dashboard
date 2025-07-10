import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance_data.dart';
import '../models/rep.dart';
import '../models/visit.dart';
import '../services/auth_service.dart';
import '../utils/loading_and_states.dart'; // Ensure you have this service for getting user branch

////////////////////////////////////////////////////////////////////////////
//                           EMPLOYEE VIEW MODEL                          //
////////////////////////////////////////////////////////////////////////////
class VisitViewModel extends ChangeNotifier
{
  final LoadingAndStates _loader = LoadingAndStates();
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Salesman> _reps = [];
  Salesman? _selectedRep;
  List<Visit> _selectedRepVisits = [];
  bool _isLoading = false;
  FilterPeriod _selectedPeriod = FilterPeriod.last30Days; // Default period

  String? _currentBranch;

  VisitViewModel(this._authService) {
    _init();
  }

  List<Salesman> get reps => _reps;
  Salesman? get selectedRep => _selectedRep;
  List<Visit> get selectedRepVisits => _selectedRepVisits;
  bool get isLoading => _isLoading;
  FilterPeriod  get selectedPeriod => FilterPeriod.last30Days;
  String? get currentBranch => _currentBranch;

  ////////////////////////////////////////////////////////////////////////////
  //                             INIT FUNCTION                              //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> _init() async
  {
    await _fetchCurrentBranch();
    if (_currentBranch != null) {
      await fetchReps();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                         FETCH MANAGERS BRANCH                          //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> _fetchCurrentBranch() async
  {
    _currentBranch = await _authService.getUserBranch();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                               FETCH REPS                               //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> fetchReps() async
  {
    if (_currentBranch == null) {
      _loader.showError("Current branch not set. Cannot fetch reps.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('user_details')
          .where('role', isEqualTo: 'rep')
          .where('branch', isEqualTo: _currentBranch)
          .get();
      _reps = querySnapshot.docs.map((doc) => Salesman.fromFirestore(doc)).toList();
      _reps.sort((a, b) => a.name.compareTo(b.name));
      if (_selectedRep == null || !_reps.any((rep) => rep.id == _selectedRep!.id)) {
        if (_reps.isNotEmpty) {
          _selectedRep = _reps.first;
          await fetchVisitsForSelectedRep();
        } else {
          _selectedRep = null;
          _selectedRepVisits = [];
        }
      } else {
        await fetchVisitsForSelectedRep();
      }

    } catch (e) {
      _reps = [];
      _selectedRep = null;
      _selectedRepVisits = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                SELECT REP                              //
  ////////////////////////////////////////////////////////////////////////////
  // TO SHOW REP DATA
  void selectRep(Salesman rep)
  {
    if (_selectedRep?.id != rep.id) {
      _selectedRep = rep;
      fetchVisitsForSelectedRep();
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                            SET FILTER PERIOD                           //
  ////////////////////////////////////////////////////////////////////////////
  void setPeriod(FilterPeriod? newPeriod)
  {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      _selectedPeriod = newPeriod;
      fetchVisitsForSelectedRep();
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                            FETCH REP VISITS                            //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> fetchVisitsForSelectedRep() async
  {
    if (_selectedRep == null) {
      _selectedRepVisits = [];
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
        // Current month's 1st day minus 1 day gives last day of previous month
          startDate = DateTime(endDate.year, endDate.month - 1, 1);
          endDate = DateTime(endDate.year, endDate.month, 0); // Last day of previous month
          break;
        case FilterPeriod.currentYear:
          startDate = DateTime(endDate.year, 1, 1);
          break;
      // Removed 'default' as _selectedPeriod is a FilterPeriod enum, all cases should be handled
      // or you need to ensure a default FilterPeriod is always set.
      // If you are absolutely sure _selectedPeriod will always be one of the defined FilterPeriod values,
      // the `default` case is not strictly necessary for exhaustiveness.
        case FilterPeriod.today:
          startDate = endDate;
          break;
      }

      String startDateString = "${startDate.year}-${_twoDigits(startDate.month)}-${_twoDigits(startDate.day)}";
      String endDateString = "${endDate.year}-${_twoDigits(endDate.month)}-${_twoDigits(endDate.day)}";

      // --- IMPORTANT NEW PRINT STATEMENTS START HERE ---

      Query query = _firestore
          .collection('rep_visits')
          .where('user', isEqualTo: _selectedRep!.id)
          .where('date_visited', isGreaterThanOrEqualTo: startDateString)
          .where('date_visited', isLessThanOrEqualTo: endDateString)
          .orderBy('date_visited', descending: true)
          .orderBy('time_visited', descending: true);

      final querySnapshot = await query.get();


      _selectedRepVisits = querySnapshot.docs.map((doc) {
        try {
          return Visit.fromFirestore(doc);
        } catch (e) {
          _loader.showError("Error parsing Visit document ID: ${doc.id}. Error: $e");
          return null;
        }
      }).where((visit) => visit != null).cast<Visit>().toList(); // Filter out any nulls from parsing errors


    } catch (e) {
      _loader.showError("Error fetching visits: $e");
      _selectedRepVisits = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}