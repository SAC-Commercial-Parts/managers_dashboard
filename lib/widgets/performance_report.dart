import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';
import '../models/employee.dart';
import '../models/performance_data.dart';

class PerformanceReport extends StatelessWidget {
  final Employee employee;
  final List<PerformanceData> performanceData;
  final FilterPeriod period;

  const PerformanceReport({
    super.key,
    required this.employee,
    required this.performanceData,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getTypeColor(employee.type),
                  child: Icon(
                    _getTypeIcon(employee.type),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_getTypeString(employee.type)} • ${employee.branchCode}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildMetrics(),
            const SizedBox(height: 24),
            if (performanceData.isNotEmpty) ...[
              const Text(
                'Performance Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildPerformanceChart(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetrics() {
    final totalMetrics = _calculateTotalMetrics();

    switch (employee.type) {
      case EmployeeType.driver:
        return Column(
          children: [
            _buildMetricRow('Total Deliveries', totalMetrics['deliveries']?.toString() ?? '0'),
            _buildMetricRow('Assigned Car', employee.carAssigned ?? 'N/A'),
          ],
        );
      case EmployeeType.rep:
        return Column(
          children: [
            _buildMetricRow('Quotes Scanned', totalMetrics['quotesScanned']?.toString() ?? '0'),
            _buildMetricRow('Conversions', totalMetrics['conversions']?.toString() ?? '0'),
            _buildMetricRow('Client Visits', totalMetrics['clientVisits']?.toString() ?? '0'),
            _buildMetricRow('Delivery Visits', totalMetrics['deliveryVisits']?.toString() ?? '0'),
          ],
        );
      case EmployeeType.salesman:
        return Column(
          children: [
            _buildMetricRow('Quotes Made', totalMetrics['quotes']?.toString() ?? '0'),
            _buildMetricRow('Invoices Made', totalMetrics['invoices']?.toString() ?? '0'),
            _buildMetricRow('Calls Made', totalMetrics['calls']?.toString() ?? '0'),
          ],
        );
    }
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    if (performanceData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = <FlSpot>[];
    String metricKey = '';

    switch (employee.type) {
      case EmployeeType.driver:
        metricKey = 'deliveries';
        break;
      case EmployeeType.rep:
        metricKey = 'quotesScanned';
        break;
      case EmployeeType.salesman:
        metricKey = 'quotes';
        break;
    }

    for (int i = 0; i < performanceData.length; i++) {
      final data = performanceData[i];
      final value = (data.metrics[metricKey] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _getTypeColor(employee.type),
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _getTypeColor(employee.type).withOpacity(0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < performanceData.length) {
                  final date = performanceData[index].date;
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 10),
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
        gridData: const FlGridData(show: true),
      ),
    );
  }

  Map<String, dynamic> _calculateTotalMetrics() {
    final totals = <String, dynamic>{};

    for (final data in performanceData) {
      data.metrics.forEach((key, value) {
        if (value is num) {
          totals[key] = (totals[key] ?? 0) + value;
        } else {
          totals[key] = value;
        }
      });
    }

    return totals;
  }

  Color _getTypeColor(EmployeeType type) {
    switch (type) {
      case EmployeeType.driver:
        return AppTheme.primaryRed;
      case EmployeeType.rep:
        return Colors.blue;
      case EmployeeType.salesman:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(EmployeeType type) {
    switch (type) {
      case EmployeeType.driver:
        return Icons.local_shipping;
      case EmployeeType.rep:
        return Icons.business;
      case EmployeeType.salesman:
        return Icons.person;
    }
  }

  String _getTypeString(EmployeeType type) {
    switch (type) {
      case EmployeeType.driver:
        return 'Driver';
      case EmployeeType.rep:
        return 'Sales Rep';
      case EmployeeType.salesman:
        return 'Salesman';
    }
  }
}