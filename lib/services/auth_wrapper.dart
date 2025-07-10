import 'package:branch_managers_app/views/login_view.dart';
import 'package:branch_managers_app/views/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';

class AuthWrapper extends StatelessWidget {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final AuthService authService;

  const AuthWrapper({
    super.key,
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error);
        }

        if (snapshot.hasData && snapshot.data != null) {
          final User user = snapshot.data!;

          // Get user document based on 'id' field matching Firebase UID
          return FutureBuilder<QuerySnapshot>(
            future: firebaseFirestore
                .collection('user_details')
                .where('id', isEqualTo: user.uid)
                .limit(1)
                .get(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> userQuerySnapshot) {
              if (userQuerySnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen(message: 'Checking User Details...');
              } else if (userQuerySnapshot.hasError) {
                return _buildErrorScreen(userQuerySnapshot.error);
              } else if (userQuerySnapshot.hasData && userQuerySnapshot.data!.docs.isNotEmpty) {
                final userData = userQuerySnapshot.data!.docs.first.data() as Map<String, dynamic>?;

                if (userData != null && userData['isApproved'] == true) {
                  return FutureBuilder<bool>(
                    future: authService.isCurrentUserAdmin(),
                    builder: (BuildContext context, AsyncSnapshot<bool> managerSnapshot) {
                      if (managerSnapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingScreen(message: 'Checking Manager Status...');
                      } else if (managerSnapshot.hasError) {
                        return _buildErrorScreen(managerSnapshot.error);
                      } else if (managerSnapshot.data == true) {
                        return const MainScreen();
                      } else {
                        return const LoginView();
                      }
                    },
                  );
                } else {
                  return _buildErrorScreen('error');
                }
              } else {
                return const LoginView(); // no user document found
              }
            },
          );
        } else {
          return const LoginView(); // not logged in
        }
      },
    );
  }

  Widget _buildLoadingScreen({String message = 'Loading...'}) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Hero(
                tag: 'logo',
                child: SizedBox(
                  height: 150.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
            const SizedBox(height: 16.0),
            Text(
              message,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object? error) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}


