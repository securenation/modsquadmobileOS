import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
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

    final auth = FakeAuthRepository(
      profile: const SignedInProfile(
        fullName: 'Priya Natarajan',
        email: 'priya.natarajan@modsquad-demo.test',
        role: 'mod_squad_admin',
        orgName: 'Mod Squad Capital',
      ),
    );
    await auth.signIn(email: 'priya.natarajan@modsquad-demo.test', password: 'x');

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: SignedInShell(
          auth: auth,
          missionControl: FakeMissionControlRepository(snapshot: sampleSnapshot()),
          campaigns: FakeCampaignsRepository(campaigns: [sampleCampaign()], workspace: sampleWorkspace),
          startups: FakeStartupsRepository(startups: const [sampleStartup]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mod Squad Capital'), findsOneWidget);
    expect(find.text('Priya Natarajan'), findsOneWidget);
    expect(find.text('PN'), findsOneWidget);
    expect(find.text('Mod Squad Admin'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.campaign_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Las Vegas · goal: 40 meetings'), findsOneWidget);
    expect(find.text('Priya Natarajan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.apartment_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Identity for the enterprise.'), findsOneWidget);
    expect(find.text('https://dante.example'), findsOneWidget);

    await tester.tap(find.byTooltip('Sign out'));
    expect(auth.signOutCount, 1);
  });

  testWidgets('hides Startups from Dante members', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = FakeAuthRepository(
      profile: const SignedInProfile(
        fullName: 'Alex Kim',
        email: 'alex.kim@dante.test',
        role: 'dante_team_member',
        orgName: 'Mod Squad Capital',
      ),
    );
    await auth.signIn(email: 'alex.kim@dante.test', password: 'x');

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: SignedInShell(
          auth: auth,
          missionControl: FakeMissionControlRepository(snapshot: sampleSnapshot()),
          campaigns: FakeCampaignsRepository(campaigns: [sampleCampaign()], workspace: sampleWorkspace),
          startups: FakeStartupsRepository(startups: const [sampleStartup]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dante Team'), findsOneWidget);
    expect(find.text('Startups'), findsNothing);
    expect(find.byIcon(Icons.apartment_outlined), findsNothing);
    expect(find.text('Campaigns'), findsOneWidget);
  });
}
