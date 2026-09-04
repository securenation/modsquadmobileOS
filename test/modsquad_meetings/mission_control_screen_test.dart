import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/mission_control/mission_control_screen.dart';
import 'package:modsquad_meetings/theme/app_theme.dart';

import 'support/fake_mission_control_repository.dart';

void main() {
  testWidgets('shows campaign snapshot, attention, and funnel', (tester) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(FakeMissionControlRepository(snapshot: sampleSnapshot())));
    await tester.pumpAndSettle();

    expect(find.text('Mission Control'), findsOneWidget);
    expect(find.text('Dante @ Black Hat'), findsOneWidget);
    expect(find.text('Dante Security · Las Vegas'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('12d'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Assign an owner to 3 unassigned targets'), findsOneWidget);
    expect(find.text('Campaign funnel'), findsOneWidget);
    expect(find.text('Intro request sent to R. Patel'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no campaigns', (tester) async {
    await tester.pumpWidget(_app(FakeMissionControlRepository()));
    await tester.pumpAndSettle();

    expect(find.text('No campaigns yet'), findsOneWidget);
  });

  testWidgets('shows an error and retries', (tester) async {
    final repo = FakeMissionControlRepository(error: Exception('network down'));
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Could not load Mission Control'), findsOneWidget);

    repo
      ..error = null
      ..snapshot = sampleSnapshot();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Dante @ Black Hat'), findsOneWidget);
    expect(repo.loadCount, 2);
  });
}

Widget _app(FakeMissionControlRepository repository) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: MissionControlScreen(repository: repository),
  );
}
