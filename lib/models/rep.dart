import 'package:cloud_firestore/cloud_firestore.dart';

class Rep {
  final String id;
  final String name;
  final String surname;
  final String? repCode;
  final String branch;
  final String? userEmail;
  final int totalCalls;
  final int totalVisits;
  final int totalNewClientRequest;
  final bool isApproved;
  final bool isApprovedRep;
  final double? currentLat;
  final double? currentLong;
  final Timestamp? ts;

  Rep({
    required this.id,
    required this.name,
    required this.surname,
    this.repCode,
    required this.branch,
    this.userEmail,
    required this.totalCalls,
    required this.totalVisits,
    required this.totalNewClientRequest,
    required this.isApproved,
    required this.isApprovedRep,
    this.currentLat,
    this.currentLong,
    this.ts,
  });

  factory Rep.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Rep(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      repCode: data['rep_code'],
      branch: data['branch'] ?? '',
      userEmail: data['user_email'],
      totalCalls: (data['total_calls'] as num?)?.toInt() ?? 0,
      totalVisits: (data['total_visits'] as num?)?.toInt() ?? 0,
      totalNewClientRequest: (data['total_new_client_request'] as num?)?.toInt() ?? 0,
      isApproved: data['isApproved'] ?? false,
      isApprovedRep: data['isApprovedRep'] ?? false,
      currentLat: (data['current_lat'] as num?)?.toDouble(),
      currentLong: (data['current_long'] as num?)?.toDouble(),
      ts: data['ts'] as Timestamp?,
    );
  }
}