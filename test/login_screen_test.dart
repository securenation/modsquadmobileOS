import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:modsquad_meetings/auth/login_screen.dart';
import 'package:modsquad_meetings/theme/app_theme.dart';

import 'support/fake_auth_repository.dart';

void main() {
  testWidgets('shows brand and sign-in fields', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));

    expect(find.text('Mod Squad Meetings'), findsOneWidget);
    expect(find.text('Sign in'), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('validates empty fields', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('rejects an invalid email', (tester) async {
    await tester.pumpWidget(_app(FakeAuthRepository()));

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('shows auth failure from the repository', (tester) async {
    final auth = FakeAuthRepository(
      onSignIn: (email, password) async {
        throw const SignInFailure('Incorrect email or password.');
      },
    );
    await tester.pumpWidget(_app(auth));

    await tester.enterText(find.byType(TextFormField).first, 'priya.natarajan@modsquad-demo.test');
    await tester.enterText(find.byType(TextFormField).last, 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('submits trimmed email and password', (tester) async {
    String? submittedEmail;
    String? submittedPassword;
    final auth = FakeAuthRepository(
      onSignIn: (email, password) async {
        submittedEmail = email;
        submittedPassword = password;
      },
    );
    await tester.pumpWidget(_app(auth));

    await tester.enterText(find.byType(TextFormField).first, '  priya.natarajan@modsquad-demo.test  ');
    await tester.enterText(find.byType(TextFormField).last, 'ModSquadDemo!2026');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(submittedEmail, 'priya.natarajan@modsquad-demo.test');
    expect(submittedPassword, 'ModSquadDemo!2026');
  });
}

Widget _app(AuthRepository auth) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: LoginScreen(auth: auth),
  );
}
