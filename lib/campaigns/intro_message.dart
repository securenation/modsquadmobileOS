import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String generateIntroRequestMessage({
  required String targetFullName,
  String? targetJobTitle,
  String? companyName,
  required String startupName,
  String? reason,
  String? suggestedLanguage,
  String? desiredResponseDate,
  required String responseUrl,
}) {
  final targetLine = [targetFullName, targetJobTitle, companyName].where((part) => part != null && part.isNotEmpty).join(', ');
  final lines = <String>[
    'Hi! Could you help with an introduction to $targetLine for $startupName?',
    if (reason != null && reason.isNotEmpty) 'Why: $reason',
    if (suggestedLanguage != null && suggestedLanguage.isNotEmpty) 'Suggested language: "$suggestedLanguage"',
    if (desiredResponseDate != null && desiredResponseDate.isNotEmpty)
      'We would love to hear back by $desiredResponseDate.',
    'Respond here (under a minute, no login needed): $responseUrl',
  ];
  return lines.join('\n\n');
}

String mintAdvisorToken() {
  final bytes = List<int>.generate(32, (_) => Random.secure().nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}

String hashAdvisorToken(String raw) => sha256.convert(utf8.encode(raw)).toString();

