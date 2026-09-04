import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/intro_message.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';
import 'package:modsquad_meetings/config/app_config.dart';
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
          'id, status, score, score_category, score_explanation, owner_id, people(full_name, job_title, email, phone, linkedin_url, city, do_not_contact, tags, companies(id, name, domain, tags))',
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
          'id, start_at, timezone, location, format, status, confirmation_status, outcome, scheduling_notes, owner_id, campaign_target_id, campaign_targets(people(full_name)), companies(name)',
        )
        .eq('campaign_id', campaignId)
        .isFilter('deleted_at', null)
        .order('start_at');
    final tasksFuture = _client
        .from('tasks')
        .select(
          'id, title, description, status, priority, due_date, owner_id, campaign_target_id, campaign_targets(people(full_name)), companies(name)',
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
      for (final row in targetRows)
        if (row['owner_id'] is String) row['owner_id'] as String,
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

    final targets = targetRows.map((row) => _targetFromRow(row, names)).toList();
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
              ownerId: row['owner_id'] as String?,
              campaignTargetId: row['campaign_target_id'] as String?,
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
              ownerId: row['owner_id'] as String?,
              campaignTargetId: row['campaign_target_id'] as String?,
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
      orgId: row['org_id'] as String? ?? '',
      startupId: row['startup_id'] as String? ?? '',
    );
  }

  CampaignTarget _targetFromRow(Map<String, dynamic> row, Map<String, String> names) {
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
      ownerId: row['owner_id'] as String?,
      ownerName: names[row['owner_id'] as String?],
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

  String? _blankToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<T> _write<T>(Future<T> Function() run, String fallback) async {
    try {
      return await run();
    } on WorkspaceFailure {
      rethrow;
    } catch (error) {
      throw WorkspaceFailure(error.toString().isEmpty ? fallback : error.toString());
    }
  }

  @override
  Future<List<OwnerOption>> listOwners() async {
    try {
      final members = await _client
          .from('organization_members')
          .select('id, user_id, role')
          .inFilter('role', ['mod_squad_admin', 'dante_team_member'])
          .eq('is_active', true);
      final memberRows = List<Map<String, dynamic>>.from(members as List);
      final names = await _memberNames({
        for (final row in memberRows)
          if (row['id'] is String) row['id'] as String,
      });
      final owners = [
        for (final row in memberRows)
          OwnerOption(
            memberId: row['id'] as String,
            name: names[row['id'] as String] ?? 'Unknown',
            role: row['role'] as String? ?? '',
          ),
      ]..sort((a, b) => a.name.compareTo(b.name));
      return owners;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Campaign> createCampaign(CreateCampaignInput input, SignedInProfile profile) {
    return _write(() async {
      final row = await _client
          .from('campaigns')
          .insert({
            'org_id': profile.orgId,
            'startup_id': input.startupId,
            'name': input.name.trim(),
            'event_name': _blankToNull(input.eventName),
            'event_city': _blankToNull(input.eventCity),
            'target_meeting_goal': input.targetMeetingGoal,
            'status': 'draft',
            'dates_confirmed': false,
            'created_by': profile.userId,
          })
          .select('*, startups(name)')
          .single();
      return _fromCampaignRow(Map<String, dynamic>.from(row as Map));
    }, 'Could not create the campaign. Please try again.');
  }

  @override
  Future<void> recordMeetingOutcome(MeetingOutcomeInput input, SignedInProfile profile) {
    return _write(() async {
      if (input.didMeetingOccur && (input.outcomeCategory == null || input.outcomeCategory!.isEmpty)) {
        throw const WorkspaceFailure("Choose what this meeting's outcome was.");
      }
      final meeting = await _client
          .from('meetings')
          .select('org_id, campaign_id, campaign_target_id, status')
          .eq('id', input.meetingId)
          .single();
      final meetingRow = Map<String, dynamic>.from(meeting as Map);

      await _client.from('meeting_outcomes').upsert({
        'meeting_id': input.meetingId,
        'did_meeting_occur': input.didMeetingOccur,
        'attendees_actual': _blankToNull(input.attendeesActual),
        'interest_level': _blankToNull(input.interestLevel),
        'problems_discussed': _blankToNull(input.problemsDiscussed),
        'existing_tools': _blankToNull(input.existingTools),
        'buying_process': _blankToNull(input.buyingProcess),
        'product_feedback': _blankToNull(input.productFeedback),
        'objections': _blankToNull(input.objections),
        'desired_next_step': _blankToNull(input.desiredNextStep),
        'follow_up_owner_id': _blankToNull(input.followUpOwnerId),
        'follow_up_due_date': _blankToNull(input.followUpDueDate),
        'opportunity_type': _blankToNull(input.opportunityType),
        'estimated_value_cents': input.estimatedValueDollars == null
            ? null
            : (input.estimatedValueDollars! * 100).round(),
        'notes': _blankToNull(input.notes),
        'recorded_by': profile.userId,
      }, onConflict: 'meeting_id');

      final meetingPatch = <String, dynamic>{
        'follow_up_owner_id': _blankToNull(input.followUpOwnerId),
        'follow_up_date': _blankToNull(input.followUpDueDate),
        'outcome': _blankToNull(input.outcomeCategory),
      };
      final status = meetingRow['status'] as String?;
      if (input.didMeetingOccur && status != 'canceled' && status != 'no_show') {
        meetingPatch['status'] = 'completed';
      }
      await _client.from('meetings').update(meetingPatch).eq('id', input.meetingId);

      final nextStep = _blankToNull(input.desiredNextStep);
      final ownerId = _blankToNull(input.followUpOwnerId);
      if (nextStep != null && ownerId != null) {
        final existing = await _client.from('tasks').select('id').eq('meeting_id', input.meetingId).maybeSingle();
        final taskPatch = {
          'title': 'Follow up: ${nextStep.substring(0, nextStep.length > 80 ? 80 : nextStep.length)}',
          'description': nextStep,
          'owner_id': ownerId,
          'due_date': _blankToNull(input.followUpDueDate),
        };
        if (existing != null) {
          await _client.from('tasks').update(taskPatch).eq('id', existing['id'] as String);
        } else {
          await _client.from('tasks').insert({
            'org_id': meetingRow['org_id'],
            'campaign_id': meetingRow['campaign_id'],
            'campaign_target_id': meetingRow['campaign_target_id'],
            'meeting_id': input.meetingId,
            'priority': 'medium',
            'created_by': profile.userId,
            ...taskPatch,
          });
        }
      }
    }, 'Could not save the meeting outcome.');
  }

  @override
  Future<void> createTask(CreateTaskInput input, SignedInProfile profile) {
    return _write(() async {
      String? companyId;
      if (input.campaignTargetId != null) {
        final target = await _client
            .from('campaign_targets')
            .select('people(company_id)')
            .eq('id', input.campaignTargetId!)
            .maybeSingle();
        companyId = asMap(target?['people'])?['company_id'] as String?;
      }
      await _client.from('tasks').insert({
        'org_id': profile.orgId,
        'campaign_id': input.campaignId,
        'campaign_target_id': input.campaignTargetId,
        'company_id': companyId,
        'title': input.title.trim(),
        'description': _blankToNull(input.description),
        'owner_id': _blankToNull(input.ownerId),
        'due_date': _blankToNull(input.dueDate),
        'priority': input.priority,
        'created_by': profile.userId,
      });
    }, 'Could not create the task.');
  }

  @override
  Future<void> updateTaskStatus({required String taskId, required String status, required bool isAdmin}) {
    return _write(() async {
      if (status == 'canceled' && !isAdmin) {
        throw const WorkspaceFailure('Only a Mod Squad admin can cancel a task.');
      }
      await _client.from('tasks').update({
        'status': status,
        'completed_at': status == 'completed' ? DateTime.now().toUtc().toIso8601String() : null,
      }).eq('id', taskId);
    }, 'Could not update the task.');
  }

  @override
  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    String? ownerId,
    String? dueDate,
    required String priority,
  }) {
    return _write(() async {
      await _client.from('tasks').update({
        'title': title.trim(),
        'description': _blankToNull(description),
        'owner_id': _blankToNull(ownerId),
        'due_date': _blankToNull(dueDate),
        'priority': priority,
      }).eq('id', taskId);
    }, 'Could not save the task.');
  }

  @override
  Future<void> assignMeetingOwner({required String meetingId, required String? ownerId}) {
    return _write(() async {
      await _client.from('meetings').update({'owner_id': ownerId}).eq('id', meetingId);
    }, 'Could not assign the meeting owner.');
  }

  @override
  Future<void> assignTargetOwner({required String targetId, required String? ownerId}) {
    return _write(() async {
      await _client.from('campaign_targets').update({'owner_id': ownerId}).eq('id', targetId);
    }, 'Could not assign the target owner.');
  }

  @override
  Future<void> setMeetingStatus({required String meetingId, required String status, String? confirmationStatus}) {
    return _write(() async {
      final patch = <String, dynamic>{'status': status};
      if (confirmationStatus != null) patch['confirmation_status'] = confirmationStatus;
      if (status == 'canceled' || status == 'no_show') {
        patch['availability_window_id'] = null;
      }
      await _client.from('meetings').update(patch).eq('id', meetingId);
    }, 'Could not update the meeting.');
  }

  @override
  Future<void> addMeetingNote({required String meetingId, required String note}) {
    return _write(() async {
      await _client.from('meetings').update({'scheduling_notes': note}).eq('id', meetingId);
    }, 'Could not save the note.');
  }

  @override
  Future<IntroRequestResult> createIntroduction(CreateIntroInput input, SignedInProfile profile) {
    return _write(() async {
      final target = await _client
          .from('campaign_targets')
          .select(
            'id, org_id, campaign_id, people(full_name, job_title, companies(name)), campaigns(startup_id, startups(name))',
          )
          .eq('id', input.campaignTargetId)
          .single();
      final targetRow = Map<String, dynamic>.from(target as Map);
      final campaign = asMap(targetRow['campaigns']);
      final startupId = campaign?['startup_id'] as String?;
      if (startupId == null) throw const WorkspaceFailure('This campaign is missing a startup.');
      final person = asMap(targetRow['people']);
      final company = asMap(person?['companies']);

      final intro = await _client
          .from('introduction_requests')
          .insert({
            'org_id': targetRow['org_id'],
            'campaign_id': targetRow['campaign_id'],
            'campaign_target_id': targetRow['id'],
            'startup_id': startupId,
            'introducer_member_id': input.introducerMemberId,
            'requesting_user_id': profile.userId,
            'reason': _blankToNull(input.reason),
            'suggested_language': _blankToNull(input.suggestedLanguage),
            'desired_response_date': _blankToNull(input.desiredResponseDate),
            'status': 'draft',
          })
          .select('id')
          .single();
      final introId = intro['id'] as String;
      final rawToken = mintAdvisorToken();
      final expiresAt = DateTime.now().toUtc().add(const Duration(days: 21)).toIso8601String();
      await _client.from('advisor_access_tokens').insert({
        'org_id': targetRow['org_id'],
        'introduction_request_id': introId,
        'organization_member_id': input.introducerMemberId,
        'token_hash': hashAdvisorToken(rawToken),
        'expires_at': expiresAt,
        'created_by': profile.memberId,
      });
      final message = generateIntroRequestMessage(
        targetFullName: person?['full_name'] as String? ?? 'this person',
        targetJobTitle: person?['job_title'] as String?,
        companyName: company?['name'] as String?,
        startupName: asMap(campaign?['startups'])?['name'] as String? ?? 'the startup',
        reason: input.reason,
        suggestedLanguage: input.suggestedLanguage,
        desiredResponseDate: input.desiredResponseDate,
        responseUrl: '${AppConfig.webBaseUrl}/i/$rawToken',
      );
      return IntroRequestResult(introductionRequestId: introId, message: message);
    }, 'Could not create the introduction request.');
  }

  @override
  Future<void> markIntroductionSent(String introductionRequestId, SignedInProfile profile) {
    return _write(() async {
      await _client
          .from('introduction_requests')
          .update({
            'status': 'requested',
            'sent_at': DateTime.now().toUtc().toIso8601String(),
            'sent_by': profile.memberId,
          })
          .eq('id', introductionRequestId)
          .eq('status', 'draft');
    }, 'Could not mark as sent.');
  }

  @override
  Future<void> addTarget(AddTargetInput input, SignedInProfile profile) {
    return _write(() async {
      final campaign = await _client.from('campaigns').select('org_id').eq('id', input.campaignId).single();
      final orgId = campaign['org_id'] as String? ?? profile.orgId;
      String? companyId;
      final companyName = _blankToNull(input.companyName);
      if (companyName != null) {
        final existing = await _client
            .from('companies')
            .select('id')
            .ilike('name', companyName)
            .isFilter('deleted_at', null)
            .limit(1)
            .maybeSingle();
        if (existing != null) {
          companyId = existing['id'] as String;
        } else {
          final created = await _client
              .from('companies')
              .insert({'org_id': orgId, 'name': companyName})
              .select('id')
              .single();
          companyId = created['id'] as String;
        }
      }

      String? personId;
      final email = _blankToNull(input.email);
      if (email != null) {
        final existingPerson = await _client
            .from('people')
            .select('id')
            .ilike('email', email)
            .isFilter('deleted_at', null)
            .limit(1)
            .maybeSingle();
        personId = existingPerson?['id'] as String?;
      }
      if (personId == null) {
        final createdPerson = await _client
            .from('people')
            .insert({
              'org_id': orgId,
              'full_name': input.fullName.trim(),
              'job_title': _blankToNull(input.jobTitle),
              'company_id': companyId,
              'email': email,
              'source': 'Mobile add',
              'tags': ['mobile-add'],
            })
            .select('id')
            .single();
        personId = createdPerson['id'] as String;
      }

      final already = await _client
          .from('campaign_targets')
          .select('id')
          .eq('campaign_id', input.campaignId)
          .eq('person_id', personId)
          .isFilter('deleted_at', null)
          .maybeSingle();
      if (already != null) {
        throw const WorkspaceFailure('That person is already a target in this campaign.');
      }

      await _client.from('campaign_targets').insert({
        'org_id': orgId,
        'campaign_id': input.campaignId,
        'person_id': personId,
        'status': 'imported',
        'owner_id': _blankToNull(input.ownerId),
      });
    }, 'Could not add the target.');
  }

  @override
  Future<void> addAvailabilityWindow(CreateAvailabilityInput input, SignedInProfile profile) {
    return _write(() async {
      if (input.endTime.compareTo(input.startTime) <= 0) {
        throw const WorkspaceFailure('End time must be after start time.');
      }
      await _client.from('availability_windows').insert({
        'org_id': profile.orgId,
        'campaign_id': input.campaignId,
        'member_id': profile.isAdmin ? null : profile.memberId,
        'team_label': profile.isAdmin ? 'Mod Squad' : null,
        'window_date': input.windowDate,
        'start_time': input.startTime,
        'end_time': input.endTime,
        'timezone': input.timezone,
        'location': _blankToNull(input.location),
        'capacity': input.capacity,
        'created_by': profile.userId,
      });
    }, 'Could not create the availability window.');
  }
}
