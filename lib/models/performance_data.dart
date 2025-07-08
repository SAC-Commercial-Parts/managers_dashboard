import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp if used

class PerformanceData {
  final String id; // Added ID to match Firestore document ID
  final String employeeId;
  final DateTime date;
  final Map<String, dynamic> metrics; // Flexible map for various metrics

  PerformanceData({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.metrics,
  });

  // Factory constructor to create PerformanceData from a Firestore document
  factory PerformanceData.fromFirestore(String id, Map<String, dynamic> data) {
    // Dates can be stored as ISO 8601 strings or Firestore Timestamps
    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.parse(data['date'] as String);
    } else {
      // Handle cases where date might be missing or in an unexpected format
      parsedDate = DateTime.now(); // Default to now, or throw an error
      print('Warning: PerformanceData date format unexpected for ID $id. Data: ${data['date']}');
    }

    return PerformanceData(
      id: id,
      employeeId: data['employeeId'] as String,
      date: parsedDate,
      metrics: Map<String, dynamic>.from(data['metrics'] as Map),
    );
  }

  // Method to convert PerformanceData to a map suitable for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'date': date.toIso8601String().substring(0, 10), // Store as YYYY-MM-DD string for consistency with other date fields
      'metrics': metrics,
    };
  }
}

// Updated FilterPeriod enum to include all necessary periods
enum FilterPeriod {
  today,
  thisMonth,
  lastMonth,
  thisQuarter,
  lastQuarter,
  thisYear,
  lastYear,
  allTime,
  sixtyDays, // From your original request
  ninetyDays, // From your original request
  oneHundredTwentyDays // From your original request
}

extension FilterPeriodExtension on FilterPeriod {
  String get displayName {
    switch (this) {
      case FilterPeriod.today:
        return 'Today';
      case FilterPeriod.thisMonth:
        return 'This Month';
      case FilterPeriod.lastMonth:
        return 'Last Month';
      case FilterPeriod.thisQuarter:
        return 'This Quarter';
      case FilterPeriod.lastQuarter:
        return 'Last Quarter';
      case FilterPeriod.thisYear:
        return 'This Year';
      case FilterPeriod.lastYear:
        return 'Last Year';
      case FilterPeriod.allTime:
        return 'All Time';
      case FilterPeriod.sixtyDays:
        return 'Last 60 Days';
      case FilterPeriod.ninetyDays:
        return 'Last 90 Days';
      case FilterPeriod.oneHundredTwentyDays:
        return 'Last 120 Days';
    }
  }

  // Returns the start date for the selected period
  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case FilterPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case FilterPeriod.thisMonth:
        return DateTime(now.year, now.month, 1);
      case FilterPeriod.lastMonth:
        return DateTime(now.year, now.month - 1, 1);
      case FilterPeriod.thisQuarter:
        final currentMonth = now.month;
        if (currentMonth >= 1 && currentMonth <= 3) return DateTime(now.year, 1, 1);
        if (currentMonth >= 4 && currentMonth <= 6) return DateTime(now.year, 4, 1);
        if (currentMonth >= 7 && currentMonth <= 9) return DateTime(now.year, 7, 1);
        return DateTime(now.year, 10, 1);
      case FilterPeriod.lastQuarter:
        final currentMonth = now.month;
        if (currentMonth >= 1 && currentMonth <= 3) return DateTime(now.year - 1, 10, 1); // Last Q was Q4 of prev year
        if (currentMonth >= 4 && currentMonth <= 6) return DateTime(now.year, 1, 1);    // Last Q was Q1
        if (currentMonth >= 7 && currentMonth <= 9) return DateTime(now.year, 4, 1);    // Last Q was Q2
        return DateTime(now.year, 7, 1); // Last Q was Q3
      case FilterPeriod.thisYear:
        return DateTime(now.year, 1, 1);
      case FilterPeriod.lastYear:
        return DateTime(now.year - 1, 1, 1);
      case FilterPeriod.allTime:
        return DateTime(2000, 1, 1); // Arbitrary old date for 'all time'
      case FilterPeriod.sixtyDays:
        return now.subtract(const Duration(days: 60));
      case FilterPeriod.ninetyDays:
        return now.subtract(const Duration(days: 90));
      case FilterPeriod.oneHundredTwentyDays:
        return now.subtract(const Duration(days: 120));
    }
  }

  // Returns the end date for the selected period
  DateTime get endDate {
    final now = DateTime.now();
    switch (this) {
      case FilterPeriod.today:
        return DateTime(now.year, now.month, now.day, 23, 59, 59); // End of today
      case FilterPeriod.thisMonth:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59); // Last day of this month
      case FilterPeriod.lastMonth:
        return DateTime(now.year, now.month, 0, 23, 59, 59); // Last day of previous month
      case FilterPeriod.thisQuarter:
        final currentMonth = now.month;
        if (currentMonth >= 1 && currentMonth <= 3) return DateTime(now.year, 3, 31, 23, 59, 59);
        if (currentMonth >= 4 && currentMonth <= 6) return DateTime(now.year, 6, 30, 23, 59, 59);
        if (currentMonth >= 7 && currentMonth <= 9) return DateTime(now.year, 9, 30, 23, 59, 59);
        return DateTime(now.year, 12, 31, 23, 59, 59);
      case FilterPeriod.lastQuarter:
        final currentMonth = now.month;
        if (currentMonth >= 1 && currentMonth <= 3) return DateTime(now.year - 1, 12, 31, 23, 59, 59);
        if (currentMonth >= 4 && currentMonth <= 6) return DateTime(now.year, 3, 31, 23, 59, 59);
        if (currentMonth >= 7 && currentMonth <= 9) return DateTime(now.year, 6, 30, 23, 59, 59);
        return DateTime(now.year, 9, 30, 23, 59, 59);
      case FilterPeriod.thisYear:
        return DateTime(now.year, 12, 31, 23, 59, 59); // End of this year
      case FilterPeriod.lastYear:
        return DateTime(now.year - 1, 12, 31, 23, 59, 59); // End of last year
      case FilterPeriod.allTime:
        return DateTime(now.year + 1, 1, 1); // Arbitrary future date for 'all time'
      case FilterPeriod.sixtyDays:
      case FilterPeriod.ninetyDays:
      case FilterPeriod.oneHundredTwentyDays:
        return DateTime(now.year, now.month, now.day, 23, 59, 59); // End of today for "last X days"
    }
  }
}
