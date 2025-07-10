// lib/widgets/rep_details_and_visits_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/rep.dart';
import '../models/visit.dart';
import '../views/screens/manager_call_log_screen.dart'; // Import the new screen

class RepDetailsAndVisitsReport extends StatelessWidget {
  final Salesman rep;
  final List<Visit> visits;
  final String period;
  final VoidCallback? onCallLogged;

  const RepDetailsAndVisitsReport({
    super.key,
    required this.rep,
    required this.visits,
    required this.period,
    this.onCallLogged
  });

  @override
  Widget build(BuildContext context) {
    // ... (rest of your build method, no changes here) ...
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRepDetailsCard(context),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.history, color: AppTheme.primaryRed, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Recent Visits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${visits.length} visits',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: visits.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No visits recorded',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'for this period.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: visits.length,
                itemBuilder: (context, index) {
                  final visit = visits[index];
                  return _buildVisitCard(context, visit);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (unchanged _buildRepDetailsCard and _buildDetailRow methods) ...

  Widget _buildVisitCard(BuildContext context, Visit visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          visit.clientName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${visit.dateVisited} at ${visit.timeVisited}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 80,),
                _buildVisitRatingRow(context, 'Overall Happiness:', visit.happy),
              ],
            ),
            Text(
              'Account: ${visit.clientAccountNumber}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            if (visit.managerCallLogged) // Show a badge if manager has logged a call
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Manager Call Logged',
                      style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        leading: const Icon(Icons.event, color: AppTheme.primaryRed),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVisitDetailRow(context, 'Spoke to:', visit.spokeTo),
                _buildVisitDetailRow(context, 'At Premises:', visit.atPremises),
                if (visit.feedbackOnPremises != null && visit.feedbackOnPremises!.isNotEmpty)
                  _buildVisitDetailRow(context, 'Premises Feedback:', visit.feedbackOnPremises!),
                if (visit.clientFeedback != null && visit.clientFeedback!.isNotEmpty)
                  _buildVisitDetailRow(context, 'Client Feedback:', visit.clientFeedback!),
                if (visit.repComment != null && visit.repComment!.isNotEmpty)
                  _buildVisitDetailRow(context, 'Rep Comment:', visit.repComment!),
                _buildVisitRatingRow(context, 'Overall Happiness:', visit.happy),
                _buildVisitRatingRow(context, 'Service Happiness:', visit.happyWithService),
                _buildVisitRatingRow(context, 'Staff Happiness:', visit.happyWithStaff),
                _buildVisitRatingRow(context, 'Parts Received:', visit.receivedParts),
                if (visit.visitLat != null && visit.visitLong != null)
                  _buildVisitDetailRow(context, 'Visit Location:', 'Lat: ${visit.visitLat!.toStringAsFixed(4)}, Long: ${visit.visitLong!.toStringAsFixed(4)}'),
                if (visit.managerFeedback != null && visit.managerFeedback!.isNotEmpty)
                  _buildVisitDetailRow(context, 'Manager Feedback:', visit.managerFeedback!),
                if (visit.isClientFeedbackCorrect != null)
                  _buildVisitDetailRow(context, 'Client Feedback Correct:', visit.isClientFeedbackCorrect! ? 'Yes' : 'No'),
                const SizedBox(height: 10),
                Text(
                  'Completion Status:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: visit.completed.map((status) {
                    return Chip(
                      label: Text(status.name),
                      backgroundColor: status.status ? Colors.green.shade100 : Colors.red.shade100,
                      labelStyle: TextStyle(
                        color: status.status ? Colors.green.shade800 : Colors.red.shade800,
                        fontSize: 12,
                      ),
                      avatar: Icon(
                        status.status ? Icons.check_circle : Icons.cancel,
                        color: status.status ? Colors.green.shade800 : Colors.red.shade800,
                        size: 18,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16), // Spacer before the button

                // --- ADD THE NEW BUTTON HERE ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManagerCallLogScreen(visit: visit),
                        ),
                      ).then((_) {
                        // Optional: When the ManagerCallLogScreen pops,
                        // you might want to refresh the visits list in VisitViewModel
                        // to reflect the 'managerCallLogged' status change.
                        // You would need to access VisitViewModel here.
                        // For simplicity now, we'll leave it as a manual refresh by navigating away and back.
                        // A more robust solution would be to call viewModel.fetchVisitsForSelectedRep()
                        // but that would require passing the VisitViewModel instance or a callback.
                      });
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Log Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepDetailsCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryRed.withAlpha(64),
                  child: Text(
                    rep.name.isNotEmpty ? rep.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${rep.name} ${rep.surname}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rep Code: ${rep.repCode ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Email: ${rep.userEmail ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(context, Icons.phone_android, 'Total Calls', '${rep.totalCalls}'),
            _buildDetailRow(context, Icons.location_on, 'Total Visits', '${rep.totalVisits}'),
            _buildDetailRow(context, Icons.people_alt, 'New Client Requests', '${rep.totalNewClientRequest}'),
            if (rep.currentLat != null && rep.currentLong != null)
              _buildDetailRow(context, Icons.my_location, 'Last Known Location', 'Lat: ${rep.currentLat!.toStringAsFixed(4)}, Long: ${rep.currentLong!.toStringAsFixed(4)}'),
            _buildDetailRow(context, Icons.check_circle_outline, 'Approved', rep.isApproved ? 'Yes' : 'No', iconColor: rep.isApproved ? Colors.green : Colors.red),
            _buildDetailRow(context, Icons.verified_user, 'Rep Approved', rep.isApprovedRep ? 'Yes' : 'No', iconColor: rep.isApprovedRep ? Colors.green : Colors.red),
            if (rep.ts != null)
              _buildDetailRow(context, Icons.update, 'Last Updated', DateFormat('yyyy-MM-dd HH:mm').format(rep.ts!.toDate())),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? Theme.of(context).iconTheme.color?.withAlpha(125)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildVisitCard(BuildContext context, Visit visit) {
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 12.0),
  //     elevation: 1,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     child: ExpansionTile(
  //       tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       title: Text(
  //         visit.clientName,
  //         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //       ),
  //       subtitle: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 4),
  //           Text(
  //             '${visit.dateVisited} at ${visit.timeVisited}',
  //             style: TextStyle(fontSize: 13, color: Colors.grey[600]),
  //           ),
  //           Text(
  //             'Account: ${visit.clientAccountNumber}',
  //             style: TextStyle(fontSize: 13, color: Colors.grey[600]),
  //           ),
  //         ],
  //       ),
  //       leading: const Icon(Icons.event, color: AppTheme.primaryRed),
  //       children: [
  //         const Divider(height: 1),
  //         Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               _buildVisitDetailRow(context, 'Spoke to:', visit.spokeTo),
  //               _buildVisitDetailRow(context, 'At Premises:', visit.atPremises),
  //               if (visit.feedbackOnPremises != null && visit.feedbackOnPremises!.isNotEmpty)
  //                 _buildVisitDetailRow(context, 'Premises Feedback:', visit.feedbackOnPremises!),
  //               if (visit.clientFeedback != null && visit.clientFeedback!.isNotEmpty)
  //                 _buildVisitDetailRow(context, 'Client Feedback:', visit.clientFeedback!),
  //               if (visit.repComment != null && visit.repComment!.isNotEmpty)
  //                 _buildVisitDetailRow(context, 'Rep Comment:', visit.repComment!),
  //               _buildVisitRatingRow(context, 'Overall Happiness:', visit.happy),
  //               _buildVisitRatingRow(context, 'Service Happiness:', visit.happyWithService),
  //               _buildVisitRatingRow(context, 'Staff Happiness:', visit.happyWithStaff),
  //               _buildVisitRatingRow(context, 'Parts Received:', visit.receivedParts),
  //               if (visit.visitLat != null && visit.visitLong != null)
  //                 _buildVisitDetailRow(context, 'Visit Location:', 'Lat: ${visit.visitLat!.toStringAsFixed(4)}, Long: ${visit.visitLong!.toStringAsFixed(4)}'),
  //               const SizedBox(height: 10),
  //               Text(
  //                 'Completion Status:',
  //                 style: Theme.of(context).textTheme.titleSmall,
  //               ),
  //               Wrap(
  //                 spacing: 8.0,
  //                 runSpacing: 4.0,
  //                 children: visit.completed.map((status) {
  //                   return Chip(
  //                     label: Text(status.name),
  //                     backgroundColor: status.status ? Colors.green.shade100 : Colors.red.shade100,
  //                     labelStyle: TextStyle(
  //                       color: status.status ? Colors.green.shade800 : Colors.red.shade800,
  //                       fontSize: 12,
  //                     ),
  //                     avatar: Icon(
  //                       status.status ? Icons.check_circle : Icons.cancel,
  //                       color: status.status ? Colors.green.shade800 : Colors.red.shade800,
  //                       size: 18,
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildVisitDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitRatingRow(BuildContext context, String label, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              );
            }),
          ),
          const SizedBox(width: 8),
          Text('$rating/5'),
        ],
      ),
    );
  }
}