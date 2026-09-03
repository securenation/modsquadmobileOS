import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/startups/startups_screen.dart';
import 'package:modsquad_meetings/theme/app_theme.dart';

import 'support/fake_auth_repository.dart';
import 'support/fake_startups_repository.dart';

void main() {
  testWidgets('lists startups and opens profile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: StartupsScreen(
          auth: FakeAuthRepository(),
          repository: FakeStartupsRepository(startups: const [sampleStartup]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Startups'), findsOneWidget);
    expect(find.text('Dante Security'), findsOneWidget);
    expect(find.text('Identity for the enterprise.'), findsOneWidget);

    await tester.tap(find.text('Dante Security'));
    await tester.pumpAndSettle();

    expect(find.text('Website'), findsOneWidget);
    expect(find.text('https://dante.example'), findsWidgets);
    expect(find.text('Demo URL'), findsOneWidget);
    expect(find.text('Elevator pitch'), findsOneWidget);
    expect(find.text('Stop identity attacks before they start.'), findsOneWidget);
    expect(find.text('Ideal customer profile'), findsOneWidget);
    expect(find.text('CISO, VP Engineering'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no startups', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: StartupsScreen(
          auth: FakeAuthRepository(),
          repository: FakeStartupsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No startups yet'), findsOneWidget);
  });
}
