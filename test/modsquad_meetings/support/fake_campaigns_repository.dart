import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/intro_message.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';

class FakeCampaignsRepository implements CampaignsRepository {
  FakeCampaignsRepository({
    this.campaigns = const [],
    this.workspace = emptyWorkspace,
    this.error,
    this.owners = const [OwnerOption(memberId: 'mem1', name: 'Priya Natarajan', role: 'mod_squad_admin')],
  });

  List<Campaign> campaigns;
  CampaignWorkspace workspace;
  Object? error;
  List<OwnerOption> owners;
  final recordedOutcomes = <MeetingOutcomeInput>[];
  final createdTasks = <CreateTaskInput>[];
  final createdIntros = <CreateIntroInput>[];
  int introSentCount = 0;

  void _throwIfNeeded() {
    final thrown = error;
    if (thrown != null) throw thrown;
  }

  @override
  Future<List<Campaign>> listCampaigns() async {
    _throwIfNeeded();
    return campaigns;
  }

  @override
  Future<CampaignWorkspace> loadWorkspace(String campaignId) async {
    _throwIfNeeded();
    return workspace;
  }

  @override
  Future<List<OwnerOption>> listOwners() async {
    _throwIfNeeded();
    return owners;
  }

  @override
  Future<Campaign> createCampaign(CreateCampaignInput input, SignedInProfile profile) async {
    _throwIfNeeded();
    final campaign = sampleCampaign(id: 'new-${campaigns.length + 1}', name: input.name);
    campaigns = [...campaigns, campaign];
    return campaign;
  }

  @override
  Future<void> recordMeetingOutcome(MeetingOutcomeInput input, SignedInProfile profile) async {
    _throwIfNeeded();
    if (input.didMeetingOccur && (input.outcomeCategory == null || input.outcomeCategory!.isEmpty)) {
      throw const WorkspaceFailure("Choose what this meeting's outcome was.");
    }
    recordedOutcomes.add(input);
    workspace = CampaignWorkspace(
      targets: workspace.targets,
      companies: workspace.companies,
      introductions: workspace.introductions,
      outreach: workspace.outreach,
      windows: workspace.windows,
      meetings: [
        for (final meeting in workspace.meetings)
          if (meeting.id == input.meetingId)
            CampaignMeeting(
              id: meeting.id,
              targetPersonName: meeting.targetPersonName,
              companyName: meeting.companyName,
              startAt: meeting.startAt,
              timezone: meeting.timezone,
              location: meeting.location,
              format: meeting.format,
              status: input.didMeetingOccur ? 'completed' : meeting.status,
              confirmationStatus: meeting.confirmationStatus,
              outcome: input.outcomeCategory,
              ownerName: meeting.ownerName,
              schedulingNotes: meeting.schedulingNotes,
              ownerId: meeting.ownerId,
              campaignTargetId: meeting.campaignTargetId,
            )
          else
            meeting,
      ],
      tasks: workspace.tasks,
      opportunities: workspace.opportunities,
      scoringRules: workspace.scoringRules,
    );
  }

  @override
  Future<void> createTask(CreateTaskInput input, SignedInProfile profile) async {
    _throwIfNeeded();
    createdTasks.add(input);
    workspace = CampaignWorkspace(
      targets: workspace.targets,
      companies: workspace.companies,
      introductions: workspace.introductions,
      outreach: workspace.outreach,
      windows: workspace.windows,
      meetings: workspace.meetings,
      tasks: [
        ...workspace.tasks,
        CampaignTask(
          id: 'task-${workspace.tasks.length + 1}',
          title: input.title,
          description: input.description,
          status: 'open',
          priority: input.priority,
          dueDate: input.dueDate,
          ownerName: owners.where((owner) => owner.memberId == input.ownerId).firstOrNull?.name,
          targetPersonName: workspace.targets.where((target) => target.id == input.campaignTargetId).firstOrNull?.fullName,
          companyName: null,
          ownerId: input.ownerId,
          campaignTargetId: input.campaignTargetId,
        ),
      ],
      opportunities: workspace.opportunities,
      scoringRules: workspace.scoringRules,
    );
  }

  @override
  Future<void> updateTaskStatus({required String taskId, required String status, required bool isAdmin}) async {
    _throwIfNeeded();
    if (status == 'canceled' && !isAdmin) {
      throw const WorkspaceFailure('Only a Mod Squad admin can cancel a task.');
    }
  }

  @override
  Future<void> updateTask({
    required String taskId,
    required String title,
    String? description,
    String? ownerId,
    String? dueDate,
    required String priority,
  }) async {
    _throwIfNeeded();
  }

  @override
  Future<void> assignMeetingOwner({required String meetingId, required String? ownerId}) async {
    _throwIfNeeded();
  }

  @override
  Future<void> assignTargetOwner({required String targetId, required String? ownerId}) async {
    _throwIfNeeded();
  }

  @override
  Future<void> setMeetingStatus({required String meetingId, required String status, String? confirmationStatus}) async {
    _throwIfNeeded();
  }

