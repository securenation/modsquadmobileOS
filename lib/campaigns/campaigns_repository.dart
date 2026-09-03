import 'package:modsquad_meetings/campaigns/workspace_models.dart';

class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.status,
    required this.startupName,
    required this.eventName,
    required this.eventCity,
    required this.eventVenue,
    required this.startDate,
    required this.endDate,
    required this.timezone,
    required this.targetMeetingGoal,
    required this.targetMeetingTypes,
    required this.targetAccountList,
    required this.datesConfirmed,
    required this.notes,
  });

  final String id;
  final String name;
  final String status;
  final String? startupName;
  final String? eventName;
  final String? eventCity;
  final String? eventVenue;
  final String? startDate;
  final String? endDate;
  final String timezone;
  final int? targetMeetingGoal;
  final List<String> targetMeetingTypes;
  final List<String> targetAccountList;
  final bool datesConfirmed;
  final String? notes;
}

abstract class CampaignsRepository {
  Future<List<Campaign>> listCampaigns();
  Future<CampaignWorkspace> loadWorkspace(String campaignId);
}
