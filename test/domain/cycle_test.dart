import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/domain/cycle.dart';

void main() {
  DateTime d(int month, int day) => DateTime(2026, month, day);

  List<DateTime> run(DateTime start, int n) => [
    for (var i = 0; i < n; i++)
      DateTime(start.year, start.month, start.day + i),
  ];

  test('runs of days are periods, a single gap does not split one', () {
    final p = periodsOf([...run(d(1, 1), 3), d(1, 5), ...run(d(2, 1), 4)]);
    expect(p.map((x) => (x.start, x.end)), [
      (d(1, 1), d(1, 5)),
      (d(2, 1), d(2, 4)),
    ]);
    expect(p.first.length, 5);
  });

  test('nothing logged: defaults and no forecast', () {
    final f = CycleForecast.from(const []);
    expect(f.cycleLength, defaultCycleLength);
    expect(f.periodLength, defaultPeriodLength);
    expect(f.measured, 0);
    expect(f.nextStart, isNull);
    expect(f.cycleDay(d(3, 1)), isNull);
    expect(f.kindOf(d(3, 1)), isNull);
  });

  test('one period: default cycle, forecast from its start', () {
    final f = CycleForecast.from(run(d(1, 1), 4));
    expect(f.periodLength, 4);
    expect(f.nextStart, d(1, 29));
    expect(f.cycleDay(d(1, 10)), 10);
    expect(f.daysUntilNext(d(1, 10)), 19);
    expect(f.kindOf(d(1, 2)), CycleDay.period);
    expect(f.kindOf(d(1, 29)), CycleDay.predictedPeriod);
    expect(f.kindOf(d(2, 1)), CycleDay.predictedPeriod);
    expect(f.kindOf(d(2, 2)), isNull);
  });

  test('the average is taken from measured cycles', () {
    final f = CycleForecast.from([
      ...run(d(1, 1), 5),
      ...run(d(1, 31), 5),
      ...run(d(3, 4), 5),
    ]);
    expect(f.cycleLengths, [32, 30]);
    expect(f.cycleLength, 31);
    expect(f.measured, 2);
    expect(f.nextStart, d(4, 4));
  });

  test('a skipped month is not a cycle', () {
    final f = CycleForecast.from([
      ...run(d(1, 1), 4),
      ...run(d(4, 1), 4), // 90 days later
    ]);
    expect(f.measured, 0);
    expect(f.cycleLength, defaultCycleLength);
  });

  test('ovulation 14 days before the next period, window around it', () {
    final f = CycleForecast.from(run(d(1, 1), 5));
    final ovulation = DateTime(2026, 1, 29 - 14);
    expect(f.kindOf(ovulation), CycleDay.ovulation);
    expect(f.kindOf(DateTime(2026, 1, 29 - 14 - 5)), CycleDay.fertile);
    expect(f.kindOf(DateTime(2026, 1, 29 - 14 + 1)), CycleDay.fertile);
    expect(f.kindOf(DateTime(2026, 1, 29 - 14 + 2)), isNull);
  });

  test('a late period is a negative count', () {
    final f = CycleForecast.from(run(d(1, 1), 5));
    expect(f.daysUntilNext(d(2, 3)), -5);
  });
}
