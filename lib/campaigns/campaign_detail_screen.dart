import 'package:flutter/material.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/reports.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';
import 'package:modsquad_meetings/shared/campaign_status_chip.dart';
import 'package:modsquad_meetings/shared/entity_ui.dart';
import 'package:modsquad_meetings/shared/format.dart';
import 'package:modsquad_meetings/shared/json.dart';
import 'package:modsquad_meetings/shared/labels.dart';
import 'package:modsquad_meetings/shared/message_state.dart';
import 'package:modsquad_meetings/shared/status_chip.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class CampaignDetailScreen extends StatefulWidget {
  const CampaignDetailScreen({
    super.key,
    required this.campaign,
    required this.repository,
  });

  final Campaign campaign;
  final CampaignsRepository repository;

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  late Future<CampaignWorkspace> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.loadWorkspace(widget.campaign.id);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.foreground,
          surfaceTintColor: Colors.transparent,
          title: Text(widget.campaign.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.cyan,
            labelColor: AppColors.cyan,
            unselectedLabelColor: AppColors.muted,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Pipeline'),
              Tab(text: 'Calendar'),
              Tab(text: 'Results'),
            ],
          ),
        ),
        body: FutureBuilder<CampaignWorkspace>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
            }
            if (snapshot.hasError) {
              return MessageState(
                title: 'Could not load campaign',
                detail: snapshot.error.toString(),
                actionLabel: 'Try again',
                onAction: () {
                  final next = widget.repository.loadWorkspace(widget.campaign.id);
                  setState(() {
                    _future = next;
                  });
                },
              );
            }
            final workspace = snapshot.data ?? emptyWorkspace;
            return TabBarView(
              children: [
                _OverviewTab(campaign: widget.campaign),
                _PipelineTab(workspace: workspace),
                _CalendarTab(workspace: workspace),
                _ResultsTab(workspace: workspace),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(campaign.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2)),
            ),
            const SizedBox(width: 8),
            CampaignStatusChip(status: campaign.status),
          ],
        ),
        const SizedBox(height: 6),
        Text(campaign.startupName ?? 'Startup', style: const TextStyle(color: AppColors.muted, fontSize: 14)),
        const SizedBox(height: 20),
        _Card(title: 'Event details', children: [
          _Field(label: 'Event name', value: campaign.eventName ?? 'Not set'),
          _Field(label: 'City', value: campaign.eventCity ?? 'Not set'),
          _Field(label: 'Venue', value: campaign.eventVenue ?? 'Not set'),
          _Field(label: 'Timezone', value: campaign.timezone),
          _Field(label: 'Start date', value: formatDate(campaign.startDate)),
          _Field(label: 'End date', value: formatDate(campaign.endDate)),
          if (!campaign.datesConfirmed)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Dates and venue are placeholders until confirmed — do not treat as verified event facts.',
                style: TextStyle(color: AppColors.warning, fontSize: 12, height: 1.35),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        _Card(title: 'Campaign configuration', children: [
          _Field(label: 'Startup', value: campaign.startupName ?? 'Unknown'),
          _Field(label: 'Target meeting goal', value: campaign.targetMeetingGoal?.toString() ?? 'Not set'),
          _Field(
            label: 'Target meeting types',
            value: campaign.targetMeetingTypes.isEmpty
                ? 'Not set'
                : campaign.targetMeetingTypes.map(humanize).join(', '),
          ),
          _Field(
            label: 'Target account list',
            value: campaign.targetAccountList.isEmpty ? 'Not set' : '${campaign.targetAccountList.length} accounts',
          ),
          if (campaign.notes != null && campaign.notes!.isNotEmpty) _Field(label: 'Notes', value: campaign.notes!),
        ]),
      ],
    );
  }
}

class _PipelineTab extends StatelessWidget {
  const _PipelineTab({required this.workspace});

