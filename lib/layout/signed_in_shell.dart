import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/campaigns_screen.dart';
import 'package:modsquad_meetings/layout/app_header_bar.dart';
import 'package:modsquad_meetings/mission_control/mission_control_repository.dart';
import 'package:modsquad_meetings/mission_control/mission_control_screen.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';
import 'package:modsquad_meetings/startups/startups_screen.dart';

class SignedInShell extends StatefulWidget {
  const SignedInShell({
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
  State<SignedInShell> createState() => _SignedInShellState();
}

class _SignedInShellState extends State<SignedInShell> {
  int _index = 0;
  late Future<SignedInProfile> _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.auth.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SignedInProfile>(
      future: _profile,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final showStartups = profile?.canSeeStartups ?? false;
        final pageCount = showStartups ? 3 : 2;
        final index = _index.clamp(0, pageCount - 1);

        return Scaffold(
          body: Column(
            children: [
              SafeArea(
                bottom: false,
                child: AppHeaderBar(
                  profile: profile,
                  onSignOut: widget.auth.signOut,
                ),
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: IndexedStack(
                    index: index,
                    children: [
                      MissionControlScreen(repository: widget.missionControl),
                      CampaignsScreen(
                        repository: widget.campaigns,
                        startups: widget.startups,
                        profile: profile,
                      ),
                      if (showStartups) StartupsScreen(repository: widget.startups, profile: profile),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (next) => setState(() => _index = next),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Mission Control',
              ),
              const NavigationDestination(
                icon: Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign),
                label: 'Campaigns',
              ),
              if (showStartups)
                const NavigationDestination(
                  icon: Icon(Icons.apartment_outlined),
                  selectedIcon: Icon(Icons.apartment),
                  label: 'Startups',
                ),
            ],
          ),
        );
      },
    );
  }
}
