// lib/views/salesman_call_view.dart
import 'package:branch_managers_app/models/performance_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../viewmodels/salesman_call_viewmodel.dart'; // Import the new ViewModel
import '../widgets/salesman_card.dart'; // Import the new SalesmanCard
import '../widgets/salesman_details_and_calls_report.dart'; // Import the new report widget
import '../widgets/filter_dropdown.dart';

class SalesmanCallView extends StatelessWidget {
  static const id = '/salesman_calls';
  const SalesmanCallView({super.key});

  ////////////////////////////////////////////////////////////////////////////
  //                                UI OUTPUT                               //
  ////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context)
  {
    return Consumer<SalesmanCallViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          ////////////////////////////////////////////////////////////////////////////
                          //                                   HEADING                              //
                          ////////////////////////////////////////////////////////////////////////////
                          children: [
                            Text(
                              'Branch ${viewModel.currentBranch ?? "..."} Salesmen',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${viewModel.salesmen.length} salesmen in this branch',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // DATE FILTER
                      SizedBox(
                        width: 200,
                        child: FilterDropdown(
                          value: viewModel.selectedPeriod,
                          onChanged: viewModel.setPeriod,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // LOADING INDICATOR
              if (viewModel.isLoading && viewModel.salesmen.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else

              ////////////////////////////////////////////////////////////////////////////
              //                                 MAIN LIST                              //
              ////////////////////////////////////////////////////////////////////////////
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200 -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildSalesmenList(viewModel), // Call _buildSalesmenList
                      ),
                      if (viewModel.selectedSalesman != null) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: SalesmanDetailsAndCallsReport( // Use SalesmanDetailsAndCallsReport
                            salesman: viewModel.selectedSalesman!,
                            calls: viewModel.selectedSalesmanCalls,
                            period: viewModel.selectedPeriod.toDisplayString(),
                            onCallLogged: () {
                              // Refresh calls list when manager logs a call
                              viewModel.fetchCallsForSelectedSalesman();
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  ////////////////////////////////////////////////////////////////////////////
  //                              SALESMAN LIST                             //
  ////////////////////////////////////////////////////////////////////////////
  Widget _buildSalesmenList(SalesmanCallViewModel viewModel)
  {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            ////////////////////////////////////////////////////////////////////////////
            //                                   HEADER                               //
            ////////////////////////////////////////////////////////////////////////////
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  color: AppTheme.primaryRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Salesmen (${viewModel.salesmen.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),


          Expanded(
            child: viewModel.salesmen.isEmpty
                ? Center(
              // NO LIST
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline, // Changed icon
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No salesmen found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'for this branch',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )

            // MAIN LIST
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: viewModel.salesmen.length,
              itemBuilder: (context, index) {
                final salesman = viewModel.salesmen[index];
                return SalesmanCard( // Use SalesmanCard
                  salesman: salesman,
                  isSelected: viewModel.selectedSalesman?.id == salesman.id,
                  onTap: () => viewModel.selectSalesman(salesman),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}