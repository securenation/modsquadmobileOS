import 'package:modsquad_meetings/campaigns/workspace_models.dart';

const opportunityStageOrder = [
  'identified',
  'discovery',
  'evaluation',
  'design_partner',
  'proof_of_concept',
  'commercial_discussion',
  'verbal_commitment',
  'won',
  'lost',
  'nurture',
];

class OpportunityReport {
  const OpportunityReport({
    required this.totalCount,
    required this.openCount,
    required this.wonCount,
    required this.lostCount,
    required this.openValueCents,
    required this.wonValueCents,
    required this.weightedPipelineCents,
    required this.stageCounts,
  });

  final int totalCount;
  final int openCount;
  final int wonCount;
  final int lostCount;
  final int openValueCents;
  final int wonValueCents;
  final int weightedPipelineCents;
  final Map<String, int> stageCounts;
}

OpportunityReport computeOpportunityReport(List<CampaignOpportunity> opportunities) {
  final stageCounts = {for (final stage in opportunityStageOrder) stage: 0};
  var openValue = 0;
  var wonValue = 0;
  var weighted = 0;
  var openCount = 0;
  var wonCount = 0;
  var lostCount = 0;

  for (final opportunity in opportunities) {
    stageCounts[opportunity.stage] = (stageCounts[opportunity.stage] ?? 0) + 1;
    final value = opportunity.estimatedValueCents ?? 0;
    if (opportunity.stage == 'won') {
      wonCount += 1;
      wonValue += value;
    } else if (opportunity.stage == 'lost') {
      lostCount += 1;
    } else {
      openCount += 1;
      openValue += value;
      final probability = opportunity.probability;
      if (opportunity.estimatedValueCents != null && probability != null) {
        weighted += ((opportunity.estimatedValueCents! * probability) / 100).round();
      }
    }
  }

  return OpportunityReport(
    totalCount: opportunities.length,
    openCount: openCount,
    wonCount: wonCount,
    lostCount: lostCount,
    openValueCents: openValue,
    wonValueCents: wonValue,
    weightedPipelineCents: weighted,
    stageCounts: stageCounts,
  );
}
