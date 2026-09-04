import 'package:flutter/material.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  static const height = 44.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      primary: false,
      toolbarHeight: height,
      titleSpacing: 16,
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.foreground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      actions: actions,
    );
  }
}
