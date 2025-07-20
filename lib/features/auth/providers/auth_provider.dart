import 'dart:async';
import 'package:flutter/foundation.dart'; // <-- CORRECTED LINE
import 'package:firebase_auth/firebase_auth.dart';

// Defines the possible roles in the app
enum UserRole { worker, manager, owner, vet }

// Defines the authentication status
enum AuthStatus { unknown, authenticated, unauthenticated }

// This class now listens to the real Firebase Auth state
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<User?> _authStateSubscription;

  AuthStatus status = AuthStatus.unknown;
  User? user;
  UserRole _userRole = UserRole.owner;
  UserRole get userRole => _userRole;

  AuthProvider() {
    _authStateSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  // New method to initialize the listener
  void initialize() {
    if (_authStateSubscription != null) return;
    _authStateSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      status = AuthStatus.unauthenticated;
      user = null;
    } else {
      status = AuthStatus.authenticated;
      user = firebaseUser;
    }
    notifyListeners();
  }

  bool get isManagerOrHigher =>
      _userRole == UserRole.manager || _userRole == UserRole.owner;

  Future<void> signInWithRole(UserRole role) async {
    // Ensure we have an anonymous Firebase user session.
    // If the user is already signed in, this does nothing.
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    // Set the chosen role and notify the app to update.
    _userRole = role;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
