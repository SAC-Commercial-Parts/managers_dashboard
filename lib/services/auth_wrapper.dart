// lib/services/auth_wrapper.dart

import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // No longer strictly needed for AuthWrapper's core logic
import 'package:firebase_auth/firebase_auth.dart'; // <--- IMPORTANT: Import Firebase's User type

import '../views/login_view.dart';
import '../views/main_screen.dart';

/// A widget that handles authentication state and navigates accordingly using a StreamBuilder.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens directly to the FirebaseAuth's authentication state changes.
    // This stream emits a new User object (or null) whenever the user's sign-in state changes,
    // including the initial check when the app starts.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Direct stream from Firebase Auth
      builder: (context, snapshot) {
        // Step 1: Check the connection state of the stream.
        // During app startup, Firebase needs time to check cached credentials.
        // In this phase, connectionState will be ConnectionState.waiting.
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the auth state to resolve, show a loading indicator.
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // You can customize your loading spinner
            ),
          );
        } else if (snapshot.hasError) {
          // Step 2: Handle any errors that might occur during the stream's lifecycle.
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // Step 3: ConnectionState is active (or done), meaning Firebase has resolved the auth state.
          final User? user = snapshot.data; // Get the user object from the snapshot

          // If the user object is null, it means no user is currently logged in.
          if (user == null) {
            return const LoginView();
          } else {
            // If the user object is not null, a user is logged in.
            return const MainScreen();
          }
        }
      },
    );
  }
}