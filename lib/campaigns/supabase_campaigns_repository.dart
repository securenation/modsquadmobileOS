import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';
import 'package:modsquad_meetings/shared/json.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCampaignsRepository implements CampaignsRepository {
  SupabaseCampaignsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Campaign>> listCampaigns() async {
    final rows = await _client
        .from('campaigns')
        .select('*, startups(name)')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows as List).map(_fromCampaignRow).toList();
  }

  @override
  Future<CampaignWorkspace> loadWorkspace(String campaignId) async {
    final targetsFuture = _client
        .from('campaign_targets')
        .select(
          'id, status, score, score_category, score_explanation, people(full_name, job_title, email, phone, linkedin_url, city, do_not_contact, tags, companies(id, name, domain, tags))',
        )
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null)
        .order('score', ascending: false);
    final introsFuture = _client
        .from('introduction_requests')
        .select(
          'id, status, reason, sent_at, advisor_note, introducer_member_id, campaign_targets(people(full_name, companies(name)))',
        )
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
    final outreachFuture = _client
        .from('outreach_activities')
        .select(
          'id, channel, subject, content, status, follow_up_date, campaign_targets(people(full_name, companies(name)))',
        )
        .eq('campaign_id', campaignId)
        .order('created_at', ascending: false);
    final windowsFuture = _client
        .from('availability_windows')
        .select('id, window_date, start_time, end_time, timezone, location, capacity, member_id')
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null)
        .order('window_date')
        .order('start_time');
    final meetingsFuture = _client
        .from('meetings')
        .select(
          'id, start_at, timezone, location, format, status, confirmation_status, outcome, scheduling_notes, owner_id, campaign_targets(people(full_name)), companies(name)',
        )
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null)
        .order('start_at');
    final tasksFuture = _client
        .from('tasks')
        .select(
          'id, title, description, status, priority, due_date, owner_id, campaign_targets(people(full_name)), companies(name)',
        )
        .eq('campaign_id', campaignId)
        .order('due_date');
    final opportunitiesFuture = _client
        .from('opportunities')
        .select(
          'id, stage, opportunity_type, estimated_value_cents, probability, next_step, next_step_date, notes, owner_id, companies(name), people(full_name)',
        )
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
    final scoringFuture = _client
        .from('scoring_rules')
        .select('id, category, weight, is_active')
        .eq('campaign_id', campaignId)
        .order('category');

    final targetRows = await _rows(targetsFuture);
    final introRows = await _rows(introsFuture);
    final outreachRows = await _rows(outreachFuture);
    final windowRows = await _rows(windowsFuture);
    final meetingRows = await _rows(meetingsFuture);
    final taskRows = await _rows(tasksFuture);
    final opportunityRows = await _rows(opportunitiesFuture);
    var scoringRows = <Map<String, dynamic>>[];
    try {
      scoringRows = await _rows(scoringFuture);
    } catch (_) {
      scoringRows = const [];
    }

    final memberIds = <String>{
      for (final row in introRows)
        if (row['introducer_member_id'] is String) row['introducer_member_id'] as String,
      for (final row in windowRows)
        if (row['member_id'] is String) row['member_id'] as String,
      for (final row in meetingRows)
        if (row['owner_id'] is String) row['owner_id'] as String,
      for (final row in taskRows)
        if (row['owner_id'] is String) row['owner_id'] as String,
      for (final row in opportunityRows)
        if (row['owner_id'] is String) row['owner_id'] as String,
    };
    final names = await _memberNames(memberIds);

    final targets = targetRows.map(_targetFromRow).toList();
    return CampaignWorkspace(
      targets: targets,
      companies: _companiesFromTargets(targetRows),
      introductions: introRows
          .map(
            (row) => CampaignIntroduction(
              id: row['id'] as String,
              status: row['status'] as String,
              reason: row['reason'] as String?,
              targetPersonName: asMap(asMap(row['campaign_targets'])?['people'])?['full_name'] as String? ?? 'Unknown',
              companyName: asMap(asMap(asMap(row['campaign_targets'])?['people'])?['companies'])?['name'] as String?,
              introducerName: names[row['introducer_member_id'] as String?] ?? 'Unknown',
              sentAt: row['sent_at'] as String?,
              advisorNote: row['advisor_note'] as String?,
            ),
          )
          .toList(),
      outreach: outreachRows
          .map(
            (row) => CampaignOutreach(
              id: row['id'] as String,
              channel: row['channel'] as String,
              subject: row['subject'] as String?,
              content: row['content'] as String?,
              status: row['status'] as String,
              targetPersonName: asMap(asMap(row['campaign_targets'])?['people'])?['full_name'] as String? ?? 'Unknown',
              companyName: asMap(asMap(asMap(row['campaign_targets'])?['people'])?['companies'])?['name'] as String?,
              followUpDate: row['follow_up_date'] as String?,
            ),
          )
          .toList(),
      windows: windowRows
          .map(
            (row) => AvailabilityWindow(
              id: row['id'] as String,
              windowDate: row['window_date'] as String,
              startTime: (row['start_time'] as String?) ?? '',
              endTime: (row['end_time'] as String?) ?? '',
              timezone: row['timezone'] as String? ?? 'UTC',
              location: row['location'] as String?,
              capacity: (row['capacity'] as num?)?.toInt() ?? 1,
              memberName: names[row['member_id'] as String?],
            ),
          )
          .toList(),
      meetings: meetingRows
          .map(
            (row) => CampaignMeeting(
              id: row['id'] as String,
              targetPersonName: asMap(asMap(row['campaign_targets'])?['people'])?['full_name'] as String? ?? 'Unknown',
              companyName: asMap(row['companies'])?['name'] as String?,
              startAt: row['start_at'] as String?,
              timezone: row['timezone'] as String? ?? 'UTC',
              location: row['location'] as String?,
              format: row['format'] as String? ?? 'unknown',
              status: row['status'] as String,
              confirmationStatus: row['confirmation_status'] as String? ?? 'unconfirmed',
              outcome: row['outcome'] as String?,
              ownerName: names[row['owner_id'] as String?],
              schedulingNotes: row['scheduling_notes'] as String?,
            ),
          )
          .toList(),
      tasks: taskRows
          .map(
            (row) => CampaignTask(
              id: row['id'] as String,
              title: row['title'] as String,
              description: row['description'] as String?,
              status: row['status'] as String,
              priority: row['priority'] as String? ?? 'medium',
              dueDate: row['due_date'] as String?,
              ownerName: names[row['owner_id'] as String?],
              targetPersonName: asMap(asMap(row['campaign_targets'])?['people'])?['full_name'] as String?,
              companyName: asMap(row['companies'])?['name'] as String?,
            ),
          )
          .toList(),
      opportunities: opportunityRows
          .map(
            (row) => CampaignOpportunity(
              id: row['id'] as String,
              companyName: asMap(row['companies'])?['name'] as String?,
              contactName: asMap(row['people'])?['full_name'] as String?,
              stage: row['stage'] as String,
              opportunityType: row['opportunity_type'] as String?,
              estimatedValueCents: (row['estimated_value_cents'] as num?)?.toInt(),
              probability: row['probability'] as num?,
              nextStep: row['next_step'] as String?,
              nextStepDate: row['next_step_date'] as String?,
              notes: row['notes'] as String?,
              ownerName: names[row['owner_id'] as String?],
            ),
          )
          .toList(),
      scoringRules: scoringRows
          .map(
            (row) => ScoringRule(
              id: row['id'] as String,
              category: row['category'] as String,
              weight: row['weight'] as num? ?? 0,
              isActive: row['is_active'] as bool? ?? true,
            ),
          )
          .toList(),
    );
  }

  Campaign _fromCampaignRow(Map<String, dynamic> row) {
    return Campaign(
      id: row['id'] as String,
      name: row['name'] as String,
      status: row['status'] as String,
      startupName: asMap(row['startups'])?['name'] as String?,
      eventName: row['event_name'] as String?,
      eventCity: row['event_city'] as String?,
      eventVenue: row['event_venue'] as String?,
      startDate: row['start_date'] as String?,
      endDate: row['end_date'] as String?,
      timezone: row['default_timezone'] as String? ?? 'UTC',
      targetMeetingGoal: row['target_meeting_goal'] as int?,
      targetMeetingTypes: asStringList(row['target_meeting_types']),
      targetAccountList: asStringList(row['target_account_list']),
      datesConfirmed: row['dates_confirmed'] as bool? ?? true,
      notes: row['notes'] as String?,
    );
  }

  CampaignTarget _targetFromRow(Map<String, dynamic> row) {
    final person = asMap(row['people']);
    final company = asMap(person?['companies']);
    return CampaignTarget(
      id: row['id'] as String,
      status: row['status'] as String,
      score: row['score'] as num?,
      scoreCategory: row['score_category'] as String?,
      scoreExplanation: row['score_explanation'] as String?,
      fullName: person?['full_name'] as String? ?? 'Unknown',
      jobTitle: person?['job_title'] as String?,
      email: person?['email'] as String?,
      phone: person?['phone'] as String?,
      linkedinUrl: person?['linkedin_url'] as String?,
      city: person?['city'] as String?,
      companyName: company?['name'] as String?,
      tags: asStringList(person?['tags']),
      doNotContact: person?['do_not_contact'] as bool? ?? false,
    );
  }

  List<CampaignCompany> _companiesFromTargets(List<Map<String, dynamic>> rows) {
    final byId = <String, CampaignCompany>{};
    for (final row in rows) {
      final company = asMap(asMap(row['people'])?['companies']);
      if (company == null) continue;
      final id = company['id'] as String?;
      if (id == null) continue;
      final existing = byId[id];
      if (existing == null) {
        byId[id] = CampaignCompany(
          id: id,
          name: company['name'] as String? ?? 'Unknown',
          domain: company['domain'] as String?,
          tags: asStringList(company['tags']),
          targetCount: 1,
        );
      } else {
        byId[id] = CampaignCompany(
          id: existing.id,
          name: existing.name,
          domain: existing.domain,
          tags: existing.tags,
          targetCount: existing.targetCount + 1,
        );
      }
    }
    final companies = byId.values.toList()
      ..sort((a, b) {
        final byCount = b.targetCount.compareTo(a.targetCount);
        return byCount != 0 ? byCount : a.name.compareTo(b.name);
      });
    return companies;
  }

  Future<List<Map<String, dynamic>>> _rows(dynamic query) async {
    return List<Map<String, dynamic>>.from((await query) as List);
  }

  Future<Map<String, String>> _memberNames(Set<String> memberIds) async {
    if (memberIds.isEmpty) return {};
    final members = await _client.from('organization_members').select('id, user_id').inFilter('id', memberIds.toList());
    final memberRows = List<Map<String, dynamic>>.from(members as List);
    final userIds = memberRows.map((row) => row['user_id'] as String).toSet().toList();
    if (userIds.isEmpty) return {};
    final profiles = await _client.from('profiles').select('id, full_name').inFilter('id', userIds);
    final nameByUser = {
      for (final row in List<Map<String, dynamic>>.from(profiles as List))
        row['id'] as String: row['full_name'] as String? ?? 'Unknown',
    };
    return {
      for (final row in memberRows) row['id'] as String: nameByUser[row['user_id'] as String] ?? 'Unknown',
    };
  }
}
