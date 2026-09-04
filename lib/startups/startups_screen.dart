import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/layout/page_app_bar.dart';
import 'package:modsquad_meetings/shared/message_state.dart';
import 'package:modsquad_meetings/startups/new_startup_screen.dart';
import 'package:modsquad_meetings/startups/startup_detail_screen.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class StartupsScreen extends StatefulWidget {
  const StartupsScreen({
    super.key,
    required this.repository,
    this.profile,
  });

  final StartupsRepository repository;
  final SignedInProfile? profile;

  @override
  State<StartupsScreen> createState() => _StartupsScreenState();
}

class _StartupsScreenState extends State<StartupsScreen> {
  late Future<List<Startup>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.listStartups();
  }

  Future<void> _reload() async {
    final next = widget.repository.listStartups();
    setState(() {
      _future = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = widget.profile?.isAdmin == true;
    return Scaffold(
      appBar: PageAppBar(
        title: 'Startups',
        actions: [
          if (canCreate)
            IconButton(
              tooltip: 'New startup',
              onPressed: () async {
                final created = await Navigator.of(context).push<Startup>(
                  MaterialPageRoute(
                    builder: (context) => NewStartupScreen(repository: widget.repository, profile: widget.profile!),
                  ),
                );
                if (created != null) await _reload();
              },
              icon: const Icon(Icons.add, color: AppColors.cyan),
            ),
        ],
      ),
      body: FutureBuilder<List<Startup>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
          }
          if (snapshot.hasError) {
            return MessageState(
              title: 'Could not load startups',
              detail: snapshot.error.toString(),
              actionLabel: 'Try again',
              onAction: _reload,
            );
          }
          final startups = snapshot.data ?? const <Startup>[];
          if (startups.isEmpty) {
            return const MessageState(
              title: 'No startups yet',
              detail: "Add a startup profile on the web app to start a campaign for them.",
            );
          }
          return RefreshIndicator(
            color: AppColors.cyan,
            backgroundColor: AppColors.card,
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: startups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final startup = startups[index];
                return _StartupCard(
                  startup: startup,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => StartupDetailScreen(startup: startup),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StartupCard extends StatelessWidget {
  const _StartupCard({required this.startup, required this.onTap});

  final Startup startup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        startup.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (startup.isPlaceholderContent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'Placeholder',
                          style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  startup.shortDescription ?? 'No description yet',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 4),
                Text(
                  startup.website ?? 'No website on file',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
