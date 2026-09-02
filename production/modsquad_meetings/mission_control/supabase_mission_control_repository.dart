import 'package:modsquad_meetings/mission_control/mission_control_repository.dart';
import 'package:modsquad_meetings/mission_control/models.dart';
import 'package:modsquad_meetings/mission_control/stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _stagePriority = <String, int>{
  'live': 0,
  'scheduling': 1,
  'outreach': 2,
  'targeting': 3,
  'follow_up': 4,
  'planning': 5,
  'draft': 6,
  'completed': 7,
  'archived': 8,
};

class SupabaseMissionControlRepository implements MissionControlRepository {
  SupabaseMissionControlRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<MissionControlSnapshot?> load() async {
    final campaigns = await _client
        .from('campaigns')
        .select('*, startups(name)')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    if (campaigns.isEmpty) return null;

    final rows = List<Map<String, dynamic>>.from(campaigns as List);
    rows.sort((a, b) {
      final left = _stagePriority[a['status'] as String? ?? ''] ?? 9;
      final right = _stagePriority[b['status'] as String? ?? ''] ?? 9;
      return left.compareTo(right);
    });
    final selected = rows.first;
    final campaignId = selected['id'] as String;

    final targetsFuture = _client
        .from('campaign_targets')
        .select('id, status, score_category, owner_id')
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null);
    final introsFuture = _client
        .from('introduction_requests')
        .select('id, status, sent_at')
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null);
    final outreachFuture = _client
        .from('outreach_activities')
        .select('id, follow_up_date, status')
        .eq('campaign_id', campaignId);
    final meetingsFuture = _client
        .from('meetings')
        .select('id, status, confirmation_status, start_at, outcome, availability_window_id')
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null);
    final tasksFuture = _client.from('tasks').select('id, status, due_date').eq('campaign_id', campaignId);
    final opportunitiesFuture = _client
        .from('opportunities')
        .select('id')
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null)
        .count(CountOption.exact);
    final activityFuture = _client
        .from('activity_events')
        .select('id, summary, created_at')
        .eq('campaign_id', campaignId)
        .order('created_at', ascending: false)
        .limit(8);
    final windowsFuture = _client
        .from('availability_windows')
        .select('id')
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null);

    final targetsRows = List<Map<String, dynamic>>.from(await targetsFuture);
    final introsRows = List<Map<String, dynamic>>.from(await introsFuture);
    final outreachRows = List<Map<String, dynamic>>.from(await outreachFuture);
    final meetingsRows = List<Map<String, dynamic>>.from(await meetingsFuture);
    final tasksRows = List<Map<String, dynamic>>.from(await tasksFuture);
    final opportunitiesRes = await opportunitiesFuture;
    final activityRows = List<Map<String, dynamic>>.from(await activityFuture);
    final windowRows = List<Map<String, dynamic>>.from(await windowsFuture);

    final targets = targetsRows
        .map(
          (row) => RawTarget(
            id: row['id'] as String,
            status: row['status'] as String,
            scoreCategory: row['score_category'] as String?,
            ownerId: row['owner_id'] as String?,
          ),
        )
        .toList();
    final introductions = introsRows
        .map(
          (row) => RawIntroduction(
            id: row['id'] as String,
            status: row['status'] as String,
            sentAt: row['sent_at'] == null ? null : DateTime.parse(row['sent_at'] as String),
          ),
        )
        .toList();
    final outreach = outreachRows
        .map(
          (row) => RawOutreach(
            id: row['id'] as String,
            status: row['status'] as String,
            followUpDate: row['follow_up_date'] as String?,
          ),
        )
        .toList();
    final meetings = meetingsRows
        .map(
          (row) => RawMeeting(
            id: row['id'] as String,
            status: row['status'] as String,
            confirmationStatus: row['confirmation_status'] as String,
            startAt: row['start_at'] as String?,
            outcome: row['outcome'] as String?,
            availabilityWindowId: row['availability_window_id'] as String?,
          ),
        )
        .toList();
    final tasks = tasksRows
        .map(
          (row) => RawTask(
            id: row['id'] as String,
            status: row['status'] as String,
            dueDate: row['due_date'] as String?,
          ),
        )
        .toList();
    final activity = activityRows
        .map(
          (row) => ActivityEvent(
            id: row['id'] as String,
            summary: row['summary'] as String,
            createdAt: DateTime.parse(row['created_at'] as String),
          ),
        )
        .toList();
    final windowIds = windowRows.map((row) => row['id'] as String).toList();

    final stats = computeMissionControlStats(
      MissionControlStatsInput(
        now: DateTime.now(),
        campaignId: campaignId,
        campaignStartDate: selected['start_date'] as String?,
        opportunitiesCreated: opportunitiesRes.count,
        targets: targets,
        introductions: introductions,
        outreach: outreach,
        meetings: meetings,
        tasks: tasks,
        windowIds: windowIds,
      ),
    );

    return MissionControlSnapshot(
      campaignId: campaignId,
      campaignName: selected['name'] as String,
      campaignStatus: selected['status'] as String,
      startupName: _startupName(selected['startups']),
      eventCity: selected['event_city'] as String?,
      datesConfirmed: selected['dates_confirmed'] as bool? ?? true,
      targetGoal: selected['target_meeting_goal'] as int?,
      daysUntilStart: stats.daysUntilStart,
      targets: stats.targets,
      introductions: stats.introductions,
      outreach: stats.outreach,
      meetings: stats.meetings,
      tasks: stats.tasks,
      opportunitiesCreated: stats.opportunitiesCreated,
      funnel: stats.funnel,
      nextBestActions: stats.nextBestActions,
      recentActivity: activity,
    );
  }

  String? _startupName(dynamic value) {
    if (value is Map<String, dynamic>) return value['name'] as String?;
    if (value is List && value.isNotEmpty && value.first is Map) {
      return (value.first as Map)['name'] as String?;
    }
    return null;
  }
}
