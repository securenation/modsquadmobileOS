import 'package:flutter/material.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

const campaignStatusLabels = {
  'draft': 'Draft',
  'planning': 'Planning',
  'targeting': 'Targeting',
  'outreach': 'Outreach',
  'scheduling': 'Scheduling',
  'live': 'Live',
  'follow_up': 'Follow-up',
  'completed': 'Completed',
  'archived': 'Archived',
};

class CampaignStatusChip extends StatelessWidget {
  const CampaignStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final live = status == 'live';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: live ? AppColors.success.withValues(alpha: 0.15) : AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: live ? AppColors.success : AppColors.border),
      ),
      child: Text(
        campaignStatusLabels[status] ?? status,
        style: TextStyle(
          color: live ? AppColors.success : AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
