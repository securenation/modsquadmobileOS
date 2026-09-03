import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:modsquad_meetings/auth/login_screen.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/layout/signed_in_shell.dart';
import 'package:modsquad_meetings/mission_control/mission_control_repository.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';
import 'package:modsquad_meetings/theme/app_theme.dart';

class ModSquadApp extends StatelessWidget {
  const ModSquadApp({
    super.key,
    required this.auth,
    required this.missionControl,
    required this.campaigns,
    required this.startups,
  });

  final AuthRepository auth;
  final MissionControlRepository missionControl;
  final CampaignsRepository campaigns;
  final StartupsRepository startups;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mod Squad Meetings',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AuthGate(
        auth: auth,
        missionControl: missionControl,
        campaigns: campaigns,
        startups: startups,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.auth,
    required this.missionControl,
    required this.campaigns,
    required this.startups,
  });

  final AuthRepository auth;
  final MissionControlRepository missionControl;
  final CampaignsRepository campaigns;
  final StartupsRepository startups;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (auth.isSignedIn) {
          return SignedInShell(
            auth: auth,
            missionControl: missionControl,
            campaigns: campaigns,
            startups: startups,
          );
        }
        return LoginScreen(auth: auth);
      },
    );
  }
}
