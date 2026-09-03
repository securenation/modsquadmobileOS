import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/campaigns/reports.dart';
import 'package:modsquad_meetings/campaigns/workspace_models.dart';

void main() {
  test('rolls opportunity stages into pipeline totals', () {
    final report = computeOpportunityReport(const [
      CampaignOpportunity(
        id: '1',
        companyName: 'A',
        contactName: null,
        stage: 'discovery',
        opportunityType: null,
        estimatedValueCents: 100000,
        probability: 50,
        nextStep: null,
        nextStepDate: null,
        notes: null,
        ownerName: null,
      ),
      CampaignOpportunity(
        id: '2',
        companyName: 'B',
        contactName: null,
        stage: 'won',
        opportunityType: null,
        estimatedValueCents: 400000,
        probability: 100,
        nextStep: null,
        nextStepDate: null,
        notes: null,
        ownerName: null,
      ),
      CampaignOpportunity(
        id: '3',
        companyName: 'C',
        contactName: null,
        stage: 'lost',
        opportunityType: null,
        estimatedValueCents: 900000,
        probability: 10,
        nextStep: null,
        nextStepDate: null,
        notes: null,
        ownerName: null,
      ),
    ]);

    expect(report.totalCount, 3);
    expect(report.openCount, 1);
    expect(report.wonCount, 1);
    expect(report.lostCount, 1);
    expect(report.openValueCents, 100000);
    expect(report.wonValueCents, 400000);
    expect(report.weightedPipelineCents, 50000);
    expect(report.stageCounts['discovery'], 1);
  });
}
