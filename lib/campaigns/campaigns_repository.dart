import 'package:modsquad_meetings/auth/signed_in_profile.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';
import 'package:modsquad_meetings/startups/startups_repository.dart';

class WorkspaceFailure implements Exception {
  const WorkspaceFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class OwnerOption {
  const OwnerOption({required this.memberId, required this.name, required this.role});

  final String memberId;
  final String name;
  final String role;
}

class CreateCampaignInput {
  const CreateCampaignInput({
    required this.name,
    required this.startupId,
    this.eventName,
    this.eventCity,
    this.targetMeetingGoal,
  });

  final String name;
  final String startupId;
  final String? eventName;
  final String? eventCity;
  final int? targetMeetingGoal;
}

class MeetingOutcomeInput {
  const MeetingOutcomeInput({
    required this.meetingId,
    required this.didMeetingOccur,
    this.attendeesActual,
    this.interestLevel,
    this.problemsDiscussed,
    this.existingTools,
    this.buyingProcess,
    this.productFeedback,
    this.objections,
    this.desiredNextStep,
    this.followUpOwnerId,
    this.followUpDueDate,
    this.opportunityType,
    this.estimatedValueDollars,
    this.outcomeCategory,
    this.notes,
  });

  final String meetingId;
  final bool didMeetingOccur;
  final String? attendeesActual;
  final String? interestLevel;
  final String? problemsDiscussed;
  final String? existingTools;
  final String? buyingProcess;
  final String? productFeedback;
  final String? objections;
  final String? desiredNextStep;
  final String? followUpOwnerId;
  final String? followUpDueDate;
  final String? opportunityType;
  final double? estimatedValueDollars;
  final String? outcomeCategory;
  final String? notes;
}

class CreateTaskInput {
  const CreateTaskInput({
    required this.campaignId,
    required this.title,
    this.description,
    this.campaignTargetId,
    this.ownerId,
    this.dueDate,
    this.priority = 'medium',
  });

  final String campaignId;
  final String title;
  final String? description;
  final String? campaignTargetId;
  final String? ownerId;
  final String? dueDate;
  final String priority;
}

class CreateIntroInput {
  const CreateIntroInput({
    required this.campaignTargetId,
    required this.introducerMemberId,
    this.reason,
    this.suggestedLanguage,
    this.desiredResponseDate,
  });

  final String campaignTargetId;
  final String introducerMemberId;
  final String? reason;
  final String? suggestedLanguage;
  final String? desiredResponseDate;
}

class IntroRequestResult {
  const IntroRequestResult({required this.introductionRequestId, required this.message});

  final String introductionRequestId;
  final String message;
}

class AddTargetInput {
  const AddTargetInput({
    required this.campaignId,
    required this.fullName,
    this.jobTitle,
    this.email,
    this.companyName,
    this.ownerId,
  });

  final String campaignId;
  final String fullName;
  final String? jobTitle;
  final String? email;
  final String? companyName;
  final String? ownerId;
}

class CreateAvailabilityInput {
  const CreateAvailabilityInput({
    required this.campaignId,
    required this.windowDate,
    required this.startTime,
    required this.endTime,
    required this.timezone,
    this.location,
    this.capacity = 1,
  });

  final String campaignId;
  final String windowDate;
  final String startTime;
  final String endTime;
  final String timezone;
  final String? location;
  final int capacity;
}

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
    this.orgId = '',
    this.startupId = '',
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
  final String orgId;
  final String startupId;
}

abstract class CampaignsRepository {
  Future<List<Campaign>> listCampaigns();
  Future<CampaignWorkspace> loadWorkspace(String campaignId);
  Future<List<OwnerOption>> listOwners();
  Future<Campaign> createCampaign(CreateCampaignInput input, SignedInProfile profile);
  Future<void> recordMeetingOutcome(MeetingOutcomeInput input, SignedInProfile profile);
  Future<void> createTask(CreateTaskInput input, SignedInProfile profile);
  Future<void> updateTaskStatus({required String taskId, required String status, required bool isAdmin});
  Future<void> updateTask({required String taskId, required String title, String? description, String? ownerId, String? dueDate, required String priority});
  Future<void> assignMeetingOwner({required String meetingId, required String? ownerId});
  Future<void> assignTargetOwner({required String targetId, required String? ownerId});
  Future<void> setMeetingStatus({required String meetingId, required String status, String? confirmationStatus});
  Future<void> addMeetingNote({required String meetingId, required String note});
  Future<IntroRequestResult> createIntroduction(CreateIntroInput input, SignedInProfile profile);
  Future<void> markIntroductionSent(String introductionRequestId, SignedInProfile profile);
  Future<void> addTarget(AddTargetInput input, SignedInProfile profile);
  Future<void> addAvailabilityWindow(CreateAvailabilityInput input, SignedInProfile profile);
}

extension StartupOptions on List<Startup> {
  List<(String, String)> asSelectOptions() => [for (final startup in this) (startup.id, startup.name)];
}
