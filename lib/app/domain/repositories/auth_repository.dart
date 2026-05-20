import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> signIn({required String email, required String password});
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> updateProfile({String? name, String? phone, String? avatarUrl});
  Future<void> deleteAccount();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Stream<UserModel?> get authStateStream;
}
