import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../data/models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  Future<AuthService> init() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        currentUser.value = null;
      }
    });
    return this;
  }

  // Only require Firebase Auth — Firestore profile loads in background
  bool get isLoggedIn => _auth.currentUser != null;
  User? get firebaseUser => _auth.currentUser;

  bool get hasActiveSubscription {
    final sub = currentUser.value?.subscription;
    if (sub == null) return false;
    return sub.isActive && !sub.isExpired;
  }

  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      if (doc.exists) {
        currentUser.value = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      Get.log('Error loading user data: $e');
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw FirebaseAuthException(code: 'network-request-failed'),
    );
  }

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw FirebaseAuthException(code: 'network-request-failed'),
    );
    // Update display name first (fast, no Firestore needed)
    await credential.user!.updateDisplayName(name);
    // Write Firestore doc — don't block registration if it fails/hangs
    _firestore.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'biometricEnabled': false,
    }).timeout(const Duration(seconds: 10)).catchError((e) {
      Get.log('Firestore user doc write failed: $e');
    });
    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      Get.log('Error deleting user data: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _storage.erase();
    currentUser.value = null;
  }

  Future<void> updateUserProfile({String? name, String? phone, String? avatarUrl}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    await _firestore.collection('users').doc(uid).update(updates);
    await _loadUserData(uid);
  }

  Future<void> refreshUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _loadUserData(uid);
  }

  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
    });
  }
}
