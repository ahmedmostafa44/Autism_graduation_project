import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autism_app/features/auth/data/models/user_model.dart';
import 'package:autism_app/core/config/app_config.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Mock helper ──────────────────────────────────────────────────────────
// mostafaa434@yahoo.com
//6112003
  UserModel get _mockUser => UserModel(
        uid: 'mock-123',
        email: 'parent@example.com',
        parentName: 'Development User',
        childName: 'Buddy',
        childAge: 6,
        createdAt: DateTime.now(),
      );

  // ── Stream of auth state changes ─────────────────────────────────────────

  Stream<User?> get authStateChanges {
    if (AppConfig.useMockAuth) {
      return Stream.value(null);
    }
    return _auth.authStateChanges();
  }

  User? get currentUser {
    if (AppConfig.useMockAuth) return null;
    return _auth.currentUser;
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String parentName,
    required String childName,
    required int childAge,
  }) async {
    if (AppConfig.useMockAuth) {
      await Future.delayed(const Duration(seconds: 1));
      return UserModel(
        uid: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        parentName: parentName,
        childName: childName,
        childAge: childAge,
        createdAt: DateTime.now(),
      );
    }
    // 1. Create Firebase Auth user
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user!;

    // 2. Update display name
    await user.updateDisplayName(parentName);

    // 3. Write profile to Firestore
    final model = UserModel(
      uid: user.uid,
      email: email.trim(),
      parentName: parentName,
      childName: childName,
      childAge: childAge,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(model.toFirestore())
        .timeout(const Duration(seconds: 10));

    return model;
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (AppConfig.useMockAuth) {
      await Future.delayed(const Duration(seconds: 1));
      if (email == 'error@example.com') {
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'User not found in Mock mode');
      }
      return _mockUser.copyWith(email: email);
    }
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      print('Firebase Auth Sign-In Successful: ${user.uid}');

      try {
        return await _fetchProfile(user.uid);
      } catch (e) {
        print(
            'Firestore Profile missing for ${user.uid}. Creating recovery profile.');
        // Auto-recovery: Create a basic profile if Firestore is empty but Auth is valid
        final model = UserModel(
          uid: user.uid,
          email: user.email ?? email,
          parentName: user.displayName ?? 'Parent',
          childName: 'Buddy',
          childAge: 5,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(model.toFirestore())
            .timeout(const Duration(seconds: 10));
        return model;
      }
    } catch (e) {
      print('Sign-In Error in Repository: $e');
      rethrow;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    if (AppConfig.useMockAuth) return;
    return _auth.signOut();
  }

  // ── Reset password ────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    if (AppConfig.useMockAuth) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Fetch Firestore profile ───────────────────────────────────────────────

  Future<UserModel> _fetchProfile(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 10));
    if (!doc.exists) throw Exception('User profile not found in Firestore');
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel?> fetchCurrentProfile() async {
    if (AppConfig.useMockAuth) return null;
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchProfile(user.uid);
    } catch (_) {
      return null;
    }
  }

  // ── Update last active ────────────────────────────────────────────────────

  Future<void> touchLastActive() async {
    if (AppConfig.useMockAuth) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }
}
