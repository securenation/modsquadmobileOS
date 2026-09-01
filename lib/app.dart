import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:modsquad_meetings/auth/login_screen.dart';
import 'package:modsquad_meetings/home/signed_in_screen.dart';
import 'package:modsquad_meetings/theme/app_theme.dart';

class ModSquadApp extends StatelessWidget {
  const ModSquadApp({super.key, required this.auth});

  final AuthRepository auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mod Squad Meetings',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AuthGate(auth: auth),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.auth});

  final AuthRepository auth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (auth.isSignedIn) {
          return SignedInScreen(auth: auth);
        }
        return LoginScreen(auth: auth);
      },
    );
  }
}
