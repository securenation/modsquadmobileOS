import 'package:modsquad_meetings/mission_control/models.dart';

const staleIntroDays = 4;

const _qualifiedStatuses = {
  'qualified',
  'high_priority',
  'assigned',
  'introduction_available',
  'introduction_requested',
  'ready_for_outreach',
  'contacted',
  'responded',
  'interested',
  'scheduling',
  'confirmed',
  'completed',
  'opportunity_created',
};

String _ymdUtc(DateTime value) {
  final utc = value.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '${utc.year}-$month-$day';
}

DateTime _parseDateOnlyUtc(String value) {
  final date = value.length >= 10 ? value.substring(0, 10) : value;
  final parts = date.split('-');
  return DateTime.utc(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

String _plural(int count, String singular, [String? plural]) {
  return count == 1 ? singular : (plural ?? '${singular}s');
}

class ComputedMissionControlStats {
  const ComputedMissionControlStats({
    required this.daysUntilStart,
    required this.targets,
    required this.introductions,
    required this.outreach,
    required this.meetings,
    required this.tasks,
    required this.opportunitiesCreated,
    required this.funnel,
    required this.nextBestActions,
  });

  final int? daysUntilStart;
  final TargetStats targets;
  final IntroStats introductions;
  final OutreachStats outreach;
  final MeetingStats meetings;
  final TaskStats tasks;
  final int opportunitiesCreated;
  final FunnelStats funnel;
  final List<NextBestAction> nextBestActions;
}

ComputedMissionControlStats computeMissionControlStats(MissionControlStatsInput input) {
  final todayStr = _ymdUtc(input.now);
  final href = '/campaigns/${input.campaignId}';

  final targetStats = TargetStats(
    total: input.targets.length,
    qualified: input.targets.where((t) => _qualifiedStatuses.contains(t.status)).length,
    highPriority: input.targets
        .where((t) => t.scoreCategory == 'critical' || t.scoreCategory == 'high')
        .length,
    awaitingAssignment: input.targets
        .where((t) => t.ownerId == null && t.status != 'do_not_contact')
        .length,
    readyForOutreach: input.targets.where((t) => t.status == 'ready_for_outreach').length,
  );

  final staleCutoff = input.now.toUtc().subtract(const Duration(days: staleIntroDays));
  final introStats = IntroStats(
    opportunities: input.targets.where((t) => t.status == 'introduction_available').length,
    awaitingResponse: input.introductions
        .where((i) => i.status == 'requested' || i.status == 'viewed')
        .length,
    neverSent: input.introductions.where((i) => i.status == 'draft').length,
    staleAwaitingResponse: input.introductions.where((i) {
      if (i.status != 'requested' && i.status != 'viewed') return false;
      final sentAt = i.sentAt;
      return sentAt != null && sentAt.toUtc().isBefore(staleCutoff);
    }).length,
  );

  final outreachStats = OutreachStats(
    needingFollowUp: input.outreach.where((o) {
      final date = o.followUpDate;
      return date != null && date.compareTo(todayStr) <= 0 && o.status != 'responded';
    }).length,
  );

  final bookedWindowIds = {
    for (final meeting in input.meetings)
      if (meeting.availabilityWindowId != null) meeting.availabilityWindowId!,
  };
  final openSlots = input.windowIds.where((id) => !bookedWindowIds.contains(id)).length;

  final meetingStats = MeetingStats(
    awaitingConfirmation: input.meetings
        .where((m) => m.confirmationStatus != 'confirmed' && m.status != 'canceled')
        .length,
    confirmed: input.meetings.where((m) => m.status == 'confirmed').length,
    today: input.meetings.where((m) => m.startAt != null && m.startAt!.startsWith(todayStr)).length,
    completedMissingOutcome:
        input.meetings.where((m) => m.status == 'completed' && (m.outcome == null || m.outcome!.isEmpty)).length,
    openSlots: openSlots,
  );

  final taskStats = TaskStats(
    dueToday: input.tasks.where((t) => t.status != 'completed' && t.dueDate == todayStr).length,
    overdue: input.tasks
        .where((t) => t.status != 'completed' && t.dueDate != null && t.dueDate!.compareTo(todayStr) < 0)
        .length,
  );

  final funnel = FunnelStats(
    qualifiedTargets: targetStats.qualified,
    introductionsOrOutreach: input.introductions.length + input.outreach.length,
    meetingsConfirmed: meetingStats.confirmed,
    meetingsCompleted: input.meetings.where((m) => m.status == 'completed').length,
    opportunities: input.opportunitiesCreated,
  );

  final nextBestActions = <NextBestAction>[];
  if (targetStats.awaitingAssignment > 0) {
    nextBestActions.add(
      NextBestAction(
        label:
            'Assign an owner to ${targetStats.awaitingAssignment} unassigned ${_plural(targetStats.awaitingAssignment, 'target')}',
        detail: 'High-priority targets without an owner stall the whole workflow.',
        href: href,
      ),
    );
  }
  if (introStats.neverSent > 0) {
    nextBestActions.add(
      NextBestAction(
        label:
            'Send ${introStats.neverSent} introduction ${_plural(introStats.neverSent, 'request')} that ${introStats.neverSent == 1 ? "hasn't" : "haven't"} gone out yet',
        detail: 'Created but never marked as sent to the advisor.',
        href: href,
      ),
    );
  }
  if (introStats.staleAwaitingResponse > 0) {
    nextBestActions.add(
      NextBestAction(
        label:
            'Nudge ${introStats.staleAwaitingResponse} ${_plural(introStats.staleAwaitingResponse, 'advisor')} on a stale introduction request',
        detail: 'Sent $staleIntroDays+ days ago with no response.',
        href: href,
      ),
    );
  }
  if (introStats.awaitingResponse > 0) {
    nextBestActions.add(
      NextBestAction(
        label:
            'Follow up on ${introStats.awaitingResponse} introduction ${_plural(introStats.awaitingResponse, 'request')} awaiting a response',
        detail: "An advisor hasn't responded yet.",
        href: href,
      ),
    );
  }
  if (outreachStats.needingFollowUp > 0) {
    nextBestActions.add(
      NextBestAction(
        label:
            'Follow up on ${outreachStats.needingFollowUp} outreach ${_plural(outreachStats.needingFollowUp, 'thread')}',
        detail: 'Follow-up date has arrived and no response is logged.',
        href: href,
      ),
    );
  }
  if (meetingStats.openSlots > 0 && targetStats.readyForOutreach > 0) {
    nextBestActions.add(
      NextBestAction(
        label: 'Fill ${meetingStats.openSlots} open meeting ${_plural(meetingStats.openSlots, 'slot')}',
        detail:
            '${targetStats.readyForOutreach} ${_plural(targetStats.readyForOutreach, 'target')} ${targetStats.readyForOutreach == 1 ? 'is' : 'are'} ready for outreach.',
        href: href,
      ),
    );
  }
  if (meetingStats.completedMissingOutcome > 0) {
    nextBestActions.add(
      NextBestAction(
        label:
            'Record the outcome for ${meetingStats.completedMissingOutcome} completed ${_plural(meetingStats.completedMissingOutcome, 'meeting')}',
        detail: 'A meeting happened but no outcome is on file yet.',
        href: href,
      ),
    );
  }
  if (taskStats.overdue > 0) {
    nextBestActions.add(
      NextBestAction(
        label: 'Clear ${taskStats.overdue} overdue follow-up ${_plural(taskStats.overdue, 'task')}',
        detail: 'These are past their due date.',
        href: href,
      ),
    );
  }

  int? daysUntilStart;
  final startDate = input.campaignStartDate;
  if (startDate != null && startDate.isNotEmpty) {
    final nowUtc = input.now.toUtc();
    final today = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final startDay = _parseDateOnlyUtc(startDate);
    daysUntilStart = startDay.difference(today).inDays;
  }

  return ComputedMissionControlStats(
    daysUntilStart: daysUntilStart,
    targets: targetStats,
    introductions: introStats,
    outreach: outreachStats,
    meetings: meetingStats,
    tasks: taskStats,
    opportunitiesCreated: input.opportunitiesCreated,
    funnel: funnel,
    nextBestActions: nextBestActions,
  );
}
