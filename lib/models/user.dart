class User {
  final String id;
  final String name;
  final String email;
  final String branchCode;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.branchCode,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      branchCode: json['branchCode'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'branchCode': branchCode,
      'role': role,
    };
  }
}