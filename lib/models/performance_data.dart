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

enum FilterPeriod { today, thisMonth, sixtyDays, ninetyDays, oneHundredTwentyDays }

extension FilterPeriodExtension on FilterPeriod {
  String get displayName {
    switch (this) {
      case FilterPeriod.today:
        return 'Today';
      case FilterPeriod.thisMonth:
        return 'This Month';
      case FilterPeriod.sixtyDays:
        return '60 Days';
      case FilterPeriod.ninetyDays:
        return '90 Days';
      case FilterPeriod.oneHundredTwentyDays:
        return '120 Days';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case FilterPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case FilterPeriod.thisMonth:
        return DateTime(now.year, now.month, 1);
      case FilterPeriod.sixtyDays:
        return now.subtract(const Duration(days: 60));
      case FilterPeriod.ninetyDays:
        return now.subtract(const Duration(days: 90));
      case FilterPeriod.oneHundredTwentyDays:
        return now.subtract(const Duration(days: 120));
    }
  }
}