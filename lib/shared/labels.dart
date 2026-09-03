import 'package:modsquad_meetings/shared/json.dart';

const targetStatusLabels = {
  'imported': 'Imported',
  'needs_review': 'Needs review',
  'qualified': 'Qualified',
  'high_priority': 'High priority',
  'assigned': 'Assigned',
  'introduction_available': 'Introduction available',
  'introduction_requested': 'Introduction requested',
  'ready_for_outreach': 'Ready for outreach',
  'contacted': 'Contacted',
  'responded': 'Responded',
  'interested': 'Interested',
  'scheduling': 'Scheduling',
  'confirmed': 'Confirmed',
  'completed': 'Completed',
  'follow_up_required': 'Follow-up required',
  'opportunity_created': 'Opportunity created',
  'nurture': 'Nurture',
  'not_a_fit': 'Not a fit',
  'do_not_contact': 'Do not contact',
};

const scoreCategoryLabels = {
  'critical': 'Critical',
  'high': 'High',
  'qualified': 'Qualified',
  'secondary': 'Secondary',
  'low': 'Low',
};

const introductionStatusLabels = {
  'draft': 'Draft',
  'requested': 'Needs advisor response',
  'viewed': 'Viewed by advisor',
  'accepted': 'Accepted',
  'declined': 'Declined',
  'needs_more_context': 'Advisor asked for more context',
  'suggested_alternative': 'Advisor suggested someone else',
  'introduction_sent': 'Introduction sent',
  'target_responded': 'Target responded',
  'meeting_scheduled': 'Meeting scheduled',
  'completed': 'Completed',
  'closed': 'Closed',
};

const outreachStatusLabels = {
  'draft': 'Draft',
  'logged': 'Logged',
  'no_response': 'No response',
  'responded': 'Responded',
  'opted_out': 'Opted out',
};

const meetingStatusLabels = {
  'proposed': 'Proposed',
  'tentative': 'Tentative',
  'awaiting_confirmation': 'Awaiting confirmation',
  'confirmed': 'Confirmed',
  'rescheduled': 'Rescheduled',
  'completed': 'Completed',
  'canceled': 'Canceled',
  'no_show': 'No-show',
};

const taskStatusLabels = {
  'open': 'Open',
  'in_progress': 'In progress',
  'waiting': 'Waiting',
  'completed': 'Completed',
  'canceled': 'Canceled',
};

const taskPriorityLabels = {
  'low': 'Low',
  'medium': 'Medium',
  'high': 'High',
  'urgent': 'Urgent',
};

const opportunityStageLabels = {
  'identified': 'Identified',
  'discovery': 'Discovery',
  'evaluation': 'Evaluation',
  'design_partner': 'Design partner',
  'proof_of_concept': 'Proof of concept',
  'commercial_discussion': 'Commercial discussion',
  'verbal_commitment': 'Verbal commitment',
  'won': 'Won',
  'lost': 'Lost',
  'nurture': 'Nurture',
};

String labelFor(Map<String, String> labels, String? value, [String fallback = 'Not set']) {
  if (value == null || value.isEmpty) return fallback;
  return labels[value] ?? humanize(value);
}
