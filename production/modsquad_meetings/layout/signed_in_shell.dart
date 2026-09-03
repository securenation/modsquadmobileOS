import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/campaigns_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          MissionControlScreen(auth: widget.auth, repository: widget.missionControl),
          CampaignsScreen(auth: widget.auth, repository: widget.campaigns),
          StartupsScreen(auth: widget.auth, repository: widget.startups),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Mission Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Startups',
          ),
        ],
      ),
    );
  }
}
