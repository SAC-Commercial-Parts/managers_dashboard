import 'package:branch_managers_app/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

// lib/views/login_view.dart

// ... (existing imports and class definition)

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final user = await authService.signIn( // This could take time
        _emailController.text.trim(),
        _passwordController.text,
      );

      // --- CRITICAL CHECK ---
      // After an await, always check if the widget is still mounted before interacting with context or state
      if (!mounted) return;

      if (user != null) {
        // User successfully authenticated with Firebase.
        // Now, fetch their role from Firestore.
        final userRole = await authService.getUserRole(user.uid); // This could take time

        // --- CRITICAL CHECK AGAIN ---
        if (!mounted) return; // Check mounted status after the second await

        if (userRole == 'branchmanager') {
          // If the user has the 'branchmanager' role, navigate to MainScreen
          // Navigator.pushReplacement also implies widget disposal
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // If the role is not 'branchmanager', log out the user and show an error
          await authService.signOut(); // This also might be an async call

          // --- CRITICAL CHECK AFTER SIGNOUT ---
          if (!mounted) return; // Check mounted status after signOut as well

          setState(() {
            _errorMessage = 'Access denied: You do not have branch manager privileges.';
          });
        }
      } else {
        // This 'else' block might be redundant if signIn throws an exception
        // for invalid credentials, but it's good for clarity
        // if it returns null on failure without throwing.
        setState(() {
          _errorMessage = 'Invalid email or password.';
        });
      }
    } catch (e) {
      // --- CRITICAL CHECK IN CATCH BLOCK ---
      if (!mounted) return; // Ensure widget is still mounted before setting state due to error

      String message = 'Login failed. Please try again.';
      if (e is Exception) {
        // You might want to parse specific FirebaseAuthException error codes here
        if (e.toString().contains('user-not-found') || e.toString().contains('wrong-password')) {
          message = 'Invalid email or password.';
        } else {
          message = 'Login failed: ${e.toString()}'; // Generic error for other issues
        }
      }

      setState(() {
        _errorMessage = message;
      });
    } finally {
      // This finally block also needs to respect the mounted state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.business,
                        size: 64,
                        color: AppTheme.primaryRed,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Branch Manager',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor, // Use theme color
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color, // Use theme text color
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(56),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withAlpha(72)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


