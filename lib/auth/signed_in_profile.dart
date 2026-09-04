import 'package:modsquad_meetings/shared/json.dart';
import 'package:modsquad_meetings/shared/labels.dart';

class SignedInProfile {
  const SignedInProfile({
    required this.fullName,
    required this.email,
    required this.role,
    required this.orgName,
    this.memberId = '',
    this.orgId = '',
    this.userId = '',
  });

  final String fullName;
  final String email;
  final String role;
  final String orgName;
  final String memberId;
  final String orgId;
  final String userId;

  bool get isAdmin => role == 'mod_squad_admin';

  bool get canSeeStartups => isAdmin;

  String get roleLabel => labelFor(orgRoleLabels, role, humanize(role));

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final letters = parts.take(2).map((part) => part[0].toUpperCase());
    return letters.join();
  }

  factory SignedInProfile.fromEmail(
    String email, {
    String role = 'mod_squad_admin',
    String orgName = 'Mod Squad Capital',
  }) {
    return SignedInProfile(
      fullName: displayNameFromEmail(email),
      email: email,
      role: role,
      orgName: orgName,
    );
  }
}

String displayNameFromEmail(String email) {
  final local = email.split('@').first;
  final parts = local
      .split(RegExp(r'[._-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}');
  final name = parts.join(' ');
  return name.isEmpty ? email : name;
}
