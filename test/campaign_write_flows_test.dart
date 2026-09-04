import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_screen.dart';
import 'package:modsquad_meetings/theme/app_theme.dart';

import 'support/fake_campaigns_repository.dart';
import 'support/fake_startups_repository.dart';

const admin = SignedInProfile(
  fullName: 'Priya Natarajan',
  email: 'priya.natarajan@modsquad-demo.test',
  role: 'mod_squad_admin',
  orgName: 'Mod Squad Capital',
  memberId: 'mem1',
  orgId: 'org1',
  userId: 'user1',
);

void main() {
  testWidgets('admin can create a campaign', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeCampaignsRepository(campaigns: [sampleCampaign()], workspace: sampleWorkspace);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: CampaignsScreen(
          repository: repository,
          startups: FakeStartupsRepository(startups: const [sampleStartup]),
          profile: admin,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('New campaign'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Dante @ RSA');
    await tester.tap(find.text('Create campaign'));
    await tester.pumpAndSettle();

    expect(repository.campaigns.map((campaign) => campaign.name), contains('Dante @ RSA'));
    expect(find.text('Dante @ RSA'), findsWidgets);
  });

  testWidgets('records a meeting outcome', (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = FakeCampaignsRepository(campaigns: [sampleCampaign()], workspace: sampleWorkspace);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: CampaignsScreen(
          repository: repository,
          startups: FakeStartupsRepository(startups: const [sampleStartup]),
          profile: admin,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dante @ Black Hat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meetings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elena Vasquez'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Record outcome'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Select what this meeting resulted in'));
    await tester.tap(find.text('Select what this meeting resulted in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sales opportunity').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save outcome'));
    await tester.tap(find.text('Save outcome'));
    await tester.pumpAndSettle();

    expect(repository.recordedOutcomes, hasLength(1));
    expect(repository.recordedOutcomes.single.outcomeCategory, 'sales_opportunity');
  });
}
