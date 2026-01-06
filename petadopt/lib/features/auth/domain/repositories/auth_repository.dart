import '../entities/profile.dart';

abstract class AuthRepository {
  Future<void> signUpEmail(String email, String password);
  Future<void> signInEmail(String email, String password);
  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<Profile?> getMyProfile();
  Future<void> upsertMyProfile(Profile profile);

  Future<void> signInWithGoogle();
}
