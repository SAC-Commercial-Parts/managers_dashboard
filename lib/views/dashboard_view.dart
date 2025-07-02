import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';
// import '../models/performance_data.dart';
import '../viewmodels/dashboard_viewmodel.dart';
// import '../widgets/metric_card.dart';
import '../widgets/filter_dropdown.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
            [
              // Header Section
              _buildHeaderSection(viewModel),
              const SizedBox(height: 24),

              // Loading or Content
              if (viewModel.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...
              [
                // Metrics Grid
                _buildMetricsGrid(viewModel.branchSummary),
                const SizedBox(height: 24),

                // Performance Chart
                _buildPerformanceChart(viewModel.branchSummary),
                const SizedBox(height: 24),

                // Additional Stats
                _buildAdditionalStats(viewModel.branchSummary),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(DashboardViewModel viewModel)
  {
    return Card(
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
                    'Branch ${viewModel.currentBranch}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manager: ${viewModel.managerName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Performance Overview',
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
    );
  }

  Widget _buildMetricsGrid(Map<String, double> summary)
  {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildEnhancedMetricCard(
              title: 'Total Deliveries',
              value: summary['deliveries']?.toInt().toString() ?? '0',
              icon: Icons.local_shipping,
              color: AppTheme.primaryRed,
              subtitle: 'Completed deliveries',
            ),
            _buildEnhancedMetricCard(
              title: 'Total Quotes',
              value: summary['quotes']?.toInt().toString() ?? '0',
              icon: Icons.description,
              color: AppTheme.darkRed,
              subtitle: 'Generated quotes',
            ),
            _buildEnhancedMetricCard(
              title: 'Conversions',
              value: summary['conversions']?.toInt().toString() ?? '0',
              icon: Icons.trending_up,
              color: Colors.green,
              subtitle: 'Successful conversions',
            ),
            _buildEnhancedMetricCard(
              title: 'Total Calls',
              value: summary['calls']?.toInt().toString() ?? '0',
              icon: Icons.phone,
              color: Colors.blue,
              subtitle: 'Client calls made',
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  })
  {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGray,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(Map<String, double> summary)
  {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Branch Performance Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Live Data',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: summary['deliveries'] ?? 0,
                          color: AppTheme.primaryRed,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: summary['quotes'] ?? 0,
                          color: AppTheme.darkRed,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: summary['conversions'] ?? 0,
                          color: Colors.green,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: summary['calls'] ?? 0,
                          color: Colors.blue,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.darkGray,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Deliveries', 'Quotes', 'Conversions', 'Calls'];
                          if (value.toInt() < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                titles[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkGray,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStats(Map<String, double> summary)
  {
    final conversionRate = summary['quotes'] != null && summary['quotes']! > 0
        ? ((summary['conversions'] ?? 0) / summary['quotes']! * 100)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Conversion Rate',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${conversionRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Quotes to conversions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.speed,
                        color: Colors.purple,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Activity Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${((summary['calls'] ?? 0) + (summary['deliveries'] ?? 0)).toInt()}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    'Total activities',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}