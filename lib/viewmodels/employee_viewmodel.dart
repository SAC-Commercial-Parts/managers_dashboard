import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/performance_data.dart';
import '../models/rep.dart';
import '../models/visit.dart';
import '../services/auth_service.dart'; // Ensure you have this service for getting user branch

class VisitViewModel extends ChangeNotifier {
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Rep> _reps = [];
  Rep? _selectedRep;
  List<Visit> _selectedRepVisits = [];
  bool _isLoading = false;
  FilterPeriod _selectedPeriod = FilterPeriod.last30Days; // Default period

  String? _currentBranch;

  VisitViewModel(this._authService) {
    _init();
  }

  List<Rep> get reps => _reps;
  Rep? get selectedRep => _selectedRep;
  List<Visit> get selectedRepVisits => _selectedRepVisits;
  bool get isLoading => _isLoading;
  FilterPeriod  get selectedPeriod => FilterPeriod.last30Days;
  String? get currentBranch => _currentBranch;

  Future<void> _init() async {
    print('VisitViewModel: _init started.');
    await _fetchCurrentBranch();
    if (_currentBranch != null) {
      print('VisitViewModel: Current branch set to $_currentBranch. Fetching reps.');
      await fetchReps();
    } else {
      _isLoading = false;
      notifyListeners();
      print("Warning: Could not fetch current user's branch code.");
    }
    print('VisitViewModel: _init finished.');
  }

  Future<void> _fetchCurrentBranch() async {
    print('VisitViewModel: Fetching current branch...');
    _currentBranch = await _authService.getUserBranch();
    print('VisitViewModel: Current branch fetched: $_currentBranch');
  }

  Future<void> fetchReps() async {
    print('VisitViewModel: fetchReps started.');
    if (_currentBranch == null) {
      print("Error: Current branch not set. Cannot fetch reps.");
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
      print('VisitViewModel: Fetched ${querySnapshot.docs.length} raw rep documents.');
      _reps = querySnapshot.docs.map((doc) => Rep.fromFirestore(doc)).toList();
      _reps.sort((a, b) => a.name.compareTo(b.name));
      print('VisitViewModel: Processed ${_reps.length} reps.');
      if (_selectedRep == null || !_reps.any((rep) => rep.id == _selectedRep!.id)) {
        if (_reps.isNotEmpty) {
          _selectedRep = _reps.first;
          print('VisitViewModel: No rep previously selected or current rep not found. Selecting first rep: ${_selectedRep!.name}');
          await fetchVisitsForSelectedRep();
        } else {
          _selectedRep = null;
          _selectedRepVisits = [];
          print('VisitViewModel: No reps found for this branch.');
        }
      } else {
        print('VisitViewModel: Current rep found: ${_selectedRep!.name}. Re-fetching visits.');
        await fetchVisitsForSelectedRep();
      }

    } catch (e) {
      print('Error fetching reps: $e');
      _reps = [];
      _selectedRep = null;
      _selectedRepVisits = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('VisitViewModel: fetchReps finished. Is loading: $_isLoading');
    }
  }

  void selectRep(Rep rep) {
    if (_selectedRep?.id != rep.id) {
      _selectedRep = rep;
      print('Selected Rep: ${rep.name}, ID: ${rep.id}');
      fetchVisitsForSelectedRep();
      notifyListeners();
    }
  }

  void setPeriod(FilterPeriod? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      _selectedPeriod = newPeriod;
      print('Selected Period: ${_selectedPeriod.toDisplayString()}');
      fetchVisitsForSelectedRep();
      notifyListeners();
    }
  }

  Future<void> fetchVisitsForSelectedRep() async {
    if (_selectedRep == null) {
      _selectedRepVisits = [];
      print('No rep selected, visits list cleared.');
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    print('Fetching visits for rep: ${_selectedRep!.name} (ID: ${_selectedRep!.id}) and period: ${_selectedPeriod.toDisplayString()}'); // Updated print for clarity

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
      print('Querying visits from $startDateString to $endDateString for user ID: ${_selectedRep!.id}');

      Query query = _firestore
          .collection('rep_visits')
          .where('user', isEqualTo: _selectedRep!.id)
          .where('date_visited', isGreaterThanOrEqualTo: startDateString)
          .where('date_visited', isLessThanOrEqualTo: endDateString)
          .orderBy('date_visited', descending: true)
          .orderBy('time_visited', descending: true);

      final querySnapshot = await query.get();

      // Debugging the raw documents received
      if (querySnapshot.docs.isEmpty) {
        print('Firestore query returned 0 documents for user ID: ${_selectedRep!.id} and period $startDateString to $endDateString.');
      } else {
        print('Firestore query returned ${querySnapshot.docs.length} documents.');
      }


      _selectedRepVisits = querySnapshot.docs.map((doc) {
        // Debugging each document before parsing
        print('Processing document ID: ${doc.id}, Data: ${doc.data()}');
        try {
          return Visit.fromFirestore(doc);
        } catch (e) {
          print('ERROR: Failed to parse Visit document ID: ${doc.id}. Error: $e');
          // Return null for a problematic document so it can be filtered out
          return null;
        }
      }).where((visit) => visit != null).cast<Visit>().toList(); // Filter out any nulls from parsing errors

      print('Successfully parsed ${_selectedRepVisits.length} visits into the list.');

    } catch (e) {
      print('GLOBAL ERROR: Error during visit fetch operation: $e'); // More descriptive error for catch block
      _selectedRepVisits = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Finished _fetchVisitsForSelectedRep. Is loading: $_isLoading. Total visits in list: ${_selectedRepVisits.length}');
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}