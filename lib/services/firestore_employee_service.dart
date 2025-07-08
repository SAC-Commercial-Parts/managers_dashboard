import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart';
import '../models/performance_data.dart';
import 'auth_service.dart'; // Assuming you have this model

class FirestoreEmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches a list of employees for a specific branch from Firestore.
  /// Data is expected to be at /branches/{branchCode}/employees/{employeeId}
  Future<List<Employee>> getEmployeesByBranch(String branchCode) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('branches')
          .doc(branchCode)
          .collection('employees')
          .get();

      // Use the Employee.fromFirestore factory constructor to parse the data
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Employee.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error fetching employees: $e');
      return []; // Return empty list on error
    }
  }

  /// Fetches performance data for a specific employee from Firestore.
  /// This currently returns dummy data. To use real performance data,
  /// you would need to:
  /// 1. Define a Firestore collection structure for performance data (e.g.,
  ///    `/branches/{branchCode}/employees/{employeeId}/performance_metrics/{metricId}`
  ///    or a top-level collection with employeeId and branchCode fields).
  /// 2. Implement the actual Firestore query here to fetch relevant documents.
  /// 3. Use `PerformanceData.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)`
  ///    to parse the fetched documents into PerformanceData objects.
  Future<List<PerformanceData>> getPerformanceData(String employeeId, FilterPeriod period) async {
    // Example of how you *would* query if you had a performance_metrics collection:

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('branches') // Or a top-level 'performance_metrics' collection
          .doc(AuthService.currentAppUser!.branchCode!) // Assuming branchCode is available
          .collection('employees')
          .doc(employeeId)
          .collection('performance_metrics') // Example subcollection
          .where('date', isGreaterThanOrEqualTo: period.startDate.toIso8601String().substring(0, 10))
          .where('date', isLessThanOrEqualTo: period.endDate.toIso8601String().substring(0, 10))
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PerformanceData.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Error fetching performance data from Firestore: $e');
      return [];
    }


    // For now, returning a dummy list as performance data was not explicitly
    // defined in the Firestore mock data or its structure.
    return [
      PerformanceData(
        id: 'PD001',
        employeeId: employeeId,
        date: DateTime.now().subtract(const Duration(days: 5)),
        metrics: {'Sales Volume': 15000.0, 'Customer Satisfaction': 4.5},
      ),
      PerformanceData(
        id: 'PD002',
        employeeId: employeeId,
        date: DateTime.now().subtract(const Duration(days: 10)),
        metrics: {'Sales Volume': 12000.0, 'Customer Satisfaction': 4.2},
      ),
      PerformanceData(
        id: 'PD003',
        employeeId: employeeId,
        date: DateTime.now().subtract(const Duration(days: 20)),
        metrics: {'Sales Volume': 18000.0, 'Customer Satisfaction': 4.8},
      ),
    ];
  }
}
