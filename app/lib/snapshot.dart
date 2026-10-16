import 'dart:convert';

/// Validate the boundary before storing an entire offline library snapshot.
Map<String, dynamic> validateSnapshot(dynamic input) {
  if (input is! Map<String, dynamic>) {
    throw const FormatException('صيغة المكتبة غير صالحة');
  }
  if (input['version'] != null && input['version'] != 1) {
    throw const FormatException('إصدار النسخة غير مدعوم؛ لم تُستبدل مكتبتك');
  }
  final favorites = input['favorites'];
  final notes = input['notes'];
  if (favorites is! List || notes is! List || favorites.length > 6236 || notes.length > 1000) {
    throw const FormatException('عناصر المكتبة غير صالحة');
  }
  final verse = RegExp(r'^(?:[1-9]|[1-9]\d|10\d|11[0-4]):[1-9]\d{0,2}$');
  for (final id in favorites) {
    if (id is! String || !verse.hasMatch(id)) {
      throw const FormatException('مرجع آية غير صالح');
    }
  }
  final cleanedNotes = <Map<String, dynamic>>[];
  final noteIds = <String>{};
  for (final item in notes) {
    if (item is! Map<String, dynamic> || item['id'] is! String || item['body'] is! String) {
      throw const FormatException('تأمل غير صالح');
    }
    if (!noteIds.add(item['id'] as String)) {
      throw const FormatException('معرفات تأملات مكررة');
    }
    final body = item['body'] as String;
    final verseId = item['verseId'];
    if (body.length > 10000 || (verseId != null && (verseId is! String || !verse.hasMatch(verseId)))) {
      throw const FormatException('نص التأمل أو مرجعه غير صالح');
    }
    cleanedNotes.add({
      'id': item['id'],
      'body': body,
      'verseId': verseId,
      'updatedAt': item['updatedAt'] is String ? item['updatedAt'] : DateTime.now().toUtc().toIso8601String(),
    });
  }
  final progress = input['progress'] ?? <String, dynamic>{};
  if (progress is! Map || progress.entries.any((e) => !['water', 'mercy', 'gratitude'].contains(e.key) || e.value is! int || (e.value as int) < 0 || (e.value as int) > 3)) {
    throw const FormatException('تقدم الرحلة غير صالح');
  }
  final clean = <String, dynamic>{
    'version': 1,
    'favorites': favorites.toSet().toList(),
    'notes': cleanedNotes,
    'progress': Map<String, dynamic>.from(progress),
  };
  if (utf8.encode(jsonEncode(clean)).length > 5 * 1024 * 1024) {
    throw const FormatException('المكتبة أكبر من الحد المسموح');
  }
  return clean;
}