  @override
  Future<void> addMeetingNote({required String meetingId, required String note}) async {
    _throwIfNeeded();
  }

  @override
  Future<IntroRequestResult> createIntroduction(CreateIntroInput input, SignedInProfile profile) async {
    _throwIfNeeded();
    createdIntros.add(input);
    return IntroRequestResult(
      introductionRequestId: 'intro-${createdIntros.length}',
      message: generateIntroRequestMessage(
        targetFullName: 'Elena Vasquez',
        startupName: 'Dante Security',
        reason: input.reason,
        responseUrl: 'http://localhost:3000/i/token',
      ),
    );
  }

  @override
  Future<void> markIntroductionSent(String introductionRequestId, SignedInProfile profile) async {
    _throwIfNeeded();
    introSentCount += 1;
  }

  @override
  Future<void> addTarget(AddTargetInput input, SignedInProfile profile) async {
    _throwIfNeeded();
    workspace = CampaignWorkspace(
      targets: [
        ...workspace.targets,
        CampaignTarget(
          id: 't-${workspace.targets.length + 1}',
          status: 'imported',
          score: null,
          scoreCategory: null,
          scoreExplanation: null,
          fullName: input.fullName,
          jobTitle: input.jobTitle,
          email: input.email,
          phone: null,
          linkedinUrl: null,
          city: null,
          companyName: input.companyName,
          tags: const [],
          doNotContact: false,
          ownerId: input.ownerId,
        ),
      ],
      companies: workspace.companies,
      introductions: workspace.introductions,
      outreach: workspace.outreach,
      windows: workspace.windows,
      meetings: workspace.meetings,
      tasks: workspace.tasks,
      opportunities: workspace.opportunities,
      scoringRules: workspace.scoringRules,
    );
  }

  @override
  Future<void> addAvailabilityWindow(CreateAvailabilityInput input, SignedInProfile profile) async {
    _throwIfNeeded();
  }
}

Campaign sampleCampaign({
  String id = 'c1',
  String name = 'Dante @ Black Hat',
  String status = 'live',
}) {
  return Campaign(
    id: id,
    name: name,
    status: status,
    startupName: 'Dante Security',
    eventName: 'Black Hat USA',
    eventCity: 'Las Vegas',
    eventVenue: 'Mandalay Bay',
    startDate: '2026-08-01',
    endDate: '2026-08-06',
    timezone: 'America/Los_Angeles',
    targetMeetingGoal: 40,
    targetMeetingTypes: const ['enterprise_sales', 'design_partner'],
    targetAccountList: const ['acme.com', 'northwind.com'],
    datesConfirmed: true,
    notes: 'Focus on CISO intros.',
    orgId: 'org1',
    startupId: 's1',
  );
}

final sampleWorkspace = CampaignWorkspace(
  targets: [
    CampaignTarget(
      id: 't1',
      status: 'qualified',
      score: 86,
      scoreCategory: 'high',
      scoreExplanation: 'CISO at a bank in the ICP.',
      fullName: 'Elena Vasquez',
      jobTitle: 'CISO',
      email: 'elena@meridian.test',
      phone: null,
      linkedinUrl: null,
      city: 'Austin',
      companyName: 'Meridian Health',
      tags: ['ciso'],
      doNotContact: false,
    ),
  ],
  companies: [
    CampaignCompany(id: 'co1', name: 'Meridian Health', domain: 'meridian.test', tags: const [], targetCount: 1),
  ],
  introductions: [
    CampaignIntroduction(
      id: 'i1',
      status: 'requested',
      reason: 'Warm intro to CISO',
      targetPersonName: 'Elena Vasquez',
      companyName: 'Meridian Health',
      introducerName: 'R. Patel',
      sentAt: '2026-08-01',
      advisorNote: null,
    ),
  ],
  outreach: const [],
  windows: [
    AvailabilityWindow(
      id: 'w1',
      windowDate: '2026-08-04',
      startTime: '09:00',
      endTime: '09:30',
      timezone: 'America/Los_Angeles',
      location: 'Expo Hall B',
      capacity: 1,
      memberName: 'Dante',
    ),
  ],
  meetings: [
    CampaignMeeting(
      id: 'm1',
      targetPersonName: 'Elena Vasquez',
      companyName: 'Meridian Health',
      startAt: '2026-08-04T16:00:00Z',
      timezone: 'America/Los_Angeles',
      location: 'Expo Hall B',
      format: 'in_person',
      status: 'confirmed',
      confirmationStatus: 'confirmed',
      outcome: null,
      ownerName: 'Dante',
      schedulingNotes: null,
    ),
  ],
  tasks: const [],
  opportunities: [
    CampaignOpportunity(
      id: 'o1',
      companyName: 'Meridian Health',
      contactName: 'Elena Vasquez',
      stage: 'discovery',
      opportunityType: 'enterprise_sales',
      estimatedValueCents: 25000000,
      probability: 40,
      nextStep: 'Send recap',
      nextStepDate: '2026-08-08',
      notes: null,
      ownerName: 'Dante',
    ),
  ],
  scoringRules: const [],
);
