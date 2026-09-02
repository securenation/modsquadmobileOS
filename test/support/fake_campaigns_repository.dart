import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';

class FakeCampaignsRepository implements CampaignsRepository {
  FakeCampaignsRepository({this.campaigns = const [], this.error});

  List<Campaign> campaigns;
  Object? error;

  @override
  Future<List<Campaign>> listCampaigns() async {
    final thrown = error;
    if (thrown != null) throw thrown;
    return campaigns;
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
