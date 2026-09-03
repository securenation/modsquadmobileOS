import 'package:flutter/material.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.emphasis = ChipEmphasis.neutral});

  final String label;
  final ChipEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final color = switch (emphasis) {
      ChipEmphasis.success => AppColors.success,
      ChipEmphasis.warning => AppColors.warning,
      ChipEmphasis.danger => AppColors.destructive,
      ChipEmphasis.neutral => AppColors.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: emphasis == ChipEmphasis.neutral ? 0 : 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: emphasis == ChipEmphasis.neutral ? AppColors.border : color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum ChipEmphasis { neutral, success, warning, danger }
