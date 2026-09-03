import 'package:modsquad_meetings/auth/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.onSignIn});

  Future<void> Function(String email, String password)? onSignIn;

  final _changes = Stream<Object?>.value(null);
  bool _signedIn = false;
  String? _email;

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
  }

  @override
  Future<void> signOut() async {
    _signedIn = false;
    _email = null;
  }
}
