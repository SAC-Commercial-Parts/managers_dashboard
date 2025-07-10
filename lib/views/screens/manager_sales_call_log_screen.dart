// lib/screens/manager_sales_call_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';

import '../../models/sales_call.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/manager_sales_call_log_viewmodel.dart';

////////////////////////////////////////////////////////////////////////////
//                        MANAGERS CALL LOG SCREEN                        //
////////////////////////////////////////////////////////////////////////////
// FOR SALESMEN
class ManagerSalesCallLogScreen extends StatelessWidget
{
  final SalesCall salesCall; // Now takes a SalesCall object

  const ManagerSalesCallLogScreen({super.key, required this.salesCall});

  ////////////////////////////////////////////////////////////////////////////
  //                                UI OUTPUT                               //
  ////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context)
  {
    return ChangeNotifierProvider(
      create: (context) => ManagerSalesCallLogViewModel(salesCall, Provider.of<AuthService>(context, listen: false)),
      child: Consumer<ManagerSalesCallLogViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            ////////////////////////////////////////////////////////////////////////////
            //                                 APP BAR                                //
            ////////////////////////////////////////////////////////////////////////////
            appBar: AppBar(
              title: Text('Log Call for ${salesCall.clientName}'),
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
            ),
            ////////////////////////////////////////////////////////////////////////////
            //                                MAIN DATA                               //
            ////////////////////////////////////////////////////////////////////////////
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CALL DETAILS
                  _buildSalesCallDetailsCard(context, salesCall),
                  const SizedBox(height: 20),
                  // MANAGER FEEDBACK
                  _buildManagerFeedbackSection(context, viewModel),
                  const SizedBox(height: 20),
                  // CALL LOG BUTTONS
                  _buildCallLogButtons(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                           CALL DETAILS CARD                            //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildSalesCallDetailsCard(BuildContext context, SalesCall salesCall)
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
              'Sales Call Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _detailRow('Client Name:', salesCall.clientName),
            _detailRow('Account No:', salesCall.clientAccountNumber),
            _detailRow('Call Date:', salesCall.callDate),
            _detailRow('Call Window:', '${salesCall.callWindowOpened} - ${salesCall.callWindowClosed}'),
            _detailRow('Salesman Spoke To:', salesCall.spokeTo!),
            _detailRow('Salesman Feedback:', salesCall.salesmanFeedback ?? 'N/A'),
            _detailRow('Client Feedback:', salesCall.clientFeedback ?? 'N/A'),
            _detailRow('Call Postponed:', salesCall.callWasPostponed ? 'Yes' : 'No'),
            _detailRow('Call Unanswered:', salesCall.callWasUnanswered ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                                DETAILS ROW                             //
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
  //                             FEEDBACK SECTION                           //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildManagerFeedbackSection(BuildContext context, ManagerSalesCallLogViewModel viewModel)
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
              'Manager Call Details',
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
              enabled: !viewModel.callWasUnanswered,
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

            // Manager Feedback Field - Enabled only if call is NOT unanswered
            Text(
              'Your Feedback:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.managerFeedbackController,
              enabled: !viewModel.callWasUnanswered,
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

            // Is Salesman's Client Feedback Correct? - Enabled only if call is NOT unanswered
            Text(
              'Is Salesman\'s Client Feedback Correct?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool?>(
                    title: const Text('Yes, Correct'),
                    value: true,
                    groupValue: viewModel.isSalesmanFeedbackCorrect,
                    onChanged: viewModel.callWasUnanswered ? null : viewModel.setIsSalesmanFeedbackCorrect,
                    activeColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool?>(
                    title: const Text('No, Incorrect'),
                    value: false,
                    groupValue: viewModel.isSalesmanFeedbackCorrect,
                    onChanged: viewModel.callWasUnanswered ? null : viewModel.setIsSalesmanFeedbackCorrect,
                    activeColor: AppTheme.primaryRed,
                  ),
                ),
              ],
            ),
            RadioListTile<bool?>(
              title: const Text('Not Applicable / Unsure'),
              value: null,
              groupValue: viewModel.isSalesmanFeedbackCorrect,
              onChanged: viewModel.callWasUnanswered ? null : viewModel.setIsSalesmanFeedbackCorrect,
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
                  'Manager Call Was Unanswered / Client Could Not Be Reached',
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
  Widget _buildCallLogButtons(BuildContext context, ManagerSalesCallLogViewModel viewModel)
  {
    return Row(
      children: [
        ////////////////////////////////////////////////////////////////////////////
        //                                LOG CALL                                //
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
                  const SnackBar(content: Text('Manager call log saved successfully!')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save manager call log: $e')),
                );
              }
            },
            icon: viewModel.isLoading && !viewModel.callWasUnanswered
                ? _buildLoadingSpinner()
                : const Icon(Icons.phone_in_talk),
            label: Text(viewModel.isLoading && !viewModel.callWasUnanswered ? 'Saving...' : 'Log Manager Call'),
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
        //                             CALL UNANSWERED                            //
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
                  const SnackBar(content: Text('Manager unanswered call logged!')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to log manager unanswered call: $e')),
                );
              }
            },
            icon: viewModel.isLoading && viewModel.callWasUnanswered
                ? _buildLoadingSpinner()
                : const Icon(Icons.phone_missed),
            label: Text(viewModel.isLoading && viewModel.callWasUnanswered ? 'Saving...' : 'Unanswered Manager Call'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
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
  Widget _buildLoadingSpinner()
  {
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