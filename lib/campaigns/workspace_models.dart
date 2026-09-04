class CampaignTarget {
  const CampaignTarget({
    required this.id,
    required this.status,
    required this.score,
    required this.scoreCategory,
    required this.scoreExplanation,
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.linkedinUrl,
    required this.city,
    required this.companyName,
    required this.tags,
    required this.doNotContact,
    this.ownerId,
    this.ownerName,
  });

  final String id;
  final String status;
  final num? score;
  final String? scoreCategory;
  final String? scoreExplanation;
  final String fullName;
  final String? jobTitle;
  final String? email;
  final String? phone;
  final String? linkedinUrl;
  final String? city;
  final String? companyName;
  final List<String> tags;
  final bool doNotContact;
  final String? ownerId;
  final String? ownerName;
}

class CampaignCompany {
  const CampaignCompany({
    required this.id,
    required this.name,
    required this.domain,
    required this.tags,
    required this.targetCount,
  });

  final String id;
  final String name;
  final String? domain;
  final List<String> tags;
  final int targetCount;
}

class CampaignIntroduction {
  const CampaignIntroduction({
    required this.id,
    required this.status,
    required this.reason,
    required this.targetPersonName,
    required this.companyName,
    required this.introducerName,
    required this.sentAt,
    required this.advisorNote,
  });

  final String id;
  final String status;
  final String? reason;
  final String targetPersonName;
  final String? companyName;
  final String introducerName;
  final String? sentAt;
  final String? advisorNote;
}

class CampaignOutreach {
  const CampaignOutreach({
    required this.id,
    required this.channel,
    required this.subject,
    required this.content,
    required this.status,
    required this.targetPersonName,
    required this.companyName,
    required this.followUpDate,
  });

  final String id;
  final String channel;
  final String? subject;
  final String? content;
  final String status;
  final String targetPersonName;
  final String? companyName;
  final String? followUpDate;
}

class AvailabilityWindow {
  const AvailabilityWindow({
    required this.id,
    required this.windowDate,
    required this.startTime,
    required this.endTime,
    required this.timezone,
    required this.location,
    required this.capacity,
    required this.memberName,
  });

  final String id;
  final String windowDate;
  final String startTime;
  final String endTime;
  final String timezone;
  final String? location;
  final int capacity;
  final String? memberName;
}

class CampaignMeeting {
  const CampaignMeeting({
    required this.id,
    required this.targetPersonName,
    required this.companyName,
    required this.startAt,
    required this.timezone,
    required this.location,
    required this.format,
    required this.status,
    required this.confirmationStatus,
    required this.outcome,
    required this.ownerName,
    required this.schedulingNotes,
    this.ownerId,
    this.campaignTargetId,
  });

  final String id;
  final String targetPersonName;
  final String? companyName;
  final String? startAt;
  final String timezone;
  final String? location;
  final String format;
  final String status;
  final String confirmationStatus;
  final String? outcome;
  final String? ownerName;
  final String? schedulingNotes;
  final String? ownerId;
  final String? campaignTargetId;
}

class CampaignTask {
  const CampaignTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.ownerName,
    required this.targetPersonName,
    required this.companyName,
    this.ownerId,
    this.campaignTargetId,
  });

  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? dueDate;
  final String? ownerName;
  final String? targetPersonName;
  final String? companyName;
  final String? ownerId;
  final String? campaignTargetId;
}

class CampaignOpportunity {
  const CampaignOpportunity({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.stage,
    required this.opportunityType,
    required this.estimatedValueCents,
    required this.probability,
    required this.nextStep,
    required this.nextStepDate,
    required this.notes,
    required this.ownerName,
  });

  final String id;
  final String? companyName;
  final String? contactName;
  final String stage;
  final String? opportunityType;
  final int? estimatedValueCents;
  final num? probability;
  final String? nextStep;
  final String? nextStepDate;
  final String? notes;
  final String? ownerName;
}

class ScoringRule {
  const ScoringRule({
    required this.id,
    required this.category,
    required this.weight,
    required this.isActive,
  });

  final String id;
  final String category;
  final num weight;
  final bool isActive;
}

class CampaignWorkspace {
  const CampaignWorkspace({
    required this.targets,
    required this.companies,
    required this.introductions,
    required this.outreach,
    required this.windows,
    required this.meetings,
    required this.tasks,
    required this.opportunities,
    required this.scoringRules,
  });

  final List<CampaignTarget> targets;
  final List<CampaignCompany> companies;
  final List<CampaignIntroduction> introductions;
  final List<CampaignOutreach> outreach;
  final List<AvailabilityWindow> windows;
  final List<CampaignMeeting> meetings;
  final List<CampaignTask> tasks;
  final List<CampaignOpportunity> opportunities;
  final List<ScoringRule> scoringRules;
}

const emptyWorkspace = CampaignWorkspace(
  targets: [],
  companies: [],
  introductions: [],
  outreach: [],
  windows: [],
  meetings: [],
  tasks: [],
  opportunities: [],
  scoringRules: [],
);
