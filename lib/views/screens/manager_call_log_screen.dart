// lib/screens/manager_call_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/visit.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/manager_call_log_viewmodel.dart';

////////////////////////////////////////////////////////////////////////////
//                         MANAGERS CALL LOG SCREEN                       //
////////////////////////////////////////////////////////////////////////////
// FOR REPS
class ManagerCallLogScreen extends StatelessWidget
{
  final Visit visit;

  const ManagerCallLogScreen({super.key, required this.visit});

  ////////////////////////////////////////////////////////////////////////////
  //                                UI OUTPUT                               //
  ////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context)
  {
    return ChangeNotifierProvider(
      create: (context) => ManagerCallLogViewModel(visit, Provider.of<AuthService>(context, listen: false)),
      child: Consumer<ManagerCallLogViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            ////////////////////////////////////////////////////////////////////////////
            //                                  APP BAR                               //
            ////////////////////////////////////////////////////////////////////////////
            appBar: AppBar(
              title: Text('Log Call for ${visit.clientName}'),
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
            ),

            ////////////////////////////////////////////////////////////////////////////
            //                                 MAIN DATA                              //
            ////////////////////////////////////////////////////////////////////////////
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DEATAILS ABOUT VISIT
                  _buildVisitDetailsCard(context, visit),
                  const SizedBox(height: 20),

                  if (viewModel.salesmanCallHistoryExists) // Display salesman call history if found
                    _buildSalesmanCallHistoryWarning(context, viewModel),
                  const SizedBox(height: 20),

                  // MANAGERS FEEDBACK
                  _buildManagerFeedbackSection(context, viewModel),
                  const SizedBox(height: 20),

                  // CALL LOG BUTTONS
                  _buildCallLogButtons(context, viewModel), // Renamed for multiple buttons
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                               VISIT DETAILS                            //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildVisitDetailsCard(BuildContext context, Visit visit)
  {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visit Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _detailRow('Client Name:', visit.clientName),
            _detailRow('Account No:', visit.clientAccountNumber),
            _detailRow('Date Visited:', visit.dateVisited),
            _detailRow('Time Visited:', visit.timeVisited),
            _detailRow('Rep Comment:', visit.repComment ?? 'N/A'),
            const SizedBox(height: 10),
            Text(
              'Client Feedback from Rep:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                visit.clientFeedback ?? 'No feedback provided by rep.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                               DETAILS ROW                              //
  ////////////////////////////////////////////////////////////////////////////
  Widget _detailRow(String label, String value)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
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

  ////////////////////////////////////////////////////////////////////////////
  //                       SALESMAN CALL HISTORY FLAG                       //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildSalesmanCallHistoryWarning(BuildContext context, ManagerCallLogViewModel viewModel)
  {
    return Card(
      color: Colors.yellow.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salesman Call History Exists!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A salesman (${viewModel.salesmanNameFromCallHistory ?? 'Unknown'}) has logged calls for this client. Please review their call log in the Salesman Call Report if available.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             FEEDBACK SECTION                           //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildManagerFeedbackSection(BuildContext context, ManagerCallLogViewModel viewModel)
  {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manager Call Details', // Renamed from Manager Call Log Details
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),

            // Spoke To Field - Enabled only if call is NOT unanswered
            Text(
              'Who did you speak to? (Optional if call unanswered)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.spokeToController,
              enabled: !viewModel.callWasUnanswered, // Disable if unanswered
              decoration: InputDecoration(
                hintText: 'Name of person spoken to...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
                fillColor: viewModel.callWasUnanswered ? Colors.grey[200] : null,
                filled: viewModel.callWasUnanswered,
              ),
              onChanged: (value) => viewModel.updateSpokeTo(value), // <--- CHANGE IS HERE
            ),
            const SizedBox(height: 20),


            Text(
              'Your Feedback:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.managerFeedbackController,
              enabled: !viewModel.callWasUnanswered, // Disable if unanswered
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
                fillColor: viewModel.callWasUnanswered ? Colors.grey[200] : null,
                filled: viewModel.callWasUnanswered,
              ),
              onChanged: (value) => viewModel.updateManagerFeedback(value), // <--- CHANGE IS HERE
            ),
            const SizedBox(height: 20),

            // Is Rep's Client Feedback Correct? - Enabled only if call is NOT unanswered
            Text(
              'Is Rep\'s Client Feedback Correct?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool?>(
                    title: const Text('Yes, Correct'),
                    value: true,
                    groupValue: viewModel.isClientFeedbackCorrect,
                    onChanged: viewModel.callWasUnanswered ? null : viewModel.setIsClientFeedbackCorrect, // Disable if unanswered
                    activeColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool?>(
                    title: const Text('No, Incorrect'),
                    value: false,
                    groupValue: viewModel.isClientFeedbackCorrect,
                    onChanged: viewModel.callWasUnanswered ? null : viewModel.setIsClientFeedbackCorrect, // Disable if unanswered
                    activeColor: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
            RadioListTile<bool?>(
              title: const Text('Not Applicable / Unsure'),
              value: null,
              groupValue: viewModel.isClientFeedbackCorrect,
              onChanged: viewModel.callWasUnanswered ? null : viewModel.setIsClientFeedbackCorrect, // Disable if unanswered
              activeColor: Colors.grey,
            ),
            const SizedBox(height: 20),

            // Call Unanswered Checkbox
            Row(
              children: [
                Checkbox(
                  value: viewModel.callWasUnanswered,
                  onChanged: viewModel.isLoading ? null : viewModel.setCallWasUnanswered,
                  activeColor: AppTheme.primaryRed,
                ),
                Text(
                  'Call Was Unanswered / Client Could Not Be Reached',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             CALL LOG BUTTONS                           //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildCallLogButtons(BuildContext context, ManagerCallLogViewModel viewModel)
  {
    return Row(
      children: [
        ////////////////////////////////////////////////////////////////////////////
        //                                 LOG CALL                               //
        ////////////////////////////////////////////////////////////////////////////
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading || !viewModel.canLogCall
                ? null
                : () async {

              try {
                await viewModel.saveCallLog(isUnanswered: false);
                if(!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call log saved successfully!')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save call log: $e')),
                );
              }
            },
            icon: viewModel.isLoading && !viewModel.callWasUnanswered
                ? _buildLoadingSpinner()
                : const Icon(Icons.phone_in_talk),
            label: Text(viewModel.isLoading && !viewModel.callWasUnanswered ? 'Saving...' : 'Log Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(width: 10),
        ////////////////////////////////////////////////////////////////////////////
        //                            UNANSWERED CALL                             //
        ////////////////////////////////////////////////////////////////////////////
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading || !viewModel.canLogUnansweredCall
                ? null
                : () async {
              try {
                await viewModel.saveCallLog(isUnanswered: true);
                if(!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unanswered call logged!')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to log unanswered call: $e')),
                );
              }
            },
            icon: viewModel.isLoading && viewModel.callWasUnanswered
                ? _buildLoadingSpinner()
                : const Icon(Icons.phone_missed),
            label: Text(viewModel.isLoading && viewModel.callWasUnanswered ? 'Saving...' : 'Unanswered Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey, // Different color for unanswered
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             LOADING SPINNER                            //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildLoadingSpinner() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }
}