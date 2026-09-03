import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/campaigns/campaigns_screen.dart';
import 'package:modsquad_meetings/theme/app_theme.dart';

import 'support/fake_auth_repository.dart';
import 'support/fake_campaigns_repository.dart';

void main() {
  testWidgets('lists campaigns and opens overview', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: CampaignsScreen(
          auth: FakeAuthRepository(),
          repository: FakeCampaignsRepository(campaigns: [sampleCampaign()], workspace: sampleWorkspace),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Campaigns'), findsOneWidget);
    expect(find.text('Dante @ Black Hat'), findsOneWidget);
    expect(find.text('Dante Security'), findsOneWidget);
    expect(find.text('Las Vegas · goal: 40 meetings'), findsOneWidget);

    await tester.tap(find.text('Dante @ Black Hat'));
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Pipeline'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Event details'), findsOneWidget);
    expect(find.text('Black Hat USA'), findsOneWidget);
    expect(find.text('Aug 1, 2026'), findsOneWidget);
    expect(find.text('Target meeting goal'), findsOneWidget);
    expect(find.text('2 accounts'), findsOneWidget);
    expect(find.text('Focus on CISO intros.'), findsOneWidget);

    await tester.tap(find.text('Pipeline'));
    await tester.pumpAndSettle();
    expect(find.text('Elena Vasquez'), findsOneWidget);
    expect(find.text('Meridian Health · CISO · score 86'), findsOneWidget);

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    expect(find.text('Scheduling'), findsOneWidget);
    expect(find.text('Meetings'), findsOneWidget);

    await tester.tap(find.text('Results'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Opportunity report'), findsOneWidget);
    expect(find.text('Weighted pipeline'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no campaigns', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: CampaignsScreen(
          auth: FakeAuthRepository(),
          repository: FakeCampaignsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No campaigns yet'), findsOneWidget);
  });
}
