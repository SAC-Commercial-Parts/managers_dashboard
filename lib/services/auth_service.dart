// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/loading_and_states.dart';

////////////////////////////////////////////////////////////////////////////
//                               AUTH SERVICE                             //
////////////////////////////////////////////////////////////////////////////
class AuthService
{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoadingAndStates _loader = LoadingAndStates();

  // Stream to listen to authentication state changes
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Method to get the currently logged-in Firebase User object
  User? get currentUser => _firebaseAuth.currentUser;


  Future<String?> getCurrentUserId() async {
    return _firebaseAuth.currentUser?.uid;
  }

  Future<bool> isCurrentUserAdmin() async
  {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('user_details').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('role') && data['role'] == 'branchmanager') {
            return true;
          }
        }
        return false;
      } catch (e) {
        _loader.showError('Error checking admin role: $e'); // <--- ADD THIS LINE FOR DEBUGGING INSTEAD (Optional)
        return false;
      }
    }
    return false;
  }
  ////////////////////////////////////////////////////////////////////////////
  //                             SIGN IN METHOD                             //
  ////////////////////////////////////////////////////////////////////////////
  Future<User?> signIn(String email, String password) async
  {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      _loader.showError("Error signing in: $e");
      return null;
    } catch (e) {
      _loader.showError("Error signing in: $e");
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                             SIGN OUT METHOD                            //
  ////////////////////////////////////////////////////////////////////////////
  Future<void> signOut() async
  {
    await _firebaseAuth.signOut();
  }

  ////////////////////////////////////////////////////////////////////////////
  //                           GET MANAGERS BRANCH                          //
  ////////////////////////////////////////////////////////////////////////////
  Future<String?> getUserBranch() async
  {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      _loader.showError("No user logged in to fetch branch.");
      return null;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('user_details').doc(user.uid).get();

      if (userDoc.exists) {
        // Assuming 'branch' is a field directly in the user's document
        return userDoc.get('branch');
      } else {
        _loader.showError("User details document not found.");
        return null;
      }
    } catch (e) {
      _loader.showError("Error fetching user branch: $e");
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  //                            GET MANAGERS ROLE                           //
  ////////////////////////////////////////////////////////////////////////////
  // FOR SIGN IN AUTHENTICATION
  Future<String?> getUserRole(String uid) async
  {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('user_details').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null && (userDoc.data() as Map<String, dynamic>).containsKey('role')) {
        return userDoc.get('role') as String?;
      } else {
        _loader.showError("User details document not found or 'role' field is missing.");
        return null;
      }
    } catch (e) {
      _loader.showError("Error fetching user role: $e");
      return null;
    }
  }

}