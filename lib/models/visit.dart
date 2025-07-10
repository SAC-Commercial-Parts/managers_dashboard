// lib/models/visit.dart
import 'package:cloud_firestore/cloud_firestore.dart';

////////////////////////////////////////////////////////////////////////////
//                              STATUS MODEL                              //
////////////////////////////////////////////////////////////////////////////
class StatusItem {
  final String name;
  final bool status;

  StatusItem({required this.name, required this.status});

  factory StatusItem.fromMap(Map<String, dynamic> data) {
    // Correctly parse the 'status' field from String to bool
    final dynamic statusValue = data['status'];
    bool parsedStatus = false; // Default value

    if (statusValue is bool) {
      parsedStatus = statusValue;
    } else if (statusValue is String) {
      parsedStatus = statusValue.toLowerCase() == 'true'; // Convert "true" to true, "false" to false
    }
    // Handle other types or null with the default `false`

    return StatusItem(
      name: data['name'] ?? '',
      status: parsedStatus, // <--- Use the parsed boolean value here
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
    };
  }
}

////////////////////////////////////////////////////////////////////////////
//                                VISIT MODEL                             //
////////////////////////////////////////////////////////////////////////////
class Visit {
  final String id;
  final String clientName;
  final String clientAccountNumber;
  final String spokeTo;
  final String atPremises;
  final String dateVisited; // YYYY-MM-DD
  final String timeVisited; // HH:mm:ss
  final int happy;
  final int happyWithService;
  final int happyWithStaff;
  final int receivedParts;
  final String? feedbackOnPremises;
  final String? clientFeedback;
  final String? repComment;
  final List<StatusItem> completed;
  final double? visitLat;
  final double? visitLong;
  final String user; // Rep ID
  final String branch;
  final Timestamp? ts; // Timestamp of visit creation/update

  // Existing fields for Manager Call Log
  final String? managerFeedback;
  final bool? isClientFeedbackCorrect;
  final bool managerCallLogged;

  // NEW FIELD for Manager Call Log
  final String? managerSpokeTo; // Who the manager spoke to
  final bool? callWasUnanswered; // New boolean for unanswered calls
  final bool? managerCallWasUnanswered;


  Visit({
    required this.id,
    required this.clientName,
    required this.clientAccountNumber,
    required this.spokeTo,
    required this.atPremises,
    required this.dateVisited,
    required this.timeVisited,
    required this.happy,
    required this.happyWithService,
    required this.happyWithStaff,
    required this.receivedParts,
    this.feedbackOnPremises,
    this.clientFeedback,
    this.repComment,
    required this.completed,
    this.visitLat,
    this.visitLong,
    required this.user,
    required this.branch,
    this.ts,
    this.managerFeedback,
    this.isClientFeedbackCorrect,
    this.managerCallLogged = false,
    // Initialize new fields
    this.managerSpokeTo,
    this.callWasUnanswered,
    required this.managerCallWasUnanswered,
  });

  factory Visit.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    double? parseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    return Visit(
      id: doc.id,
      clientName: data['client_name'] ?? '',
      clientAccountNumber: data['client_account_number'] ?? '',
      spokeTo: data['spoke_to'] ?? '',
      atPremises: data['at_premises'] ?? '',
      dateVisited: data['date_visited'] ?? '',
      timeVisited: data['time_visited'] ?? '',
      happy: (data['happy'] as num?)?.toInt() ?? 0,
      happyWithService: (data['happyWithService'] as num?)?.toInt() ?? 0,
      happyWithStaff: (data['happyWithStaff'] as num?)?.toInt() ?? 0,
      receivedParts: (data['receivedParts'] as num?)?.toInt() ?? 0,
      feedbackOnPremises: data['feedback_on_premises'],
      clientFeedback: data['client_feedback'],
      repComment: data['rep_comment'],
      completed: (data['completed'] as List<dynamic>?)
          ?.map((item) => StatusItem.fromMap(item as Map<String, dynamic>))
          .toList() ??
          [],
      visitLat: parseDouble(data['visit_lat']),
      visitLong: parseDouble(data['visit_long']),
      user: data['user'] ?? '',
      branch: data['branch'] ?? '',
      ts: data['ts'] as Timestamp?,
      managerFeedback: data['manager_feedback'],
      isClientFeedbackCorrect: data['is_client_feedback_correct'] as bool?,
      managerCallLogged: data['manager_call_logged'] ?? false,
      // NEW FIELD from Firestore
      managerSpokeTo: data['manager_spoke_to'],
      callWasUnanswered: data['call_was_unanswered'] as bool?,
      managerCallWasUnanswered: data['manager_call_was_unanswered'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'client_name': clientName,
      'client_account_number': clientAccountNumber,
      'spoke_to': spokeTo,
      'at_premises': atPremises,
      'date_visited': dateVisited,
      'time_visited': timeVisited,
      'happy': happy,
      'happyWithService': happyWithService,
      'happyWithStaff': happyWithStaff,
      'receivedParts': receivedParts,
      'feedback_on_premises': feedbackOnPremises,
      'client_feedback': clientFeedback,
      'rep_comment': repComment,
      'completed': completed.map((item) => item.toMap()).toList(),
      'visit_lat': visitLat,
      'visit_long': visitLong,
      'user': user,
      'branch': branch,
      'ts': ts ?? Timestamp.now(),
      'manager_feedback': managerFeedback,
      'is_client_feedback_correct': isClientFeedbackCorrect,
      'manager_call_logged': managerCallLogged,
      // NEW FIELDS for writing to Firestore
      'manager_spoke_to': managerSpokeTo,
      'call_was_unanswered': callWasUnanswered,
    };
  }
}