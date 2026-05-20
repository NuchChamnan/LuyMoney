import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../data/models/subscription_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return null;
    return _fetchUser(credential.user!.uid);
  }

  @override
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return null;

    await credential.user!.updateDisplayName(name);

    final user = UserModel(
      id: credential.user!.uid,
      name: name,
      email: email,
      phone: phone ?? '',
      avatarUrl: '',
      role: 'user',
      subscription: null,
      createdAt: DateTime.now(),
      biometricEnabled: false,
    );

    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toFirestore());

    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchUser(user.uid);
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

    await _firestore.collection('users').doc(uid).update(updates);

    if (name != null) {
      await _auth.currentUser!.updateDisplayName(name);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).delete();
    await _auth.currentUser!.delete();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Stream<UserModel?> get authStateStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _fetchUser(user.uid);
    });
  }

  Future<UserModel?> _fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    SubscriptionModel? subscription;
    final subDoc = await _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (subDoc.docs.isNotEmpty) {
      subscription = SubscriptionModel.fromFirestore(subDoc.docs.first);
    }

    return UserModel.fromFirestore(doc, subscription: subscription);
  }
}
