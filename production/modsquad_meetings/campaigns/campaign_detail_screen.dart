import 'package:flutter/material.dart';
import 'package:modsquad_meetings/campaigns/campaigns_repository.dart';
import 'package:modsquad_meetings/shared/campaign_status_chip.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({super.key, required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.foreground,
        surfaceTintColor: Colors.transparent,
        title: const Text('Campaign', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  campaign.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2),
                ),
              ),
              const SizedBox(width: 8),
              CampaignStatusChip(status: campaign.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            campaign.startupName ?? 'Startup',
            style: const TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _SectionCard(
            title: 'Event details',
            children: [
              _Field(label: 'Event name', value: campaign.eventName ?? 'Not set'),
              _Field(label: 'City', value: campaign.eventCity ?? 'Not set'),
              _Field(label: 'Venue', value: campaign.eventVenue ?? 'Not set'),
              _Field(label: 'Timezone', value: campaign.timezone),
              _Field(label: 'Start date', value: _formatDate(campaign.startDate)),
              _Field(label: 'End date', value: _formatDate(campaign.endDate)),
              if (!campaign.datesConfirmed)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Dates and venue are placeholders until confirmed — do not treat as verified event facts.',
                    style: TextStyle(color: AppColors.warning, fontSize: 12, height: 1.35),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Campaign configuration',
            children: [
              _Field(label: 'Startup', value: campaign.startupName ?? 'Unknown'),
              _Field(
                label: 'Target meeting goal',
                value: campaign.targetMeetingGoal?.toString() ?? 'Not set',
              ),
              _Field(
                label: 'Target meeting types',
                value: campaign.targetMeetingTypes.isEmpty ? 'Not set' : campaign.targetMeetingTypes.join(', '),
              ),
              _Field(
                label: 'Target account list',
                value: campaign.targetAccountList.isEmpty
                    ? 'Not set'
                    : '${campaign.targetAccountList.length} accounts',
              ),
              if (campaign.notes != null && campaign.notes!.isNotEmpty)
                _Field(label: 'Notes', value: campaign.notes!),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3)),
        ],
      ),
    );
  }
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _formatDate(String? value) {
  if (value == null || value.isEmpty) return 'Not set';
  final date = value.length >= 10 ? value.substring(0, 10) : value;
  final parts = date.split('-');
  if (parts.length != 3) return value;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null || month < 1 || month > 12) return value;
  return '${_months[month - 1]} $day, $year';
}
