import 'inventory_rules.dart' show dateOnly;

/// Cycle length used until there are two periods to measure one from.
const defaultCycleLength = 28;

/// Period length used until there is one to measure.
const defaultPeriodLength = 5;

/// Cycles outside this range are not counted into the average (a missed
/// month in the log, not a cycle).
const minCycleLength = 15;
const maxCycleLength = 60;

/// How many of the latest cycles the average is taken from.
const _averageOver = 6;

/// How many cycles ahead the calendar predicts.
const predictedCycles = 3;

/// A run of period days.
class Period {
  const Period(this.start, this.end);

  final DateTime start;
  final DateTime end;

  int get length => end.difference(start).inDays + 1;
}

/// Runs of consecutive [days], oldest first. A single missing day inside a
/// run does not split it.
List<Period> periodsOf(Iterable<DateTime> days) {
  final sorted = ({for (final d in days) dateOnly(d)}).toList()..sort();
  final periods = <Period>[];
  for (final d in sorted) {
    final last = periods.lastOrNull;
    if (last != null && d.difference(last.end).inDays <= 2) {
      periods[periods.length - 1] = Period(last.start, d);
    } else {
      periods.add(Period(d, d));
    }
  }
  return periods;
}

/// What the calendar shows a day as.
enum CycleDay { period, predictedPeriod, fertile, ovulation }

/// Measurements and predictions from the logged period days. Not a medical
/// device: the predictions are averages.
class CycleForecast {
  CycleForecast._(
    this.periods,
    this.cycleLength,
    this.periodLength,
    this.measured,
    this._predicted,
  );

  factory CycleForecast.from(Iterable<DateTime> days) {
    final periods = periodsOf(days);
    final lengths = [
      for (var i = 1; i < periods.length; i++)
        periods[i].start.difference(periods[i - 1].start).inDays,
    ].where((n) => n >= minCycleLength && n <= maxCycleLength).toList();
    final recent = lengths.length > _averageOver
        ? lengths.sublist(lengths.length - _averageOver)
        : lengths;
    final cycle = recent.isEmpty
        ? defaultCycleLength
        : (recent.reduce((a, b) => a + b) / recent.length).round();
    final recentPeriods = periods.length > _averageOver
        ? periods.sublist(periods.length - _averageOver)
        : periods;
    final period = recentPeriods.isEmpty
        ? defaultPeriodLength
        : (recentPeriods.map((p) => p.length).reduce((a, b) => a + b) /
                  recentPeriods.length)
              .round();
    final predicted = <DateTime, CycleDay>{};
    final last = periods.lastOrNull;
    if (last != null) {
      for (var i = 1; i <= predictedCycles; i++) {
        final start = _plus(last.start, cycle * i);
        for (var d = 0; d < period; d++) {
          predicted[_plus(start, d)] = CycleDay.predictedPeriod;
        }
        // Ovulation about 14 days before the next period; the fertile window
        // is the five days before it and the day after.
        final ovulation = _plus(start, -14);
        for (var d = -5; d <= 1; d++) {
          predicted.putIfAbsent(_plus(ovulation, d), () => CycleDay.fertile);
        }
        predicted[ovulation] = CycleDay.ovulation;
      }
    }
    return CycleForecast._(periods, cycle, period, recent.length, predicted);
  }

  final List<Period> periods;

  /// Average cycle length in days (28 until measured).
  final int cycleLength;

  /// Average period length in days (5 until measured).
  final int periodLength;

  /// How many cycles the average is taken from; 0 means the defaults.
  final int measured;
  final Map<DateTime, CycleDay> _predicted;

  /// The start of the next period, or null with nothing logged.
  DateTime? get nextStart {
    final last = periods.lastOrNull;
    return last == null ? null : _plus(last.start, cycleLength);
  }

  /// The day of the cycle [today] is (1 on the first day of a period), or
  /// null with nothing logged.
  int? cycleDay(DateTime today) {
    final last = periods.lastOrNull;
    if (last == null) return null;
    final n = dateOnly(today).difference(last.start).inDays + 1;
    return n < 1 ? null : n;
  }

  /// Days to the next period, negative when it is late.
  int? daysUntilNext(DateTime today) {
    return nextStart?.difference(dateOnly(today)).inDays;
  }

  /// The lengths of the cycles between logged periods, newest first.
  List<int> get cycleLengths => [
    for (var i = periods.length - 1; i > 0; i--)
      periods[i].start.difference(periods[i - 1].start).inDays,
  ];

  /// What [day] is: a logged period day beats a prediction.
  CycleDay? kindOf(DateTime day) {
    final d = dateOnly(day);
    for (final p in periods) {
      if (!d.isBefore(p.start) && !d.isAfter(p.end)) return CycleDay.period;
    }
    return _predicted[d];
  }
}

/// Calendar arithmetic that ignores clock changes.
DateTime _plus(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

/// Storage of the logged period days. Implemented in `data/`.
abstract interface class CycleRepository {
  /// The logged days; re-emits on change.
  Stream<Set<DateTime>> watchDays();

  /// Logs [day] as a period day or takes it back.
  Future<void> setDay(DateTime day, {required bool on});
}
