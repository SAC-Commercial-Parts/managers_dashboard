import '../models/user.dart';

class AuthService {
  static User? _currentUser;

  // Mock login - in real app this would authenticate with backend
  static Future<User?> login(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock user data - in real app this would come from authentication API
    final mockUsers =
    {
      'manager1@company.com': User(
        id: '1',
        name: 'John Manager',
        email: 'manager1@company.com',
        branchCode: 'BR001',
        role: 'Branch Manager',
      ),
      'manager2@company.com': User(
        id: '2',
        name: 'Sarah Manager',
        email: 'manager2@company.com',
        branchCode: 'BR002',
        role: 'Branch Manager',
      ),
    };

    if (mockUsers.containsKey(email) && password == 'password123') {
      _currentUser = mockUsers[email];
      return _currentUser;
    }

    return null;
  }

  static User? get currentUser => _currentUser;

  static bool get isLoggedIn => _currentUser != null;

  static void logout() {
    _currentUser = null;
  }
}