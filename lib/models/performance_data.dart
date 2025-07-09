class PerformanceData {
  final String employeeId;
  final DateTime date;
  final Map<String, dynamic> metrics;

  PerformanceData({
    required this.employeeId,
    required this.date,
    required this.metrics,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      employeeId: json['employeeId'],
      date: DateTime.parse(json['date']),
      metrics: json['metrics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'metrics': metrics,
    };
  }
}

enum FilterPeriod {
  today,
  last7Days,
  last30Days,
  currentMonth,
  lastMonth,
  currentYear,
}

extension FilterPeriodExtension on FilterPeriod {
  String toDisplayString() {
    switch (this) {
      case FilterPeriod.today:
        return 'Today';
      case FilterPeriod.last7Days:
        return 'Last 7 Days';
      case FilterPeriod.last30Days:
        return 'Last 30 Days';
      case FilterPeriod.currentMonth:
        return 'Current Month';
      case FilterPeriod.lastMonth:
        return 'Last Month';
      case FilterPeriod.currentYear:
        return 'Current Year';
    }
  }
}