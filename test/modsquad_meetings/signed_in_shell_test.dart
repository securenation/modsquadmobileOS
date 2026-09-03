import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/layout/signed_in_shell.dart';
import 'package:modsquad_meetings/theme/app_theme.dart';

import 'support/fake_auth_repository.dart';
import 'support/fake_campaigns_repository.dart';
import 'support/fake_mission_control_repository.dart';
import 'support/fake_startups_repository.dart';

void main() {
  testWidgets('switches between Mission Control, Campaigns, and Startups', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: SignedInShell(
          auth: FakeAuthRepository(),
          missionControl: FakeMissionControlRepository(snapshot: sampleSnapshot()),
          campaigns: FakeCampaignsRepository(campaigns: [sampleCampaign()], workspace: sampleWorkspace),
          startups: FakeStartupsRepository(startups: const [sampleStartup]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Needs attention'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.campaign_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Las Vegas · goal: 40 meetings'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.apartment_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Identity for the enterprise.'), findsOneWidget);
    expect(find.text('https://dante.example'), findsOneWidget);
  });
}