  final CampaignWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.cyan,
            labelColor: AppColors.cyan,
            unselectedLabelColor: AppColors.muted,
            tabs: [
              Tab(text: 'Targets'),
              Tab(text: 'Companies'),
              Tab(text: 'Intros'),
              Tab(text: 'Outreach'),
              Tab(text: 'Scoring'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ListPane(
                  empty: 'No targets in this campaign yet.',
                  children: [
                    for (final target in workspace.targets)
                      EntityRow(
                        title: target.fullName,
                        subtitle: [
                          if (target.companyName != null) target.companyName!,
                          if (target.jobTitle != null) target.jobTitle!,
                          if (target.score != null) 'score ${target.score}',
                        ].join(' · '),
                        trailing: StatusChip(label: labelFor(targetStatusLabels, target.status)),
                        onTap: () => _open(context, target.fullName, [
                          ('Status', labelFor(targetStatusLabels, target.status)),
                          ('Score', target.score?.toString() ?? 'Unscored'),
                          ('Band', labelFor(scoreCategoryLabels, target.scoreCategory, 'Unscored')),
                          ('Company', target.companyName ?? 'Not set'),
                          ('Title', target.jobTitle ?? 'Not set'),
                          ('Email', target.email ?? 'Not set'),
                          ('Phone', target.phone ?? 'Not set'),
                          ('LinkedIn', target.linkedinUrl ?? 'Not set'),
                          ('City', target.city ?? 'Not set'),
                          ('Do not contact', target.doNotContact ? 'Yes' : 'No'),
                          ('Why this score', target.scoreExplanation ?? 'Not set'),
                          ('Tags', target.tags.isEmpty ? 'None' : target.tags.join(', ')),
                        ]),
                      ),
                  ],
                ),
                _ListPane(
                  empty: 'No companies linked to campaign targets yet.',
                  children: [
                    for (final company in workspace.companies)
                      EntityRow(
                        title: company.name,
                        subtitle: [
                          company.domain ?? 'No domain',
                          '${company.targetCount} target${company.targetCount == 1 ? '' : 's'}',
                        ].join(' · '),
                        onTap: () => _open(context, company.name, [
                          ('Domain', company.domain ?? 'Not set'),
                          ('Targets', '${company.targetCount}'),
                          ('Tags', company.tags.isEmpty ? 'None' : company.tags.join(', ')),
                        ]),
                      ),
                  ],
                ),
                _ListPane(
                  empty: 'No introduction requests yet.',
                  children: [
                    for (final intro in workspace.introductions)
                      EntityRow(
                        title: intro.targetPersonName,
                        subtitle: [
                          if (intro.companyName != null) intro.companyName!,
                          'via ${intro.introducerName}',
                        ].join(' · '),
                        trailing: StatusChip(label: labelFor(introductionStatusLabels, intro.status)),
                        onTap: () => _open(context, intro.targetPersonName, [
                          ('Status', labelFor(introductionStatusLabels, intro.status)),
                          ('Company', intro.companyName ?? 'Not set'),
                          ('Introducer', intro.introducerName),
                          ('Reason', intro.reason ?? 'Not set'),
                          ('Sent', formatDate(intro.sentAt)),
                          ('Advisor note', intro.advisorNote ?? 'None'),
                        ]),
                      ),
                  ],
                ),
                _ListPane(
                  empty: 'No outreach logged yet.',
                  children: [
                    for (final item in workspace.outreach)
                      EntityRow(
                        title: item.targetPersonName,
                        subtitle: [
                          humanize(item.channel),
                          if (item.subject != null) item.subject!,
                        ].join(' · '),
                        trailing: StatusChip(label: labelFor(outreachStatusLabels, item.status)),
                        onTap: () => _open(context, item.targetPersonName, [
                          ('Channel', humanize(item.channel)),
                          ('Status', labelFor(outreachStatusLabels, item.status)),
                          ('Company', item.companyName ?? 'Not set'),
                          ('Subject', item.subject ?? 'Not set'),
                          ('Content', item.content ?? 'Not set'),
                          ('Follow-up date', formatDate(item.followUpDate)),
                        ]),
                      ),
                  ],
                ),
                _ListPane(
                  empty: 'No scoring rules visible for this campaign.',
                  children: [
                    for (final rule in workspace.scoringRules)
                      EntityRow(
                        title: humanize(rule.category),
                        subtitle: 'Weight ${rule.weight}',
                        trailing: StatusChip(
                          label: rule.isActive ? 'Active' : 'Inactive',
                          emphasis: rule.isActive ? ChipEmphasis.success : ChipEmphasis.neutral,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({required this.workspace});

  final CampaignWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.cyan,
            labelColor: AppColors.cyan,
            unselectedLabelColor: AppColors.muted,
            tabs: [Tab(text: 'Scheduling'), Tab(text: 'Meetings')],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ListPane(
                  empty: 'No availability windows yet.',
                  children: [
                    for (final window in workspace.windows)
                      EntityRow(
                        title: '${formatDate(window.windowDate)} · ${window.startTime}–${window.endTime}',
                        subtitle: [
                          window.timezone,
                          if (window.location != null) window.location!,
                          if (window.memberName != null) window.memberName!,
                          'cap ${window.capacity}',
                        ].join(' · '),
                      ),
                  ],
                ),
                _ListPane(
                  empty: 'No meetings booked yet.',
                  children: [
                    for (final meeting in workspace.meetings)
                      EntityRow(
                        title: meeting.targetPersonName,
                        subtitle: [
                          if (meeting.companyName != null) meeting.companyName!,
                          if (meeting.startAt != null) formatTimestamp(DateTime.tryParse(meeting.startAt!)),
                        ].join(' · '),
                        trailing: StatusChip(
                          label: labelFor(meetingStatusLabels, meeting.status),
                          emphasis: meeting.outcome == null && meeting.status == 'completed'
                              ? ChipEmphasis.danger
                              : ChipEmphasis.neutral,
                        ),
                        onTap: () => _open(context, meeting.targetPersonName, [
                          ('Status', labelFor(meetingStatusLabels, meeting.status)),
                          ('Confirmation', humanize(meeting.confirmationStatus)),
                          ('Company', meeting.companyName ?? 'Not set'),
                          ('When', meeting.startAt == null ? 'Not set' : formatTimestamp(DateTime.tryParse(meeting.startAt!))),
                          ('Timezone', meeting.timezone),
                          ('Format', humanize(meeting.format)),
                          ('Location', meeting.location ?? 'Not set'),
                          ('Owner', meeting.ownerName ?? 'Unassigned'),
                          ('Outcome', meeting.outcome == null ? 'Missing' : humanize(meeting.outcome!)),
                          ('Notes', meeting.schedulingNotes ?? 'None'),
                        ]),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsTab extends StatelessWidget {
  const _ResultsTab({required this.workspace});

  final CampaignWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final report = computeOpportunityReport(workspace.opportunities);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.cyan,
            labelColor: AppColors.cyan,
            unselectedLabelColor: AppColors.muted,
            tabs: [Tab(text: 'Tasks'), Tab(text: 'Opportunities'), Tab(text: 'Reports')],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ListPane(
                  empty: 'No follow-up tasks yet.',
                  children: [
                    for (final task in workspace.tasks)
                      EntityRow(
                        title: task.title,
                        subtitle: [
                          labelFor(taskPriorityLabels, task.priority),
                          if (task.dueDate != null) formatDate(task.dueDate),
                          if (task.ownerName != null) task.ownerName!,
                        ].join(' · '),
                        trailing: StatusChip(label: labelFor(taskStatusLabels, task.status)),
                        onTap: () => _open(context, task.title, [
                          ('Status', labelFor(taskStatusLabels, task.status)),
                          ('Priority', labelFor(taskPriorityLabels, task.priority)),
                          ('Due', formatDate(task.dueDate)),
                          ('Owner', task.ownerName ?? 'Unassigned'),
                          ('Target', task.targetPersonName ?? 'Not set'),
                          ('Company', task.companyName ?? 'Not set'),
                          ('Description', task.description ?? 'None'),
                        ]),
                      ),
                  ],
                ),
                _ListPane(
                  empty: 'No opportunities created yet.',
                  children: [
                    for (final opportunity in workspace.opportunities)
                      EntityRow(
                        title: opportunity.companyName ?? opportunity.contactName ?? 'Opportunity',
                        subtitle: [
                          labelFor(opportunityStageLabels, opportunity.stage),
                          formatMoney(opportunity.estimatedValueCents),
                        ].join(' · '),
                        onTap: () => _open(context, opportunity.companyName ?? 'Opportunity', [
                          ('Stage', labelFor(opportunityStageLabels, opportunity.stage)),
                          ('Type', opportunity.opportunityType == null ? 'Not set' : humanize(opportunity.opportunityType!)),
                          ('Contact', opportunity.contactName ?? 'Not set'),
                          ('Value', formatMoney(opportunity.estimatedValueCents)),
                          ('Probability', opportunity.probability == null ? 'Not set' : '${opportunity.probability}%'),
                          ('Owner', opportunity.ownerName ?? 'Unassigned'),
                          ('Next step', opportunity.nextStep ?? 'Not set'),
                          ('Next step date', formatDate(opportunity.nextStepDate)),
                          ('Notes', opportunity.notes ?? 'None'),
                        ]),
                      ),
                  ],
                ),
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _Card(title: 'Opportunity report', children: [
                      _Field(label: 'Total', value: '${report.totalCount}'),
                      _Field(label: 'Open', value: '${report.openCount} · ${formatMoney(report.openValueCents)}'),
                      _Field(label: 'Won', value: '${report.wonCount} · ${formatMoney(report.wonValueCents)}'),
                      _Field(label: 'Lost', value: '${report.lostCount}'),
                      _Field(label: 'Weighted pipeline', value: formatMoney(report.weightedPipelineCents)),
                    ]),
                    const SizedBox(height: 12),
                    _Card(
                      title: 'By stage',
                      children: [
                        for (final stage in opportunityStageOrder)
                          if ((report.stageCounts[stage] ?? 0) > 0)
                            _Field(label: labelFor(opportunityStageLabels, stage), value: '${report.stageCounts[stage]}'),
                        if (report.totalCount == 0) const _Field(label: 'Stages', value: 'No opportunities yet'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListPane extends StatelessWidget {
  const _ListPane({required this.empty, required this.children});

  final String empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return ListView(padding: const EdgeInsets.all(16), children: [EmptyHint(empty)]);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: children.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => children[index],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3)),
        ],
      ),
    );
  }
}

void _open(BuildContext context, String title, List<(String, String)> fields) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => DetailFieldsScreen(title: title, fields: fields)),
  );
}
