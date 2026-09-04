import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';

void main() {
  test('builds initials and role labels from membership', () {
    const profile = SignedInProfile(
      fullName: 'Priya Natarajan',
      email: 'priya.natarajan@modsquad-demo.test',
      role: 'mod_squad_admin',
      orgName: 'Mod Squad Capital',
    );

    expect(profile.initials, 'PN');
    expect(profile.roleLabel, 'Mod Squad Admin');
  });

  test('derives a display name from an email local part', () {
    final profile = SignedInProfile.fromEmail('alex.kim@modsquad.vc', role: 'dante_team_member');

    expect(profile.fullName, 'Alex Kim');
    expect(profile.initials, 'AK');
    expect(profile.roleLabel, 'Dante Team');
  });
}
