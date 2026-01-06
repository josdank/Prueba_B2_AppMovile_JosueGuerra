import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/env.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/profile_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final SupabaseClient client;

  AuthRepositoryImpl({required this.remote, required this.client});

  @override
  Future<void> signInEmail(String email, String password) =>
      remote.signInEmail(email, password);

  @override
  Future<void> signOut() => remote.signOut();

  @override
  Future<void> signUpEmail(String email, String password) =>
      remote.signUpEmail(email, password);

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      remote.sendPasswordResetEmail(email);

  @override
  Future<Profile?> getMyProfile() => remote.getMyProfile();

  @override
  Future<void> upsertMyProfile(Profile profile) async {
    final model = ProfileModel(
      id: profile.id,
      fullName: profile.fullName,
      phone: profile.phone,
      role: profile.role,
    );
    await remote.upsertMyProfile(model);
  }

  // Google OAuth real -> idToken -> Supabase
  @override
  Future<void> signInWithGoogle() async {
    final webClientId = Env.googleWebClientId.trim();
    if (webClientId.isEmpty) {
      throw Exception('Falta GOOGLE_WEB_CLIENT_ID en el archivo .env');
    }

    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
      scopes: const ['email', 'profile', 'openid'],
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception(
        'No se pudo obtener idToken. Revisa SHA-1 (OAuth Android) y GOOGLE_WEB_CLIENT_ID.',
      );
    }

    await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }
}
