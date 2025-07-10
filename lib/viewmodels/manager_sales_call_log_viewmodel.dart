// lib/viewmodels/manager_sales_call_log_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sales_call.dart';
import '../services/auth_service.dart';
import '../utils/loading_and_states.dart';

class ManagerSalesCallLogViewModel extends ChangeNotifier
{
  final LoadingAndStates _loader = LoadingAndStates();
  final SalesCall _originalSalesCall;
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController managerFeedbackController = TextEditingController();
  TextEditingController spokeToController = TextEditingController();
  bool? _isSalesmanFeedbackCorrect;
  bool _callWasUnanswered = false;
  bool _isLoading = false;

  ////////////////////////////////////////////////////////////////////////////
  //                              CONSTRUCTOR                               //
  ////////////////////////////////////////////////////////////////////////////
  ManagerSalesCallLogViewModel(this._originalSalesCall, this._authService)
  {
    managerFeedbackController.text = _originalSalesCall.managerFeedback ?? '';
    spokeToController.text = _originalSalesCall.managerSpokeTo ?? '';
    _isSalesmanFeedbackCorrect = _originalSalesCall.isSalesmanFeedbackCorrect;
    _callWasUnanswered = _originalSalesCall.managerCallWasUnanswered ?? false;
  }

  SalesCall get originalSalesCall => _originalSalesCall;
  bool? get isSalesmanFeedbackCorrect => _isSalesmanFeedbackCorrect;
  bool get callWasUnanswered => _callWasUnanswered;
  bool get isLoading => _isLoading;

  ////////////////////////////////////////////////////////////////////////////
  //                           UPDATE TEXT FIELDS                           //
  ////////////////////////////////////////////////////////////////////////////
  void updateSpokeTo(String text)
  {
    spokeToController.text = text; // Update the controller's text
    notifyListeners(); // Notify listeners to update the button state
  }
  void updateManagerFeedback(String text)
  {
    managerFeedbackController.text = text; // Update the controller's text
    notifyListeners(); // Notify listeners to update the button state
  }

  ////////////////////////////////////////////////////////////////////////////
  //                      SALESMAN FEEDBACK VALIDATION                      //
  ////////////////////////////////////////////////////////////////////////////
  void setIsSalesmanFeedbackCorrect(bool? value)
  {
    _isSalesmanFeedbackCorrect = value;
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             CALL UNANSWERED                            //
  ////////////////////////////////////////////////////////////////////////////
  void setCallWasUnanswered(bool? value)
  {
    _callWasUnanswered = value ?? false;
    if (_callWasUnanswered) {
      spokeToController.clear();
      managerFeedbackController.clear();
      _isSalesmanFeedbackCorrect = null; // Reset feedback correctness
    }
    notifyListeners();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                  GETTERS                               //
  ////////////////////////////////////////////////////////////////////////////
  bool get canLogCall
  {
    return !_callWasUnanswered &&
        spokeToController.text.trim().isNotEmpty &&
        (managerFeedbackController.text.trim().isNotEmpty || _isSalesmanFeedbackCorrect != null);
  }
  bool get canLogUnansweredCall
  {
    return _callWasUnanswered;
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

      final Map<String, dynamic> updatedSalesCallData =
      {
        'manager_spoke_to': isUnanswered ? null : spokeToController.text.trim(),
        'manager_feedback': isUnanswered ? null : managerFeedbackController.text.trim(),
        'is_salesman_feedback_correct': isUnanswered ? null : _isSalesmanFeedbackCorrect,
        'manager_call_logged': !isUnanswered,
        'manager_call_was_unanswered': isUnanswered,
        'last_manager_call_log_ts': FieldValue.serverTimestamp(),
        'logged_by_manager_id': managerId,
      };

      await _firestore.collection('sales_man_calls').doc(_originalSalesCall.id).update(updatedSalesCallData);

      // Add a new document to 'managers_sales_call_logs' collection for auditing
      final Map<String, dynamic> callLogData = {
        'source_document_id': _originalSalesCall.id,
        'source_collection': 'sales_man_calls', // Indicate source collection
        'manager_id': managerId,
        'manager_spoke_to': isUnanswered ? null : spokeToController.text.trim(),
        'manager_feedback': isUnanswered ? null : managerFeedbackController.text.trim(),
        'is_salesman_feedback_correct': isUnanswered ? null : _isSalesmanFeedbackCorrect,
        'call_was_unanswered': isUnanswered, // This refers to the manager's call
        'call_timestamp': FieldValue.serverTimestamp(),
        // Duplicate relevant sales call details for logging
        'salesman_id': _originalSalesCall.user,
        'branch': _originalSalesCall.branch,
        'client_name': _originalSalesCall.clientName,
        'client_account_number': _originalSalesCall.clientAccountNumber,
        'salesman_feedback': _originalSalesCall.salesmanFeedback,
        'salesman_spoke_to': _originalSalesCall.spokeTo,
        'call_date': _originalSalesCall.callDate,
        'call_window_opened': _originalSalesCall.callWindowOpened,
        'call_window_closed': _originalSalesCall.callWindowClosed,
        'salesman_call_was_unanswered': _originalSalesCall.callWasUnanswered,
        'salesman_call_was_postponed': _originalSalesCall.callWasPostponed,
      };

      await _firestore.collection('managers_sales_call_logs').add(callLogData);

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