const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String formatDate(String? value) {
  if (value == null || value.isEmpty) return 'Not set';
  final date = value.length >= 10 ? value.substring(0, 10) : value;
  final parts = date.split('-');
  if (parts.length != 3) return value;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null || month < 1 || month > 12) return value;
  return '${months[month - 1]} $day, $year';
}

String formatTimestamp(DateTime? value) {
  if (value == null) return 'Not set';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${formatDate(local.toIso8601String())} $hour:$minute';
}

String formatMoney(int? cents) {
  if (cents == null) return 'Not set';
  final dollars = cents / 100;
  if (dollars >= 1000000) return '\$${(dollars / 1000000).toStringAsFixed(1)}M';
  if (dollars >= 1000) return '\$${(dollars / 1000).toStringAsFixed(1)}K';
  return '\$${dollars.toStringAsFixed(0)}';
}
