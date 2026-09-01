import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  String? get currentEmail => _client.auth.currentUser?.email;

  @override
  bool get isSignedIn => _client.auth.currentSession != null;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException {
      throw const SignInFailure('Incorrect email or password.');
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
