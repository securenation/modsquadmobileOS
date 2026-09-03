Map<String, dynamic>? asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List && value.isNotEmpty) return asMap(value.first);
  return null;
}

List<String> asStringList(dynamic value) {
  if (value is List) return value.map((item) => item.toString()).toList();
  return const [];
}

String humanize(String value) {
  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
