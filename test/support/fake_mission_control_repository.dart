import 'package:modsquad_meetings/mission_control/mission_control_repository.dart';
import 'package:modsquad_meetings/mission_control/models.dart';

class FakeMissionControlRepository implements MissionControlRepository {
  FakeMissionControlRepository({this.snapshot, this.error});

  MissionControlSnapshot? snapshot;
  Object? error;
  int loadCount = 0;

  @override
  Future<MissionControlSnapshot?> load() async {
    loadCount += 1;
    final thrown = error;
    if (thrown != null) throw thrown;
    return snapshot;
  }
}

MissionControlSnapshot sampleSnapshot({
  List<NextBestAction> actions = const [
    NextBestAction(
      label: 'Assign an owner to 3 unassigned targets',
      detail: 'High-priority targets without an owner stall the whole workflow.',
      href: '/campaigns/c1',
    ),
  ],
}) {
  return MissionControlSnapshot(
    campaignId: 'c1',
    campaignName: 'Dante @ Black Hat',
    campaignStatus: 'live',
    startupName: 'Dante Security',
    eventCity: 'Las Vegas',
    datesConfirmed: true,
    targetGoal: 40,
    daysUntilStart: 12,
    targets: const TargetStats(
      total: 80,
      qualified: 54,
      highPriority: 11,
      awaitingAssignment: 3,
      readyForOutreach: 6,
    ),
    introductions: const IntroStats(
      opportunities: 4,
      awaitingResponse: 2,
      neverSent: 1,
      staleAwaitingResponse: 0,
    ),
    outreach: const OutreachStats(needingFollowUp: 0),
    meetings: const MeetingStats(
      awaitingConfirmation: 2,
      confirmed: 9,
      today: 3,
      completedMissingOutcome: 1,
      openSlots: 4,
    ),
    tasks: const TaskStats(dueToday: 1, overdue: 0),
    opportunitiesCreated: 5,
    funnel: const FunnelStats(
      qualifiedTargets: 54,
      introductionsOrOutreach: 18,
      meetingsConfirmed: 9,
      meetingsCompleted: 4,
      opportunities: 5,
    ),
    nextBestActions: actions,
    recentActivity: [
      ActivityEvent(
        id: 'a1',
        summary: 'Intro request sent to R. Patel',
        createdAt: DateTime.parse('2026-08-04T15:00:00Z'),
      ),
    ],
  );
}
