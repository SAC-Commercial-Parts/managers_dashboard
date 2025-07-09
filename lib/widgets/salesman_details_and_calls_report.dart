// lib/widgets/salesman_details_and_calls_report.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/rep.dart'; // For salesman details
import '../models/sales_call.dart';
import '../views/screens/manager_sales_call_log_screen.dart';

class SalesmanDetailsAndCallsReport extends StatelessWidget {
  final Rep salesman;
  final List<SalesCall> calls;
  final String period;
  final VoidCallback? onCallLogged; // Callback to refresh calls list

  const SalesmanDetailsAndCallsReport({
    super.key,
    required this.salesman,
    required this.calls,
    required this.period,
    this.onCallLogged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSalesmanDetailsCard(context),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.call, color: AppTheme.primaryRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Recent Calls ($period)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${calls.length} calls',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Expanded(
              child: calls.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_missed_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No calls recorded',
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
                itemCount: calls.length,
                itemBuilder: (context, index) {
                  final call = calls[index];
                  return _buildSalesCallCard(context, call);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesmanDetailsCard(BuildContext context) {
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
                    salesman.name.isNotEmpty ? salesman.name[0].toUpperCase() : '?',
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
                      '${salesman.name} ${salesman.surname}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Salesman Code: ${salesman.repCode ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Email: ${salesman.userEmail ?? 'N/A'}',
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
            _buildDetailRow(context, Icons.phone_android, 'Total Calls', '${salesman.totalCalls}'),
            _buildDetailRow(context, Icons.check_circle_outline, 'Approved', salesman.isApproved ? 'Yes' : 'No', iconColor: salesman.isApproved ? Colors.green : Colors.red),
            _buildDetailRow(context, Icons.verified_user, 'Salesman Approved', salesman.isApprovedRep ? 'Yes' : 'No', iconColor: salesman.isApprovedRep ? Colors.green : Colors.red),
            if (salesman.ts != null)
              _buildDetailRow(context, Icons.update, 'Last Updated', DateFormat('yyyy-MM-dd HH:mm').format(salesman.ts!.toDate())),
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

  Widget _buildSalesCallCard(BuildContext context, SalesCall call) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          call.clientName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${call.callDate} - ${call.callWindowOpened} to ${call.callWindowClosed}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            Text(
              'Account: ${call.clientAccountNumber}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            if (call.managerCallLogged) // Show a badge if manager has logged a call
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
        leading: const Icon(Icons.call, color: AppTheme.primaryRed),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCallDetailRow(context, 'Spoke to:', call.spokeTo),
                _buildCallDetailRow(context, 'Client Feedback:', call.clientFeedback ?? 'N/A'),
                _buildCallDetailRow(context, 'Salesman Feedback:', call.salesmanFeedback ?? 'N/A'),
                _buildCallDetailRow(context, 'Call Postponed:', call.callWasPostponed ? 'Yes' : 'No'),
                _buildCallDetailRow(context, 'Call Unanswered:', call.callWasUnanswered ? 'Yes' : 'No'),
                _buildCallDetailRow(context, 'Added Business Focus:', call.addedBusinessFocus ? 'Yes' : 'No'),
                _buildCallDetailRow(context, 'Added Contact:', call.addedContact ? 'Yes' : 'No'),
                _buildCallDetailRow(context, 'Added Potential:', call.addedPotential ? 'Yes' : 'No'),
                _buildCallDetailRow(context, 'Added Vehicle:', call.addedVehicle ? 'Yes' : 'No'),
                if (call.managerFeedback != null && call.managerFeedback!.isNotEmpty)
                  _buildCallDetailRow(context, 'Manager Feedback:', call.managerFeedback!),
                if (call.isSalesmanFeedbackCorrect != null)
                  _buildCallDetailRow(context, 'Salesman Feedback Correct:', call.isSalesmanFeedbackCorrect! ? 'Yes' : 'No'),
                if (call.managerCallWasUnanswered != null)
                  _buildCallDetailRow(context, 'Manager Call Unanswered:', call.managerCallWasUnanswered! ? 'Yes' : 'No'),

                const SizedBox(height: 16), // Spacer before the button

                // --- ADD THE NEW BUTTON HERE ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManagerSalesCallLogScreen(salesCall: call),
                        ),
                      ).then((_) {
                        // Refresh the calls list when the ManagerSalesCallLogScreen pops
                        if (onCallLogged != null) {
                          onCallLogged!();
                        }
                      });
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Log Manager Call'),
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

  Widget _buildCallDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150, // Slightly wider for labels
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
}