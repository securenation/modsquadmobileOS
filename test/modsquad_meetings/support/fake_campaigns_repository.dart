import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';

class FakeCampaignsRepository implements CampaignsRepository {
  FakeCampaignsRepository({this.campaigns = const [], this.workspace = emptyWorkspace, this.error});

  List<Campaign> campaigns;
  CampaignWorkspace workspace;
  Object? error;

  @override
  Future<List<Campaign>> listCampaigns() async {
    final thrown = error;
    if (thrown != null) throw thrown;
    return campaigns;
  }

  @override
  Future<CampaignWorkspace> loadWorkspace(String campaignId) async {
    final thrown = error;
    if (thrown != null) throw thrown;
    return workspace;
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
