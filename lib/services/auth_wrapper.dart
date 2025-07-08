import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For FirebaseAuthException
import '../services/auth_service.dart'; // Corrected import path for AuthService
import '../views/login_view.dart';
import '../views/main_screen.dart';

/// A widget that listens to the authentication state and renders either
/// the LoginView or the MainScreen based on whether a user is logged in
/// and has the 'branchmanager' role.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to the authStateChanges stream from AuthService.
    // This stream emits an AppUser? whenever the authentication state changes.
    return StreamBuilder<AppUser?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // Handle potential errors from the authentication stream.
        // This is particularly important for 'permission-denied' errors
        // thrown by AuthService if a user logs in but doesn't have the role.
        if (snapshot.hasError) {
          // If the error is a FirebaseAuthException and it's 'permission-denied',
          // it means the user was logged out due to an incorrect role.
          // We can display a specific message or just let the LoginView handle it.
          if (snapshot.error is FirebaseAuthException &&
              (snapshot.error as FirebaseAuthException).code == 'permission-denied') {
            // Optionally show a snackbar or dialog here to inform the user
            // before navigating to LoginView. For simplicity, we'll just
            // navigate to LoginView, and the LoginView's error handling
            // can pick up the message if it's set in a global state or passed.
            // For now, we'll just ensure it goes to LoginView.
            return const LoginView();
          }
          // For any other type of error, you might want to show a generic error screen
          // or a message.
          return Scaffold(
            body: Center(
              child: Text('An unexpected error occurred: ${snapshot.error.toString()}'),
            ),
          );
        }

        // Show a loading indicator while the authentication state is being determined.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Get the AppUser from the snapshot.
        final AppUser? user = snapshot.data;

        // If 'user' is null, it means no user is logged in or the logged-in user
        // does not have the 'branchmanager' role (as handled by AuthService.authStateChanges).
        // In this case, show the LoginView.
        if (user == null) {
          return const LoginView();
        } else {
          // If 'user' is not null, it means a user is logged in AND has the
          // 'branchmanager' role. Show the MainScreen.
          return const MainScreen();
        }
      },
    );
  }
}
