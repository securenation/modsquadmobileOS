import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaign_detail_screen.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/new_campaign_screen.dart';
import 'package:modsquad_meetings/layout/page_app_bar.dart';
import 'package:modsquad_meetings/shared/campaign_status_chip.dart';
import 'package:modsquad_meetings/shared/message_state.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({
    super.key,
    required this.repository,
    this.startups,
    this.profile,
  });

  final CampaignsRepository repository;
  final StartupsRepository? startups;
  final SignedInProfile? profile;

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  late Future<List<Campaign>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.listCampaigns();
  }

  Future<void> _reload() async {
    final next = widget.repository.listCampaigns();
    setState(() {
      _future = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.profile?.isAdmin == true && widget.startups != null && widget.profile != null;
    return Scaffold(
      appBar: PageAppBar(
        title: 'Campaigns',
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'New campaign',
              onPressed: () async {
                final created = await Navigator.of(context).push<Campaign>(
                  MaterialPageRoute(
                    builder: (context) => NewCampaignScreen(
                      repository: widget.repository,
                      startups: widget.startups!,
                      profile: widget.profile!,
                    ),
                  ),
                );
                if (created != null) {
                  await _reload();
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => CampaignDetailScreen(
                        campaign: created,
                        repository: widget.repository,
                        profile: widget.profile,
                      ),
                    ),
                  );
                  await _reload();
                }
              },
              icon: const Icon(Icons.add, color: AppColors.cyan),
            ),
        ],
      ),
      body: FutureBuilder<List<Campaign>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
          }
          if (snapshot.hasError) {
            return MessageState(
              title: 'Could not load campaigns',
              detail: snapshot.error.toString(),
              actionLabel: 'Try again',
              onAction: _reload,
            );
          }
          final campaigns = snapshot.data ?? const <Campaign>[];
          if (campaigns.isEmpty) {
            return const MessageState(
              title: 'No campaigns yet',
              detail: 'No campaigns have been shared with your team yet.',
            );
          }
          return RefreshIndicator(
            color: AppColors.cyan,
            backgroundColor: AppColors.card,
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              itemCount: campaigns.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final campaign = campaigns[index];
                return _CampaignCard(
                  campaign: campaign,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => CampaignDetailScreen(
                          campaign: campaign,
                          repository: widget.repository,
                          profile: widget.profile,
                        ),
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

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.onTap});

  final Campaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = [
      campaign.eventCity ?? 'City TBD',
      if (campaign.targetMeetingGoal != null) 'goal: ${campaign.targetMeetingGoal} meetings',
    ].join(' · ');

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        campaign.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.25),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CampaignStatusChip(status: campaign.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  campaign.startupName ?? 'Startup',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(meta, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
