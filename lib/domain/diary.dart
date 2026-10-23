import 'dart:convert';

/// The troubles offered as chips, stored by these names; anything else a
/// person types is stored as typed.
const diarySymptoms = [
  'headache',
  'nausea',
  'dizziness',
  'weakness',
  'fever',
  'stomachache',
  'heartburn',
  'cough',
  'insomnia',
  'rash',
  'anxiety',
  'pain',
];

/// The most troubles one entry holds.
const maxDiarySymptoms = 12;

String encodeSymptoms(List<String> symptoms) => jsonEncode(symptoms);

/// The list written by [encodeSymptoms]; empty for nothing or a damaged value.
List<String> decodeSymptoms(String? text) {
  if (text == null) return const [];
  try {
    return [
      for (final s in jsonDecode(text) as List)
        if (s is String && s.trim().isNotEmpty) s,
    ];
  } on Object {
    return const [];
  }
}

/// One entry of the wellbeing diary.
class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.at,
    this.mood,
    this.symptoms = const [],
    this.note,
  });

  final String id;
  final DateTime at;

  /// 1 (bad) to 5 (great).
  final int? mood;

  /// What the trouble was: names from [diarySymptoms] or the person's own.
  final List<String> symptoms;
  final String? note;
}

/// Input for a new entry.
class NewDiaryEntry {
  const NewDiaryEntry({
    required this.at,
    this.mood,
    this.symptoms = const [],
    this.note,
  });

  final DateTime at;
  final int? mood;
  final List<String> symptoms;
  final String? note;
}

/// Why an entry is refused; the text is for the user.
String? validateDiaryEntry(NewDiaryEntry e) {
  final note = e.note?.trim() ?? '';
  if (e.mood == null && e.symptoms.isEmpty && note.isEmpty) {
    return 'Заполните хотя бы одно поле';
  }
  if (e.symptoms.length > maxDiarySymptoms) {
    return 'Не больше 12 пунктов в записи';
  }
  return null;
}

abstract interface class DiaryRepository {
  /// Newest first.
  Stream<List<DiaryEntry>> watchEntries();

  Future<void> add(NewDiaryEntry entry);

  Future<void> delete(String id);
}
