class RawTarget {
  const RawTarget({
    required this.id,
    required this.status,
    required this.scoreCategory,
    required this.ownerId,
  });

  final String id;
  final String status;
  final String? scoreCategory;
  final String? ownerId;
}

class RawIntroduction {
  const RawIntroduction({
    required this.id,
    required this.status,
    required this.sentAt,
  });

  final String id;
  final String status;
  final DateTime? sentAt;
}

class RawOutreach {
  const RawOutreach({
    required this.id,
    required this.status,
    required this.followUpDate,
  });

  final String id;
  final String status;
  final String? followUpDate;
}

class RawMeeting {
  const RawMeeting({
    required this.id,
    required this.status,
    required this.confirmationStatus,
    required this.startAt,
    required this.outcome,
    required this.availabilityWindowId,
  });

  final String id;
  final String status;
  final String confirmationStatus;
  final String? startAt;
  final String? outcome;
  final String? availabilityWindowId;
}

class RawTask {
  const RawTask({
    required this.id,
    required this.status,
    required this.dueDate,
  });

  final String id;
  final String status;
  final String? dueDate;
}

class NextBestAction {
  const NextBestAction({
    required this.label,
    required this.detail,
    required this.href,
  });

  final String label;
  final String detail;
  final String href;
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.summary,
    required this.createdAt,
  });

  final String id;
  final String summary;
  final DateTime createdAt;
}

class MissionControlSnapshot {
  const MissionControlSnapshot({
    required this.campaignId,
    required this.campaignName,
    required this.campaignStatus,
    required this.startupName,
    required this.eventCity,
    required this.datesConfirmed,
    required this.targetGoal,
    required this.daysUntilStart,
    required this.targets,
    required this.introductions,
    required this.outreach,
    required this.meetings,
    required this.tasks,
    required this.opportunitiesCreated,
    required this.funnel,
    required this.nextBestActions,
    required this.recentActivity,
  });

  final String campaignId;
  final String campaignName;
  final String campaignStatus;
  final String? startupName;
  final String? eventCity;
  final bool datesConfirmed;
  final int? targetGoal;
  final int? daysUntilStart;
  final TargetStats targets;
  final IntroStats introductions;
  final OutreachStats outreach;
  final MeetingStats meetings;
  final TaskStats tasks;
  final int opportunitiesCreated;
  final FunnelStats funnel;
  final List<NextBestAction> nextBestActions;
  final List<ActivityEvent> recentActivity;
}

class TargetStats {
  const TargetStats({
    required this.total,
    required this.qualified,
    required this.highPriority,
    required this.awaitingAssignment,
    required this.readyForOutreach,
  });

  final int total;
  final int qualified;
  final int highPriority;
  final int awaitingAssignment;
  final int readyForOutreach;
}

class IntroStats {
  const IntroStats({
    required this.opportunities,
    required this.awaitingResponse,
    required this.neverSent,
    required this.staleAwaitingResponse,
  });

  final int opportunities;
  final int awaitingResponse;
  final int neverSent;
  final int staleAwaitingResponse;
}

class OutreachStats {
  const OutreachStats({required this.needingFollowUp});

  final int needingFollowUp;
}

class MeetingStats {
  const MeetingStats({
    required this.awaitingConfirmation,
    required this.confirmed,
    required this.today,
    required this.completedMissingOutcome,
    required this.openSlots,
  });

  final int awaitingConfirmation;
  final int confirmed;
  final int today;
  final int completedMissingOutcome;
  final int openSlots;
}

class TaskStats {
  const TaskStats({required this.dueToday, required this.overdue});

  final int dueToday;
  final int overdue;
}

class FunnelStats {
  const FunnelStats({
    required this.qualifiedTargets,
    required this.introductionsOrOutreach,
    required this.meetingsConfirmed,
    required this.meetingsCompleted,
    required this.opportunities,
  });

  final int qualifiedTargets;
  final int introductionsOrOutreach;
  final int meetingsConfirmed;
  final int meetingsCompleted;
  final int opportunities;
}

class MissionControlStatsInput {
  const MissionControlStatsInput({
    required this.now,
    required this.campaignId,
    required this.campaignStartDate,
    required this.opportunitiesCreated,
    required this.targets,
    required this.introductions,
    required this.outreach,
    required this.meetings,
    required this.tasks,
    required this.windowIds,
  });

  final DateTime now;
  final String campaignId;
  final String? campaignStartDate;
  final int opportunitiesCreated;
  final List<RawTarget> targets;
  final List<RawIntroduction> introductions;
  final List<RawOutreach> outreach;
  final List<RawMeeting> meetings;
  final List<RawTask> tasks;
  final List<String> windowIds;
}
