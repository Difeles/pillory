import 'dart:async';

import 'package:pillory/domain/cycle.dart';

/// In memory: widget tests cannot wait on a real database.
class FakeCycleRepository implements CycleRepository {
  final _days = <DateTime>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  @override
  Stream<Set<DateTime>> watchDays() async* {
    yield {..._days};
    await for (final _ in _changes.stream) {
      yield {..._days};
    }
  }

  @override
  Future<void> setDay(DateTime day, {required bool on}) async {
    final d = DateTime(day.year, day.month, day.day);
    on ? _days.add(d) : _days.remove(d);
    _changes.add(null);
  }
}
