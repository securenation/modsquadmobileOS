class SignInFailure implements Exception {
  const SignInFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Stream<Object?> get authStateChanges;
  String? get currentEmail;
  bool get isSignedIn;

  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}
