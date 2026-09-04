import 'package:flutter/material.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.title,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
    this.submitting = false,
    this.error,
  });

  final String title;
  final List<Widget> children;
  final String submitLabel;
  final VoidCallback? onSubmit;
  final bool submitting;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.foreground,
        surfaceTintColor: Colors.transparent,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          ...children,
          if (error != null && error!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: AppColors.destructive, fontSize: 13, height: 1.35)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: submitting ? null : onSubmit,
            child: submitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink))
                : Text(submitLabel),
          ),
        ],
      ),
    );
  }
}

class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class OptionField extends StatelessWidget {
  const OptionField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Select',
  });

  final String? value;
  final List<(String, String)> options;
  final ValueChanged<String?> onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final selected = options.any((option) => option.$1 == value) ? value : null;
    return DropdownButtonFormField<String>(
      key: ValueKey(selected),
      initialValue: selected,
      isExpanded: true,
      hint: Text(placeholder),
      dropdownColor: AppColors.card,
      items: [
        for (final option in options)
          DropdownMenuItem(value: option.$1, child: Text(option.$2, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: onChanged,
    );
  }
}

Future<String?> pickDate(BuildContext context, {String? initial}) async {
  final now = DateTime.now();
  DateTime parsed = now;
  if (initial != null && initial.length >= 10) {
    parsed = DateTime.tryParse(initial.substring(0, 10)) ?? now;
  }
  final picked = await showDatePicker(
    context: context,
    initialDate: parsed,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 3),
  );
  if (picked == null) return null;
  final month = picked.month.toString().padLeft(2, '0');
  final day = picked.day.toString().padLeft(2, '0');
  return '${picked.year}-$month-$day';
}

Future<String?> pickTime(BuildContext context, {String? initial}) async {
  var time = const TimeOfDay(hour: 9, minute: 0);
  if (initial != null && initial.contains(':')) {
    final parts = initial.split(':');
    time = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts[1]) ?? 0);
  }
  final picked = await showTimePicker(context: context, initialTime: time);
  if (picked == null) return null;
  return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
}

class DateFieldButton extends StatelessWidget {
  const DateFieldButton({super.key, required this.value, required this.onPicked});

  final String? value;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await pickDate(context, initial: value);
        if (picked != null) onPicked(picked);
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(value == null || value!.isEmpty ? 'Pick a date' : value!),
      ),
    );
  }
}

class TimeFieldButton extends StatelessWidget {
  const TimeFieldButton({super.key, required this.value, required this.onPicked});

  final String? value;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await pickTime(context, initial: value);
        if (picked != null) onPicked(picked);
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(value == null || value!.isEmpty ? 'Pick a time' : value!),
      ),
    );
  }
}
