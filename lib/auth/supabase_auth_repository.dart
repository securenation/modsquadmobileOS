import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/shared/json.dart';
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

  @override
  Future<SignedInProfile> loadProfile() async {
    final user = _client.auth.currentUser;
    final email = user?.email ?? '';
    if (user == null) {
      return SignedInProfile.fromEmail(email.isEmpty ? 'unknown@modsquad.vc' : email);
    }

    try {
      final membership = await _client
          .from('organization_members')
          .select('id, org_id, role, organizations(name)')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();
      final profile = await _client.from('profiles').select('full_name').eq('id', user.id).maybeSingle();

      final org = asMap(membership?['organizations']);
      final fullName = (profile?['full_name'] as String?)?.trim();
      final role = membership?['role'] as String?;
      final orgName = org?['name'] as String?;

      return SignedInProfile(
        fullName: (fullName != null && fullName.isNotEmpty) ? fullName : displayNameFromEmail(email),
        email: email,
        role: role ?? 'mod_squad_admin',
        orgName: (orgName != null && orgName.isNotEmpty) ? orgName : 'Mod Squad Capital',
        memberId: membership?['id'] as String? ?? '',
        orgId: membership?['org_id'] as String? ?? '',
        userId: user.id,
      );
    } catch (_) {
      return SignedInProfile.fromEmail(email.isEmpty ? 'unknown@modsquad.vc' : email);
    }
  }
}
