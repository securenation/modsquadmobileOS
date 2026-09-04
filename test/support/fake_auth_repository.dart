import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.onSignIn, SignedInProfile? profile}) : _profile = profile;

  Future<void> Function(String email, String password)? onSignIn;

  final _changes = Stream<Object?>.value(null);
  bool _signedIn = false;
  String? _email;
  SignedInProfile? _profile;
  int signOutCount = 0;

  @override
  Stream<Object?> get authStateChanges => _changes;

  @override
  String? get currentEmail => _email;

  @override
  bool get isSignedIn => _signedIn;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await onSignIn?.call(email, password);
    _signedIn = true;
    _email = email;
    _profile ??= SignedInProfile.fromEmail(email);
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    _email = null;
    _profile = null;
    signOutCount += 1;
  }

  @override
  Future<SignedInProfile> loadProfile() async {
    return _profile ?? SignedInProfile.fromEmail(_email ?? 'user@modsquad.vc');
  }
}
