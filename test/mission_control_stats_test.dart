import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/mission_control/models.dart';
import 'package:modsquad_meetings/mission_control/stats.dart';

final now = DateTime.parse('2026-08-04T12:00:00Z');

MissionControlStatsInput baseInput({
  String? campaignStartDate,
  int opportunitiesCreated = 0,
  List<RawTarget> targets = const [],
  List<RawIntroduction> introductions = const [],
  List<RawOutreach> outreach = const [],
  List<RawMeeting> meetings = const [],
  List<RawTask> tasks = const [],
  List<String> windowIds = const [],
}) {
  return MissionControlStatsInput(
    now: now,
    campaignId: 'campaign-1',
    campaignStartDate: campaignStartDate,
    opportunitiesCreated: opportunitiesCreated,
    targets: targets,
    introductions: introductions,
    outreach: outreach,
    meetings: meetings,
    tasks: tasks,
    windowIds: windowIds,
  );
}

void main() {
  test('counts targets awaiting assignment but not do-not-contact targets', () {
    final stats = computeMissionControlStats(
      baseInput(
        targets: const [
          RawTarget(id: '1', status: 'qualified', scoreCategory: 'high', ownerId: null),
          RawTarget(id: '2', status: 'do_not_contact', scoreCategory: null, ownerId: null),
          RawTarget(id: '3', status: 'qualified', scoreCategory: 'low', ownerId: 'member-1'),
        ],
      ),
    );

    expect(stats.targets.awaitingAssignment, 1);
    expect(stats.targets.qualified, 2);
    expect(stats.targets.highPriority, 1);
  });

  test('treats outreach as needing follow-up only when the date has arrived and there is no response', () {
    final stats = computeMissionControlStats(
      baseInput(
        outreach: const [
          RawOutreach(id: '1', status: 'logged', followUpDate: '2026-08-02'),
          RawOutreach(id: '2', status: 'logged', followUpDate: '2026-08-04'),
          RawOutreach(id: '3', status: 'logged', followUpDate: '2026-08-10'),
          RawOutreach(id: '4', status: 'responded', followUpDate: '2026-08-02'),
          RawOutreach(id: '5', status: 'logged', followUpDate: null),
        ],
      ),
    );

    expect(stats.outreach.needingFollowUp, 2);
  });

  test('computes open meeting slots as windows not referenced by any meeting', () {
    final stats = computeMissionControlStats(
      baseInput(
        windowIds: const ['w1', 'w2', 'w3'],
        meetings: const [
          RawMeeting(
            id: 'm1',
            status: 'confirmed',
            confirmationStatus: 'confirmed',
            startAt: null,
            outcome: null,
            availabilityWindowId: 'w1',
          ),
        ],
      ),
    );

    expect(stats.meetings.openSlots, 2);
  });

  test('flags completed meetings with no outcome recorded', () {
    final stats = computeMissionControlStats(
      baseInput(
        meetings: const [
          RawMeeting(
            id: 'm1',
            status: 'completed',
            confirmationStatus: 'confirmed',
            startAt: null,
            outcome: null,
            availabilityWindowId: null,
          ),
          RawMeeting(
            id: 'm2',
            status: 'completed',
            confirmationStatus: 'confirmed',
            startAt: null,
            outcome: 'design_partner_opportunity',
            availabilityWindowId: null,
          ),
        ],
      ),
    );

    expect(stats.meetings.completedMissingOutcome, 1);
    expect(stats.funnel.meetingsCompleted, 2);
  });

  test('buckets tasks into due-today and overdue, ignoring completed tasks', () {
    final stats = computeMissionControlStats(
      baseInput(
        tasks: const [
          RawTask(id: '1', status: 'open', dueDate: '2026-08-04'),
          RawTask(id: '2', status: 'open', dueDate: '2026-08-01'),
          RawTask(id: '3', status: 'completed', dueDate: '2026-08-01'),
          RawTask(id: '4', status: 'open', dueDate: '2026-08-10'),
        ],
      ),
    );

    expect(stats.tasks.dueToday, 1);
    expect(stats.tasks.overdue, 1);
  });

  test('computes days until start from the campaign start date', () {
    final stats = computeMissionControlStats(baseInput(campaignStartDate: '2026-08-09'));
    expect(stats.daysUntilStart, 5);
  });

  test('generates a next-best-action for unassigned targets', () {
    final stats = computeMissionControlStats(
      baseInput(
        targets: const [
          RawTarget(id: '1', status: 'qualified', scoreCategory: 'high', ownerId: null),
        ],
      ),
    );

    expect(stats.nextBestActions.first.label, contains('Assign an owner'));
    expect(stats.nextBestActions.first.href, '/campaigns/campaign-1');
  });

  test('produces no next-best-actions when everything is on track', () {
    final stats = computeMissionControlStats(baseInput());
    expect(stats.nextBestActions, isEmpty);
  });

  test('counts introduction requests never marked sent', () {
    final stats = computeMissionControlStats(
      baseInput(
        introductions: [
          const RawIntroduction(id: '1', status: 'draft', sentAt: null),
          RawIntroduction(id: '2', status: 'requested', sentAt: DateTime.parse('2026-08-01T00:00:00Z')),
          const RawIntroduction(id: '3', status: 'draft', sentAt: null),
        ],
      ),
    );

    expect(stats.introductions.neverSent, 2);
  });

  test('flags a sent introduction as stale only past the 4-day threshold', () {
    final stats = computeMissionControlStats(
      baseInput(
        introductions: [
          RawIntroduction(id: '1', status: 'requested', sentAt: DateTime.parse('2026-07-30T00:00:00Z')),
          RawIntroduction(id: '2', status: 'requested', sentAt: DateTime.parse('2026-08-02T00:00:00Z')),
          const RawIntroduction(id: '3', status: 'requested', sentAt: null),
          RawIntroduction(id: '4', status: 'accepted', sentAt: DateTime.parse('2026-07-01T00:00:00Z')),
        ],
      ),
    );

    expect(stats.introductions.staleAwaitingResponse, 1);
  });
}
