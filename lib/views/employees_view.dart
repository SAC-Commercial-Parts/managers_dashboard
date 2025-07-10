// lib/views/visits_view.dart
import 'package:branch_managers_app/models/performance_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/employee_viewmodel.dart';
import '../widgets/rep_details_and_visits_report.dart';
import '../widgets/filter_dropdown.dart';
import '../core/app_theme.dart';

////////////////////////////////////////////////////////////////////////////
//                               VISIT VIEW                               //
////////////////////////////////////////////////////////////////////////////
class VisitsView extends StatelessWidget {
  static const id = '/visits';
  const VisitsView({super.key});

  ////////////////////////////////////////////////////////////////////////////
  //                                UI OUTPUT                               //
  ////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context)
  {
    return Consumer<VisitViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ////////////////////////////////////////////////////////////////////////////
            //                           REP LIST SECTION                             //
            ////////////////////////////////////////////////////////////////////////////
            Expanded(
              flex: 1,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOTAL REPS
                      Text(
                        'Reps in Branch ${viewModel.currentBranch ?? '...'}:',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // FILTER BY DATE RANGE
                      SizedBox(
                        width: 200,
                        child: FilterDropdown(
                          value: viewModel.selectedPeriod,
                          onChanged: viewModel.setPeriod,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (viewModel.isLoading && viewModel.reps.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else if (viewModel.reps.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No reps found for this branch.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      else

                        // LIST OF REPS
                        Expanded(
                          child: ListView.builder(
                            itemCount: viewModel.reps.length,
                            itemBuilder: (context, index) {
                              final rep = viewModel.reps[index];
                              final isSelected = viewModel.selectedRep?.id == rep.id;
                              return Card(
                                elevation: isSelected ? 4 : 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected ? AppTheme.primaryRed : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                color: Theme.of(context).cardColor ,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primaryRed.withAlpha(64),
                                    child: Text(
                                      rep.name.isNotEmpty ? rep.name[0].toUpperCase() : '?',
                                      style: const TextStyle(color: AppTheme.primaryRed),
                                    ),
                                  ),
                                  //tileColor: Theme.of(context).cardColor,
                                  title: Text('${rep.name} ${rep.surname}'),
                                  subtitle: Text('Rep Code: ${rep.repCode}'),
                                  onTap: () {
                                    viewModel.selectRep(rep);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            ////////////////////////////////////////////////////////////////////////////
            //                             REP VISIT DETAILS                          //
            ////////////////////////////////////////////////////////////////////////////
            if (viewModel.selectedRep != null) ...[
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: RepDetailsAndVisitsReport(
                  rep: viewModel.selectedRep!,
                  visits: viewModel.selectedRepVisits,
                  period: viewModel.selectedPeriod.toDisplayString(),
                  onCallLogged: () {
                    // This callback will be triggered when ManagerCallLogScreen pops
                    viewModel.fetchVisitsForSelectedRep(); // Re-fetch data to update badge
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}