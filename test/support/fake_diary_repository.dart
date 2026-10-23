import 'dart:async';

import 'package:pillory/domain/diary.dart';

/// In memory: widget tests cannot wait on a real database.
class FakeDiaryRepository implements DiaryRepository {
  final _entries = <DiaryEntry>[];
  final _changes = StreamController<void>.broadcast(sync: true);

  @override
  Stream<List<DiaryEntry>> watchEntries() async* {
    yield [..._entries];
    await for (final _ in _changes.stream) {
      yield [..._entries];
    }
  }

  @override
  Future<void> add(NewDiaryEntry e) async {
    _entries.insert(
      0,
      DiaryEntry(
        id: '${_entries.length}',
        at: e.at,
        mood: e.mood,
        symptoms: e.symptoms,
      ),
    );
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    _entries.removeWhere((e) => e.id == id);
    _changes.add(null);
  }
}
