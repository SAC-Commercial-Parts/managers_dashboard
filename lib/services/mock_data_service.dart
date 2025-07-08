// import '../models/employee.dart';
// import '../models/performance_data.dart';
// import 'dart:math';
//
// class MockDataService {
//   static final List<Employee> _employees = [
//     Employee(id: '1', name: 'John Driver', email: 'john@company.com', type: EmployeeType.driver, branchCode: 'BR001', carAssigned: 'CAR-001'),
//     Employee(id: '2', name: 'Sarah Rep', email: 'sarah@company.com', type: EmployeeType.rep, branchCode: 'BR001'),
//     Employee(id: '3', name: 'Mike Salesman', email: 'mike@company.com', type: EmployeeType.salesman, branchCode: 'BR001'),
//     Employee(id: '4', name: 'Lisa Driver', email: 'lisa@company.com', type: EmployeeType.driver, branchCode: 'BR002', carAssigned: 'CAR-002'),
//     Employee(id: '5', name: 'Tom Rep', email: 'tom@company.com', type: EmployeeType.rep, branchCode: 'BR002'),
//     Employee(id: '6', name: 'Anna Salesman', email: 'anna@company.com', type: EmployeeType.salesman, branchCode: 'BR002'),
//   ];
//
//   static List<Employee> getEmployees() {
//     return _employees;
//   }
//
//   static List<Employee> getEmployeesByBranch(String branchCode) {
//     return _employees.where((e) => e.branchCode == branchCode).toList();
//   }
//
//   static List<String> getBranchCodes() {
//     return _employees.map((e) => e.branchCode).toSet().toList();
//   }
//
//   static List<PerformanceData> getPerformanceData(String employeeId, FilterPeriod period) {
//     final random = Random();
//     final employee = _employees.firstWhere((e) => e.id == employeeId);
//     final data = <PerformanceData>[];
//
//     final startDate = period.startDate;
//     final endDate = DateTime.now();
//
//     for (var date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
//       Map<String, dynamic> metrics = {};
//
//       switch (employee.type) {
//         case EmployeeType.driver:
//           metrics = {
//             'deliveries': random.nextInt(20) + 5,
//             'car': employee.carAssigned,
//           };
//           break;
//         case EmployeeType.rep:
//           final quotesScanned = random.nextInt(15) + 5;
//           final conversions = (quotesScanned * (0.2 + random.nextDouble() * 0.3)).round();
//           final clientVisits = random.nextInt(10) + 3;
//           final deliveryVisits = (clientVisits * (0.3 + random.nextDouble() * 0.4)).round();
//           metrics = {
//             'quotesScanned': quotesScanned,
//             'conversions': conversions,
//             'clientVisits': clientVisits,
//             'deliveryVisits': deliveryVisits,
//           };
//           break;
//         case EmployeeType.salesman:
//           metrics = {
//             'quotes': random.nextInt(25) + 10,
//             'invoices': random.nextInt(15) + 5,
//             'calls': random.nextInt(50) + 20,
//           };
//           break;
//       }
//
//       data.add(PerformanceData(
//         employeeId: employeeId,
//         date: date,
//         metrics: metrics,
//       ));
//     }
//
//     return data;
//   }
//
//   static Map<String, double> getBranchSummary(String branchCode, FilterPeriod period) {
//     final branchEmployees = getEmployeesByBranch(branchCode);
//     double totalDeliveries = 0;
//     double totalQuotes = 0;
//     double totalConversions = 0;
//     double totalCalls = 0;
//
//     for (final employee in branchEmployees) {
//       final performanceData = getPerformanceData(employee.id, period);
//
//       for (final data in performanceData) {
//         switch (employee.type) {
//           case EmployeeType.driver:
//             totalDeliveries += (data.metrics['deliveries'] ?? 0).toDouble();
//             break;
//           case EmployeeType.rep:
//             totalQuotes += (data.metrics['quotesScanned'] ?? 0).toDouble();
//             totalConversions += (data.metrics['conversions'] ?? 0).toDouble();
//             break;
//           case EmployeeType.salesman:
//             totalQuotes += (data.metrics['quotes'] ?? 0).toDouble();
//             totalCalls += (data.metrics['calls'] ?? 0).toDouble();
//             break;
//         }
//       }
//     }
//
//     return {
//       'deliveries': totalDeliveries,
//       'quotes': totalQuotes,
//       'conversions': totalConversions,
//       'calls': totalCalls,
//     };
//   }
// }