enum EmployeeType { driver, rep, salesman }
////////////////////////////////////////////////////////////////////////////
//                             EMPLOYEE MODEL                             //
////////////////////////////////////////////////////////////////////////////
class Employee {
  final String id;
  final String name;
  final String email;
  final EmployeeType type;
  final String branchCode;
  final String? carAssigned;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.branchCode,
    this.carAssigned,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: EmployeeType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
      ),
      branchCode: json['branchCode'],
      carAssigned: json['carAssigned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type.toString().split('.').last,
      'branchCode': branchCode,
      'carAssigned': carAssigned,
    };
  }
}