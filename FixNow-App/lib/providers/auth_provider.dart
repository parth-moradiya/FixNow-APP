import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../services/db_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserRole? selectedRole;
  bool isLoading = false;
  String? errorMessage;
  AppUser? currentUser;

  bool get isLoggedIn => currentUser != null;

  void selectRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _loadProfile(credential.user!.uid);
      errorMessage = null;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _friendlyError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final role = selectedRole ?? UserRole.customer;
      final user = AppUser(
        uid: uid,
        name: name,
        email: email.trim(),
        phone: phone,
        role: role,
      );
      await DbService.users.child(uid).set(user.toMap());
      currentUser = user;
      errorMessage = null;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _friendlyError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> _loadProfile(String uid) async {
    final snapshot = await DbService.users.child(uid).get();
    if (snapshot.exists) {
      currentUser = AppUser.fromMap(uid, snapshot.value as Map<dynamic, dynamic>);
      selectedRole = currentUser!.role;
    }
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final user = currentUser;
    if (user == null) return;
    await DbService.users.child(user.uid).update({'name': name, 'phone': phone});
    currentUser = AppUser(
      uid: user.uid,
      name: name,
      email: user.email,
      phone: phone,
      role: user.role,
      active: user.active,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
    selectedRole = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Enter a valid email address';
      default:
        return e.message ?? 'Something went wrong. Please try again';
    }
  }
}
