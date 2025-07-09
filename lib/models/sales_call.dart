// lib/models/sales_call.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesCall {
  final String id; // This is the call_id from Firestore
  final String user; // Salesman's UID
  final String branch;
  final String callDate; // YYYY-MM-DD
  final String callWindowOpened; // HH:mm:ss
  final String callWindowClosed; // HH:mm:ss
  final String clientAccountNumber;
  final String clientName;
  final String spokeTo;
  final String? clientFeedback;
  final String? salesmanFeedback;
  final bool callWasPostponed;
  final bool callWasUnanswered;
  final bool addedBusinessFocus;
  final bool addedContact;
  final bool addedPotential;
  final bool addedVehicle;
  final Timestamp? ts; // Timestamp of call creation/update

  // New fields for Manager Call Log on Sales Calls (will be updated on the sales_man_calls document)
  final String? managerSpokeTo;
  final String? managerFeedback;
  final bool? isSalesmanFeedbackCorrect;
  final bool managerCallLogged; // Flag if manager has logged a call for this sales call
  final bool? managerCallWasUnanswered; // Flag if manager's call was unanswered

  SalesCall({
    required this.id,
    required this.user,
    required this.branch,
    required this.callDate,
    required this.callWindowOpened,
    required this.callWindowClosed,
    required this.clientAccountNumber,
    required this.clientName,
    required this.spokeTo,
    this.clientFeedback,
    this.salesmanFeedback,
    required this.callWasPostponed,
    required this.callWasUnanswered,
    required this.addedBusinessFocus,
    required this.addedContact,
    required this.addedPotential,
    required this.addedVehicle,
    this.ts,
    // Manager Call Log fields
    this.managerSpokeTo,
    this.managerFeedback,
    this.isSalesmanFeedbackCorrect,
    this.managerCallLogged = false,
    this.managerCallWasUnanswered,
  });

  factory SalesCall.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    // Helper to safely parse booleans from various types (bool, string)
    bool parseBool(dynamic value) {
      if (value is bool) {
        return value;
      } else if (value is String) {
        return value.toLowerCase() == 'true';
      }
      return false; // Default to false if not a valid boolean or string
    }

    return SalesCall(
      id: doc.id, // Use document ID for the sales call itself
      user: data['user'] ?? '',
      branch: data['branch'] ?? '',
      callDate: data['call_date'] ?? '',
      callWindowOpened: data['call_window_opened'] ?? '',
      callWindowClosed: data['call_window_closed'] ?? '',
      clientAccountNumber: data['client_account_number'] ?? '',
      clientName: data['client_name'] ?? '',
      spokeTo: data['spoke_to'] ?? '',
      clientFeedback: data['client_feedback'],
      salesmanFeedback: data['salesman_feedback'],
      callWasPostponed: parseBool(data['call_was_postponed']),
      callWasUnanswered: parseBool(data['call_was_unanswered']),
      addedBusinessFocus: parseBool(data['added_business_focus']),
      addedContact: parseBool(data['added_contact']),
      addedPotential: parseBool(data['added_potential']),
      addedVehicle: parseBool(data['added_vehicle']),
      ts: data['ts'] as Timestamp?,

      // Manager Call Log fields
      managerSpokeTo: data['manager_spoke_to'],
      managerFeedback: data['manager_feedback'],
      isSalesmanFeedbackCorrect: data['is_salesman_feedback_correct'] as bool?,
      managerCallLogged: data['manager_call_logged'] ?? false,
      managerCallWasUnanswered: data['manager_call_was_unanswered'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'branch': branch,
      'call_date': callDate,
      'call_window_opened': callWindowOpened,
      'call_window_closed': callWindowClosed,
      'client_account_number': clientAccountNumber,
      'client_name': clientName,
      'spoke_to': spokeTo,
      'client_feedback': clientFeedback,
      'salesman_feedback': salesmanFeedback,
      'call_was_postponed': callWasPostponed,
      'call_was_unanswered': callWasUnanswered,
      'added_business_focus': addedBusinessFocus,
      'added_contact': addedContact,
      'added_potential': addedPotential,
      'added_vehicle': addedVehicle,
      'ts': ts ?? FieldValue.serverTimestamp(), // Use existing or new timestamp

      // Manager Call Log fields
      'manager_spoke_to': managerSpokeTo,
      'manager_feedback': managerFeedback,
      'is_salesman_feedback_correct': isSalesmanFeedbackCorrect,
      'manager_call_logged': managerCallLogged,
      'manager_call_was_unanswered': managerCallWasUnanswered,
    };
  }
}