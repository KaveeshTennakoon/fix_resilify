import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:resilify/models/UserDTO.dart';
import 'package:resilify/services/hive_service.dart';
import 'package:resilify/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HiveService _hiveService = HiveService();
  final ApiService _apiService = ApiService();

  // Flag to track if auth state has been initialized
  bool _authStateInitialized = false;

  // User data
  User? _firebaseUser;
  String? _displayName;

  // Constructor - start listening to auth changes
  AuthService() {
    _initializeAuthState();
  }

  // Initialize the auth state
  Future<void> _initializeAuthState() async {
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      _loadUserData();
      _authStateInitialized = true;
      notifyListeners();
    });
  }

  // Load additional user data from Firestore if available
  Future<void> _loadUserData() async {
    if (_firebaseUser != null) {
      try {
        final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data.containsKey('firstName') && data.containsKey('lastName')) {
            _displayName = "${data['firstName']} ${data['lastName']}";
          } else {
            _displayName = _firebaseUser!.displayName;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error loading user data: $e');
        }
      }
    }
  }

  // Check if auth state is initialized
  bool get authStateInitialized => _authStateInitialized;

  // Get current user ID
  String? get currentUserId => _firebaseUser?.uid;

  // Get user email
  String? get userEmail => _firebaseUser?.email;

  // Get display name
  String? get displayName => _displayName ?? _firebaseUser?.displayName;

  // Check if user is logged in
  bool get isLoggedIn => _firebaseUser != null;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get cached token for backend authentication
  Future<String?> getIdToken() async {
    if (!isLoggedIn) return null;
    try {
      return await _firebaseUser?.getIdToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting ID token: $e');
      }
      return null;
    }
  }

  // Sync user with backend
  Future<void> syncUserWithBackendDirect(String userId, String firstName, String lastName) async {
    try {
      // Save to Firestore
      await _firestore.collection('users').doc(userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': userEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Also sync with your existing backend
      await _apiService.syncUserProfile(
        firstName: firstName,
        lastName: lastName,
        email: userEmail ?? '',
      );

      if (kDebugMode) {
        print("User synced with backend successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error syncing user with backend: $e");
      }
      // Continue even if backend sync fails - we'll retry later
    }
  }

  // Sync a game session to the backend
  Future<void> syncGameSessionToBackend(
      DateTime timePlayed,
      int duration,
      int points,
      String activityType
      ) async {
    try {
      await _apiService.saveGameSession(
        timePlayed: timePlayed,
        duration: duration,
        points: points,
        activityType: activityType,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error syncing game session to backend: $e");
      }
      rethrow;
    }
  }

  // Sign Up with Email & Password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required BuildContext context,
  }) async {
    try {
      // Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the new user
      final user = userCredential.user;
      if (user != null) {
        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update display name in Firebase Auth
        await user.updateDisplayName('$firstName $lastName');

        // Store user data in Hive for offline access
        UserDTO userDTO = UserDTO(
          id: user.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
        );
        await _hiveService.saveUser(user.uid, userDTO);

        // Sync with backend
        await syncUserWithBackendDirect(user.uid, firstName, lastName);

        // Update local state
        _displayName = '$firstName $lastName';
        notifyListeners();

        return userCredential;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = e.message ?? 'An error occurred during sign up.';
      }
      _showErrorMessage(context, errorMessage);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign up: $e');
      }
      _showErrorMessage(context, "Sign up failed: $e");
      return null;
    }
  }

  // Sign In with Email & Password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user
      final user = userCredential.user;
      if (user != null) {
        // Get user data from Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data.containsKey('firstName') && data.containsKey('lastName')) {
            _displayName = "${data['firstName']} ${data['lastName']}";

            // Store in Hive for offline access
            UserDTO userDTO = UserDTO(
              id: user.uid,
              email: email,
              firstName: data['firstName'],
              lastName: data['lastName'],
            );
            await _hiveService.saveUser(user.uid, userDTO);

            // Try to sync any local sessions with backend
            await _hiveService.syncLocalSessionsWithBackend(syncGameSessionToBackend);
          }
        }

        notifyListeners();
        return userCredential;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = e.message ?? 'An error occurred during sign in.';
      }
      _showErrorMessage(context, errorMessage);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign in: $e');
      }
      _showErrorMessage(context, "Sign in failed: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _displayName = null;
    notifyListeners();
  }

  // Reset Password
  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent to $email")),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(context, e.message ?? "Password reset failed");
    } catch (e) {
      _showErrorMessage(context, "Password reset failed: $e");
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    BuildContext? context,
  }) async {
    try {
      if (_firebaseUser != null) {
        // Update in Firestore
        await _firestore.collection('users').doc(_firebaseUser!.uid).update({
          'firstName': firstName,
          'lastName': lastName,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update display name in Firebase Auth
        await _firebaseUser!.updateDisplayName('$firstName $lastName');

        // Update local state
        _displayName = '$firstName $lastName';

        // Update in Hive
        await _hiveService.updateUser(
          _firebaseUser!.uid,
          firstName: firstName,
          lastName: lastName,
        );

        // Sync with backend
        await syncUserWithBackendDirect(_firebaseUser!.uid, firstName, lastName);

        notifyListeners();

        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully")),
          );
        }
      }
    } catch (e) {
      if (context != null) {
        _showErrorMessage(context, "Error updating profile: $e");
      }
    }
  }

  // Get current user as UserDTO
  UserDTO? getCurrentUserDTO() {
    if (_firebaseUser == null) return null;

    return UserDTO(
      id: _firebaseUser!.uid,
      email: _firebaseUser!.email ?? '',
      firstName: _displayName?.split(' ').first ?? '',
      lastName: _displayName?.split(' ').last ?? '',
      photoURL: _firebaseUser!.photoURL,
    );
  }

  // Show error message
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}