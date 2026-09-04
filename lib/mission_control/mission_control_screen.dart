import 'package:flutter/material.dart';
import 'package:modsquad_meetings/layout/page_app_bar.dart';
import 'package:modsquad_meetings/mission_control/mission_control_repository.dart';
import 'package:modsquad_meetings/mission_control/models.dart';
import 'package:modsquad_meetings/shared/campaign_status_chip.dart';
import 'package:modsquad_meetings/shared/message_state.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class MissionControlScreen extends StatefulWidget {
  const MissionControlScreen({
    super.key,
    required this.repository,
  });

  final MissionControlRepository repository;

  @override
  State<MissionControlScreen> createState() => _MissionControlScreenState();
}

class _MissionControlScreenState extends State<MissionControlScreen> {
  late Future<MissionControlSnapshot?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.load();
  }

  Future<void> _reload() async {
    final next = widget.repository.load();
    setState(() {
      _future = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(title: 'Mission Control'),
      body: FutureBuilder<MissionControlSnapshot?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
          }
          if (snapshot.hasError) {
            return MessageState(
              title: 'Could not load Mission Control',
              detail: snapshot.error.toString(),
              actionLabel: 'Try again',
              onAction: _reload,
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return const MessageState(
              title: 'No campaigns yet',
              detail: 'Create a campaign on the web app to start bringing in targets, introductions, and meetings.',
            );
          }
          return RefreshIndicator(
            color: AppColors.cyan,
            backgroundColor: AppColors.card,
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                _CampaignHeader(data: data),
                const SizedBox(height: 16),
                _KpiGrid(data: data),
                const SizedBox(height: 20),
                _NeedsAttention(actions: data.nextBestActions),
                const SizedBox(height: 20),
                _FunnelCard(funnel: data.funnel),
                const SizedBox(height: 20),
                _ActivityCard(events: data.recentActivity),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CampaignHeader extends StatelessWidget {
  const _CampaignHeader({required this.data});

  final MissionControlSnapshot data;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (data.startupName != null && data.startupName!.isNotEmpty) data.startupName!,
      if (data.eventCity != null && data.eventCity!.isNotEmpty) data.eventCity!,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                data.campaignName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2),
              ),
            ),
            const SizedBox(width: 8),
            CampaignStatusChip(status: data.campaignStatus),
          ],
        ),
        if (parts.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(parts.join(' · '), style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
        if (!data.datesConfirmed) ...[
          const SizedBox(height: 4),
          const Text(
            'Dates are placeholders, not yet confirmed',
            style: TextStyle(color: AppColors.warning, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.data});

  final MissionControlSnapshot data;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(
        label: 'Countdown',
        value: data.daysUntilStart == null ? 'TBD' : '${data.daysUntilStart}d',
      ),
      _KpiCard(
        label: 'Meetings today',
        value: '${data.meetings.today}',
        valueColor: AppColors.cyan,
      ),
      _KpiCard(
        label: 'Confirmed',
        value: '${data.meetings.confirmed}',
        valueColor: AppColors.success,
      ),
      _KpiCard(
        label: 'Opportunities',
        value: '${data.opportunitiesCreated}',
        valueColor: AppColors.success,
      ),
      _KpiCard(
        label: 'Qualified targets',
        value: '${data.targets.qualified}',
      ),
      _KpiCard(
        label: 'High priority',
        value: '${data.targets.highPriority}',
      ),
      _KpiCard(
        label: 'Meeting goal',
        value: data.targetGoal?.toString() ?? 'Not set',
      ),
      _KpiCard(
        label: 'Missing outcome',
        value: '${data.meetings.completedMissingOutcome}',
        valueColor: data.meetings.completedMissingOutcome > 0 ? AppColors.destructive : null,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < cards.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < cards.length ? 8 : 0),
            child: Row(
              children: [
                Expanded(child: cards[i]),
                const SizedBox(width: 8),
                Expanded(child: cards[i + 1]),
              ],
            ),
          ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.foreground,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeedsAttention extends StatelessWidget {
  const _NeedsAttention({required this.actions});

  final List<NextBestAction> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Needs attention', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (actions.isEmpty)
              const Text(
                'Nothing urgent right now.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              )
            else
              ...actions.map(
                (action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AttentionRow(action: action),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.action});

  final NextBestAction action;

  Color get _barColor {
    final label = action.label.toLowerCase();
    if (label.contains('outcome') || label.contains('overdue')) return AppColors.destructive;
    if (label.contains('intro') || label.contains('follow up') || label.contains('nudge')) {
      return AppColors.warning;
    }
    if (label.contains('assign') || label.contains('owner')) return AppColors.caution;
    return AppColors.cyan;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 36,
              decoration: BoxDecoration(color: _barColor, borderRadius: BorderRadius.circular(99)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.25)),
                  const SizedBox(height: 3),
                  Text(action.detail, style: const TextStyle(color: AppColors.muted, fontSize: 11, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunnelCard extends StatelessWidget {
  const _FunnelCard({required this.funnel});

  final FunnelStats funnel;

  @override
  Widget build(BuildContext context) {
    final stages = [
      ('Qualified', funnel.qualifiedTargets),
      ('Intros / outreach', funnel.introductionsOrOutreach),
      ('Confirmed', funnel.meetingsConfirmed),
      ('Completed', funnel.meetingsCompleted),
      ('Opportunities', funnel.opportunities),
    ];
    final max = stages.fold<int>(1, (current, stage) => stage.$2 > current ? stage.$2 : current);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Campaign funnel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...stages.map(
              (stage) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 112,
                      child: Text(
                        stage.$1,
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = stage.$2 == 0
                              ? 0.0
                              : (constraints.maxWidth * (stage.$2 / max)).clamp(4.0, constraints.maxWidth);
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 7,
                              width: width,
                              decoration: BoxDecoration(
                                color: AppColors.cyan,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${stage.$2}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12, fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.events});

  final List<ActivityEvent> events;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Text('No activity recorded yet.', style: TextStyle(color: AppColors.muted, fontSize: 13))
            else
              ...events.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.summary, style: const TextStyle(fontSize: 13, height: 1.3)),
                      const SizedBox(height: 3),
                      Text(_formatTimestamp(event.createdAt), style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatTimestamp(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}
