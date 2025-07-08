import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define a custom AppUser class to hold user data including custom claims
class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? branchCode; // Custom field for branch code from Firestore
  final String? role;       // Custom field for role from Firestore

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.branchCode,
    this.role,
  });
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Initialize Firestore

  // Static variable to hold the current logged-in AppUser
  static AppUser? _currentAppUser;

  // Getter for the current AppUser
  static AppUser? get currentAppUser => _currentAppUser;

  // Helper function to fetch user data from Firestore and check role
  static Future<AppUser?> _fetchUserAndCheckRole(User firebaseUser) async {
    try {
      // Get user document from 'users' collection using UID
      DocumentSnapshot userDoc = await _firestore.collection('user_details').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final userRole = data['role'] as String?;
        final userBranchCode = data['branch'] as String?;
        final userDisplayName = data['name'] as String?; // Assuming displayName might also be in Firestore

        // Check if the 'role' field exists and is 'branchmanager'
        if (userRole == 'branchmanager') {
          return AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: userDisplayName ?? firebaseUser.displayName, // Prefer Firestore displayName, fallback to Firebase Auth
            branchCode: userBranchCode,
            role: userRole,
          );
        } else {
          // If the user does not have the 'branchmanager' role, sign them out
          await _auth.signOut();
          _currentAppUser = null;
          throw FirebaseAuthException(
            code: 'permission-denied',
            message: 'Access denied. Only Branch Managers can log in.',
          );
        }
      } else {
        // User document does not exist in Firestore
        await _auth.signOut();
        _currentAppUser = null;
        throw FirebaseAuthException(
          code: 'user-data-missing',
          message: 'User data not found in Firestore. Access denied.',
        );
      }
    } catch (e) {
      // Re-throw FirebaseAuthException or wrap other errors
      if (e is FirebaseAuthException) {
        rethrow;
      }
      throw FirebaseAuthException(
        code: 'firestore-error',
        message: 'Failed to fetch user data from Firestore: ${e.toString()}',
      );
    }
  }

  // Stream for authentication state changes
  static Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentAppUser = null;
        return null;
      } else {
        // Fetch user data from Firestore and check role
        try {
          _currentAppUser = await _fetchUserAndCheckRole(firebaseUser);
          return _currentAppUser;
        } on FirebaseAuthException catch (e) {
          // Catch specific errors from _fetchUserAndCheckRole and re-throw
          rethrow;
        } catch (e) {
          // Catch any other unexpected errors during role check
          await _auth.signOut(); // Ensure user is signed out on unexpected error
          _currentAppUser = null;
          throw FirebaseAuthException(
            code: 'auth-state-error',
            message: 'Error checking user role during auth state change: ${e.toString()}',
          );
        }
      }
    });
  }

  static Future<AppUser?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Fetch user data from Firestore and check role after successful authentication
        _currentAppUser = await _fetchUserAndCheckRole(user);
        return _currentAppUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: 'invalid-credentials',
          message: 'Invalid email or password.',
        );
      } else if (e.code == 'permission-denied' || e.code == 'user-data-missing' || e.code == 'firestore-error') {
        // Re-throw custom errors from _fetchUserAndCheckRole
        rethrow;
      } else {
        // Generic error for other FirebaseAuthExceptions
        throw FirebaseAuthException(
          code: 'firebase-error',
          message: 'An unexpected Firebase authentication error occurred: ${e.message}',
        );
      }
    } catch (e) {
      // Handle any other unexpected errors
      throw Exception('An unexpected error occurred during login: $e');
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
    _currentAppUser = null; // Clear the stored user on logout
  }
}
