import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resilify/models/UserDTO.dart';
import 'package:resilify/models/user_main.dart';
import 'package:resilify/services/hive_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Make AuthService extend ChangeNotifier to work with Provider
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HiveService _hiveService = HiveService();

  // Flag to track if auth state has been initialized
  bool _authStateInitialized = false;

  // Constructor to listen for auth state changes
  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _authStateInitialized = true;
      notifyListeners();
    });
  }

  // Getter for auth state initialization
  bool get authStateInitialized => _authStateInitialized;

  // Getter to check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Get the current user from Firebase
  User? get currentUser => _auth.currentUser;

  // Get the current user's ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get the current user's ID token
  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;

        // Try to get user from Firestore
        final docSnapshot = await _firestore.collection('users').doc(uid).get();

        if (docSnapshot.exists) {
          // Save user to Hive for offline access
          final userData = docSnapshot.data()!;
          final user = UserMain(
            uid: uid,
            firstName: userData['firstName'] ?? '',
            lastName: userData['lastName'] ?? '',
            points: userData['points'] ?? 0,
            streak: userData['streak'] ?? 0,
          );

          await _hiveService.saveUser(user);
        }
      }

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      return null;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required BuildContext context,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;

        // Create user in Firestore
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'points': 0,
          'streak': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Create user in Hive
        final user = UserMain(
          uid: uid,
          firstName: firstName,
          lastName: lastName,
          points: 0,
          streak: 0,
        );

        await _hiveService.saveUser(user);
      }

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Reset password
  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required BuildContext context,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Update in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'firstName': firstName,
          'lastName': lastName,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update in Hive
        final userData = _hiveService.getUser(user.uid);
        if (userData != null) {
          userData.firstName = firstName;
          userData.lastName = lastName;
          await _hiveService.saveUser(userData);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );

        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  // Get current user as DTO
  UserDTO? getCurrentUserDTO() {
    final user = _auth.currentUser;

    if (user != null) {
      final userData = _hiveService.getUser(user.uid);

      if (userData != null) {
        return UserDTO(
          id: user.uid,
          email: user.email ?? '',
          firstName: userData.firstName,
          lastName: userData.lastName,
          photoURL: user.photoURL,
        );
      }
    }

    return null;
  }

  // Update password
  Future<void> updatePassword(String newPassword, BuildContext context) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await user.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'requires-recent-login':
          errorMessage = 'Please sign in again before changing your password.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}