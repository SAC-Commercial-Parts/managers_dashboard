// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  // Stream to listen to authentication state changes
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Method to get the currently logged-in Firebase User object
  User? get currentUser => _firebaseAuth.currentUser;

  Future<String?> getCurrentUserId() async {
    return _firebaseAuth.currentUser?.uid;
  }
  // Method to sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors (e.g., wrong password, user not found)
      print("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Method to sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> getUserBranch() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      print("No user logged in to fetch branch.");
      return null;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('user_details').doc(user.uid).get();

      if (userDoc.exists) {
        // Assuming 'branch' is a field directly in the user's document
        return userDoc.get('branch');
      } else {
        print("User details document for ${user.uid} not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching user branch: $e");
      return null;
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('user_details').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('role')) {
        return userDoc.get('role') as String?;
      } else {
        print("User details document for $uid not found or 'role' field is missing.");
        return null;
      }
    } catch (e) {
      print("Error fetching user role for $uid: $e");
      return null;
    }
  }

}