enum EmployeeType { driver, rep, salesman }

class Employee {
  final String id; // This will be the Firestore document ID
  final String name;
  final String email;
  final EmployeeType type; // Corresponds to 'role' in Firestore
  final String? phoneNumber; // Added from Firestore mock data
  final DateTime? hireDate; // Added from Firestore mock data
  final String? branchCode; // Not directly in employee doc, but useful for context
  final String? carAssigned; // Kept as nullable, not in mock data

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.phoneNumber, // Made nullable
    this.hireDate,    // Made nullable
    this.branchCode,  // Made nullable
    this.carAssigned, // Made nullable
  });

  factory Employee.fromFirestore(String id, Map<String, dynamic> data) {
    // Helper to parse string role to enum
    EmployeeType parseEmployeeType(String roleString) {
      switch (roleString.toLowerCase()) {
        case 'driver':
          return EmployeeType.driver;
        case 'sales rep': // Note: 'Sales Rep' in mock data, 'rep' in enum
          return EmployeeType.rep;
        case 'salesman':
          return EmployeeType.salesman;
        default:
          return EmployeeType.salesman; // Default or throw error
      }
    }

    return Employee(
      id: id, // Use the Firestore document ID
      name: data['name'] as String,
      email: data['email'] as String,
      type: parseEmployeeType(data['role'] as String), // Map 'role' from Firestore to 'type' enum
      phoneNumber: data['phoneNumber'] as String?,
      hireDate: data['hireDate'] != null ? DateTime.parse(data['hireDate'] as String) : null,
      branchCode: data['branchCode'] as String?, // Assuming branchCode could be passed from service or derived
      carAssigned: data['carAssigned'] as String?,
    );
  }

  // toJson is typically used for sending data TO Firestore.
  // This version reflects the structure of the mock data you provided.
  Map<String, dynamic> toFirestore() {
    // Helper to convert enum type to string role for Firestore
    String employeeTypeToString(EmployeeType type) {
      switch (type) {
        case EmployeeType.driver:
          return 'Driver';
        case EmployeeType.rep:
          return 'Sales Rep';
        case EmployeeType.salesman:
          return 'Salesman';
      }
    }

    return {
      'name': name,
      'email': email,
      'role': employeeTypeToString(type), // Map 'type' enum to 'role' string for Firestore
      'phoneNumber': phoneNumber,
      'hireDate': hireDate?.toIso8601String().substring(0, 10), // Store as YYYY-MM-DD string
      // 'branchCode' is part of the document path, not usually a field within the employee doc itself
      // 'carAssigned' is not in the mock data, so it might not be needed in toFirestore if not used.
    };
  }
}
