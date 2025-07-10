// lib/models/sales_call.dart
import 'package:cloud_firestore/cloud_firestore.dart';
////////////////////////////////////////////////////////////////////////////
//                                CALL MODEL                              //
////////////////////////////////////////////////////////////////////////////
class SalesCall {
  final String id;
  final String user; // Salesman's UID (matches 'id' in user_details)
  final String branch;
  final String clientName;
  final String clientAccountNumber;
  final String callDate;
  final String callWindowOpened;
  final String callWindowClosed;
  final String? spokeTo;
  final String? salesmanFeedback;
  final String? clientFeedback;
  final bool callWasPostponed;
  final bool callWasUnanswered;
  final bool addedPotential;
  final bool addedVehicle;
  final bool addedContact;
  final bool addedBusinessFocus;
  final Timestamp? ts; // Timestamp of call creation

  // Manager-specific fields
  final String? managerSpokeTo;
  final String? managerFeedback;
  final bool? isSalesmanFeedbackCorrect;
  final bool managerCallLogged;
  final bool? managerCallWasUnanswered;
  final Timestamp? lastManagerCallLogTs;
  final String? loggedByManagerId;

  // NEW: Non-final fields to hold salesman name and surname for display/filtering.
  // These are populated by the ViewModel after fetching user_details.
  String? salesmanName;
  String? salesmanSurname;

  SalesCall({
    required this.id,
    required this.user,
    required this.branch,
    required this.clientName,
    required this.clientAccountNumber,
    required this.callDate,
    required this.callWindowOpened,
    required this.callWindowClosed,
    this.spokeTo,
    this.salesmanFeedback,
    this.clientFeedback,
    this.callWasPostponed = false,
    this.callWasUnanswered = false,
    this.addedPotential = false,
    this.addedVehicle = false,
    this.addedContact = false,
    this.addedBusinessFocus = false,
    this.ts,
    this.managerSpokeTo,
    this.managerFeedback,
    this.isSalesmanFeedbackCorrect,
    this.managerCallLogged = false,
    this.managerCallWasUnanswered,
    this.lastManagerCallLogTs,
    this.loggedByManagerId,
    // Initialize new derived fields to null or default
    this.salesmanName, // Will be set later
    this.salesmanSurname, // Will be set later
  });

  factory SalesCall.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool parseBool(dynamic value, {bool defaultValue = false}) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return defaultValue;
    }

    bool? parseNullableBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) {
        if (value.toLowerCase() == 'true') return true;
        if (value.toLowerCase() == 'false') return false;
      }
      return null;
    }

    return SalesCall(
      id: doc.id,
      user: data['user'] ?? '',
      branch: data['branch'] ?? '',
      clientName: data['client_name'] ?? '',
      clientAccountNumber: data['client_account_number'] ?? '',
      callDate: data['call_date'] ?? '',
      callWindowOpened: data['call_window_opened'] ?? '',
      callWindowClosed: data['call_window_closed'] ?? '',
      spokeTo: data['spoke_to'],
      salesmanFeedback: data['salesman_feedback'],
      clientFeedback: data['client_feedback'],
      callWasPostponed: parseBool(data['call_was_postponed']),
      callWasUnanswered: parseBool(data['call_was_unanswered']),
      addedPotential: parseBool(data['added_potential']),
      addedVehicle: parseBool(data['added_vehicle']),
      addedContact: parseBool(data['added_contact']),
      addedBusinessFocus: parseBool(data['added_business_focus']),
      ts: data['ts'] as Timestamp?,
      managerSpokeTo: data['manager_spoke_to'],
      managerFeedback: data['manager_feedback'],
      isSalesmanFeedbackCorrect: parseNullableBool(data['is_salesman_feedback_correct']),
      managerCallLogged: parseBool(data['manager_call_logged']),
      managerCallWasUnanswered: parseNullableBool(data['manager_call_was_unanswered']),
      lastManagerCallLogTs: data['last_manager_call_log_ts'] as Timestamp?,
      loggedByManagerId: data['logged_by_manager_id'],
      // Do NOT set salesmanName/Surname here, they are derived.
    );
  }
}