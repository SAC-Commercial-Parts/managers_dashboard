// lib/viewmodels/manager_call_log_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visit.dart';
import '../services/auth_service.dart';
import '../models/sales_call.dart';
import '../utils/loading_and_states.dart'; // Import SalesCall for history check

class ManagerCallLogViewModel extends ChangeNotifier {
  final LoadingAndStates _loader = LoadingAndStates();
  final Visit _originalVisit;
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController managerFeedbackController = TextEditingController();
  TextEditingController spokeToController = TextEditingController();
  bool? _isClientFeedbackCorrect;
  bool _callWasUnanswered = false; // For manager's call
  bool _isLoading = false;

  // New properties for salesman call history check
  bool _salesmanCallHistoryExists = false;
  String? _salesmanNameFromCallHistory;

  ManagerCallLogViewModel(this._originalVisit, this._authService) {
    // Initialize from visit data if it's already been logged by manager
    managerFeedbackController.text = _originalVisit.managerFeedback ?? '';
    spokeToController.text = _originalVisit.managerSpokeTo ?? '';
    _isClientFeedbackCorrect = _originalVisit.isClientFeedbackCorrect;
    _callWasUnanswered = _originalVisit.managerCallWasUnanswered ?? false;

    // Load initial salesman call history
    _checkSalesmanCallHistory();
  }

  Visit get originalVisit => _originalVisit;
  bool? get isClientFeedbackCorrect => _isClientFeedbackCorrect;
  bool get callWasUnanswered => _callWasUnanswered;
  bool get isLoading => _isLoading;
  bool get salesmanCallHistoryExists => _salesmanCallHistoryExists;
  String? get salesmanNameFromCallHistory => _salesmanNameFromCallHistory;

  ////////////////////////////////////////////////////////////////////////////
  //                              SPOKE TO ...                              //
  ////////////////////////////////////////////////////////////////////////////
  void updateSpokeTo(String text)
  {
    spokeToController.text = text;
  }

  ////////////////////////////////////////////////////////////////////////////
  //                          MANAGERS FEEDBACK                             //
  ////////////////////////////////////////////////////////////////////////////
  void updateManagerFeedback(String text)
  {
    managerFeedbackController.text = text;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                    FEEDBACK VALIDATION BY MANAGER                      //
  ////////////////////////////////////////////////////////////////////////////
  void setIsClientFeedbackCorrect(bool? value)
  {
    _isClientFeedbackCorrect = value;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                            CALL UNANSWERED                             //
  ////////////////////////////////////////////////////////////////////////////
  void setCallWasUnanswered(bool? value)
  {
    _callWasUnanswered = value ?? false;
    if (_callWasUnanswered) {
      spokeToController.clear();
      managerFeedbackController.clear();
      _isClientFeedbackCorrect = null; // Reset feedback correctness
    }
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                 GETTERS                                //
  ////////////////////////////////////////////////////////////////////////////
  bool get canLogCall
  {
    return !_callWasUnanswered &&
        spokeToController.text.trim().isNotEmpty &&
        (managerFeedbackController.text.trim().isNotEmpty || _isClientFeedbackCorrect != null);
  }
  bool get canLogUnansweredCall
  {
    return _callWasUnanswered;
  }

  ////////////////////////////////////////////////////////////////////////////
  //                SALESMAN CALL HISTORY FOR SELECTED CLIENT               //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> _checkSalesmanCallHistory() async
  {
    try {
      final querySnapshot = await _firestore
          .collection('sales_man_calls')
          .where('client_account_number', isEqualTo: _originalVisit.clientAccountNumber)
          .orderBy('call_date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _salesmanCallHistoryExists = true;
        final latestCall = SalesCall.fromFirestore(querySnapshot.docs.first);

// Fetch salesman name from user_details by querying the 'id' field
        final userDetailsQuerySnapshot = await _firestore
            .collection('user_details')
            .where('id', isEqualTo: latestCall.user) // <--- CRITICAL CHANGE: Query by the 'id' field
            .limit(1) // Limit to 1 result, as IDs should be unique
            .get();

        if (userDetailsQuerySnapshot.docs.isNotEmpty) {
          // If a document matching the 'id' field is found
          final salesmanDetailsData = userDetailsQuerySnapshot.docs.first.data();
          _salesmanNameFromCallHistory = (salesmanDetailsData['name'] ?? 'Unknown')  (salesmanDetailsData['surname'] ?? '');
        } else {
          _salesmanNameFromCallHistory = 'Unknown Salesman (ID: ${latestCall.user})'; // Changed to ID as email is not found here
        }
      } else {
        _salesmanCallHistoryExists = false;
        _salesmanNameFromCallHistory = null;
      }
    } catch (e) {
      _salesmanCallHistoryExists = false;
      _salesmanNameFromCallHistory = null;
    } finally {
      notifyListeners(); // Notify after history check is complete
    }
  }


  ////////////////////////////////////////////////////////////////////////////
  //                             SAVE CALL LOG                              //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> saveCallLog({bool isUnanswered = false}) async
  {
    _isLoading = true;
    notifyListeners();

    try {
      final String? managerId = await _authService.getCurrentUserId();
      if (managerId == null) {
        throw Exception("Manager ID not found. Cannot log call.");
      }

      // 1. Update the original 'rep_visits' document
      // This ensures the visit itself reflects the manager's action
      final Map<String, dynamic> updatedVisitData = {
        'manager_spoke_to': isUnanswered ? null : spokeToController.text.trim(),
        'manager_feedback': isUnanswered ? null : managerFeedbackController.text.trim(),
        'is_client_feedback_correct': isUnanswered ? null : _isClientFeedbackCorrect,
        'manager_call_logged': !isUnanswered, // True if answered, false if unanswered
        'manager_call_was_unanswered': isUnanswered, // Set based on button pressed
        'last_manager_call_log_ts': FieldValue.serverTimestamp(),
        'logged_by_manager_id': managerId,
      };

      await _firestore.collection('rep_visits').doc(_originalVisit.id).update(updatedVisitData);

      // 2. Add a new document to 'managers_call_logs' collection
      final Map<String, dynamic> callLogData = {
        'source_document_id': _originalVisit.id,
        'source_collection': 'rep_visits', // Indicate source collection
        'manager_id': managerId,
        'manager_spoke_to': isUnanswered ? null : spokeToController.text.trim(),
        'manager_feedback': isUnanswered ? null : managerFeedbackController.text.trim(),
        'is_client_feedback_correct': isUnanswered ? null : _isClientFeedbackCorrect,
        'call_was_unanswered': isUnanswered, // This refers to the manager's call
        'call_timestamp': FieldValue.serverTimestamp(),
        // Duplicate relevant visit details for logging
        'rep_id': _originalVisit.user,
        'branch': _originalVisit.branch,
        'client_name': _originalVisit.clientName,
        'client_account_number': _originalVisit.clientAccountNumber,
        'rep_client_feedback': _originalVisit.clientFeedback, // Original rep's client feedback
        'rep_comment': _originalVisit.repComment, // Original rep's comment
        'date_visited': _originalVisit.dateVisited,
        'time_visited': _originalVisit.timeVisited,
      };

      await _firestore.collection('managers_call_logs').add(callLogData);

    } catch (e) {
      _loader.showError("Error saving call log: $e");
      rethrow; // Re-throw to be caught by the UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                 DISPOSE                                //
  ////////////////////////////////////////////////////////////////////////////
  @override
  void dispose()
  {
    managerFeedbackController.dispose();
    spokeToController.dispose();
    super.dispose();
  }
}