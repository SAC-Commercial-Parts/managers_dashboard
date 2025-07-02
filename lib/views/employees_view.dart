import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
// import '../models/employee.dart';
// import '../models/performance_data.dart';
import '../viewmodels/employee_viewmodel.dart';
import '../widgets/employee_card.dart';
import '../widgets/performance_report.dart';
import '../widgets/filter_dropdown.dart';

class EmployeesView extends StatelessWidget {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Consumer<EmployeeViewModel>(
      builder: (context, viewModel, child)
      {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
            [
              // Header Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Branch ${viewModel.currentBranch} Employees',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${viewModel.employees.length} employees in this branch',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
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

              // Loading or Content
              if (viewModel.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildEmployeesList(viewModel),
                      ),
                      if (viewModel.selectedEmployee != null) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: PerformanceReport(
                            employee: viewModel.selectedEmployee!,
                            performanceData: viewModel.performanceData,
                            period: viewModel.selectedPeriod,
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

  Widget _buildEmployeesList(EmployeeViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  color: AppTheme.primaryRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Employees (${viewModel.employees.length})',
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
            child: viewModel.employees.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No employees found',
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
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: viewModel.employees.length,
              itemBuilder: (context, index) {
                final employee = viewModel.employees[index];
                return EmployeeCard(
                  employee: employee,
                  isSelected: viewModel.selectedEmployee?.id == employee.id,
                  onTap: () => viewModel.selectEmployee(employee),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}