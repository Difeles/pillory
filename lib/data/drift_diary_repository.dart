import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/diary.dart';
import 'app_database.dart';

class DriftDiaryRepository implements DiaryRepository {
  DriftDiaryRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<DiaryEntry>> watchEntries() =>
      (_db.select(
        _db.diaryEntries,
      )..orderBy([(t) => OrderingTerm.desc(t.at)])).watch().map(
        (rows) => [
          for (final r in rows)
            DiaryEntry(
              id: r.id,
              at: r.at,
              mood: r.mood,
              symptoms: decodeSymptoms(r.symptoms),
              note: r.note,
            ),
        ],
      );

  @override
  Future<void> add(NewDiaryEntry e) async {
    final problem = validateDiaryEntry(e);
    if (problem != null) throw ArgumentError(problem);
    final note = e.note?.trim();
    await _db
        .into(_db.diaryEntries)
        .insert(
          DiaryEntriesCompanion.insert(
            id: generateId(),
            at: e.at,
            mood: Value(e.mood),
            symptoms: Value(
              e.symptoms.isEmpty ? null : encodeSymptoms(e.symptoms),
            ),
            note: Value(note == null || note.isEmpty ? null : note),
          ),
        );
  }

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.diaryEntries)..where((t) => t.id.equals(id))).go();
}
