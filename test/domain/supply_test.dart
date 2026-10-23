import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/reminders.dart';
import 'package:pillory/domain/schedule.dart';
import 'package:pillory/domain/supply.dart';

void main() {
  final today = DateTime(2026, 10, 19);
  final stock = MedicineStock(
    medicine: Medicine(
      id: 'm',
      name: 'Аспирин',
      unit: 'шт.',
      createdAt: DateTime(2026),
    ),
    packages: [
      MedicinePackage(
        id: 'p',
        medicineId: 'm',
        initialQuantity: 20,
        quantity: 20,
        unit: 'шт.',
        createdAt: DateTime(2026),
      ),
    ],
  );

  Schedule schedule({
    ScheduleKind kind = ScheduleKind.daily,
    List<int> times = const [480, 1200],
    Set<int> weekdays = const {},
    DateTime? end,
    String unit = 'шт.',
  }) => Schedule(
    id: 's',
    createdAt: DateTime(2026),
    medicineId: 'm',
    kind: kind,
    dose: 1,
    doseUnit: unit,
    startDate: DateTime(2026, 10, 1),
    times: times,
    weekdays: weekdays,
    endDate: end,
  );

  SupplyForecast? forecast(List<Schedule> list) =>
      forecastSupply(stock, list, today);

  test('twice a day: 20 pills cover 10 days', () {
    final f = forecast([schedule()])!;
    expect(f.days, 10);
    expect(f.coversPlan, isFalse);
    expect(f.beyondHorizon, isFalse);
  });

  test('weekdays count only on their days', () {
    // 19 Oct 2026 is a Monday; 20 pills at 1 per Mon/Wed/Fri last 6 weeks and
    // 2 days: the 21st dose is on Mon 30 Nov... day index is what matters.
    final f = forecast([
      schedule(kind: ScheduleKind.weekdays, weekdays: {1, 3, 5}, times: [480]),
    ])!;
    expect(f.days, greaterThan(40));
    expect(f.days, lessThan(52));
  });

  test('a finite course the stock covers is reported as covered', () {
    final f = forecast([schedule(end: DateTime(2026, 10, 25))])!;
    expect(f.coversPlan, isTrue);
  });

  test('a finite course the stock cannot cover runs out inside it', () {
    final f = forecast([schedule(end: DateTime(2026, 11, 30))])!;
    expect(f.coversPlan, isFalse);
    expect(f.days, 10);
  });

  test('a long open plan is beyond the horizon', () {
    final f = forecast([
      schedule(times: [480], end: null),
    ])!;
    expect(f.days, 20);
    final bigStock = MedicineStock(
      medicine: stock.medicine,
      packages: [
        MedicinePackage(
          id: 'q',
          medicineId: 'm',
          initialQuantity: 5000,
          quantity: 5000,
          unit: 'шт.',
          createdAt: DateTime(2026),
        ),
      ],
    );
    expect(
      forecastSupply(bigStock, [
        schedule(times: [480]),
      ], today)!.beyondHorizon,
      isTrue,
    );
  });

  test('no forecast without a plan in the stock unit', () {
    expect(forecast(const []), isNull);
    expect(forecast([schedule(unit: 'мл')]), isNull);
  });

  test('courses ending within two days are listed, soonest first', () {
    ReminderSchedule rs(String name, DateTime? end) =>
        ReminderSchedule(schedule(end: end), name);
    final list = endingCourses([
      rs('Поздно', DateTime(2026, 10, 25)),
      rs('Сегодня', today),
      rs('Бессрочно', null),
      rs('Давно', DateTime(2026, 10, 1)),
      rs('Скоро', DateTime(2026, 10, 20)),
    ], today);
    expect(list.map((c) => c.medicineName), ['Сегодня', 'Скоро']);
  });

  test('a stage that the next one takes over is not an ending course', () {
    Schedule stage(String id, DateTime start, DateTime end) => Schedule(
      id: id,
      createdAt: DateTime(2026),
      medicineId: 'm',
      kind: ScheduleKind.daily,
      dose: 1,
      doseUnit: 'шт.',
      startDate: start,
      endDate: end,
      times: const [480],
    );
    final list = endingCourses([
      ReminderSchedule(
        stage('a', DateTime(2026, 10, 14), today),
        'Преднизолон',
      ),
      ReminderSchedule(
        stage('b', DateTime(2026, 10, 20), DateTime(2026, 10, 26)),
        'Преднизолон',
      ),
    ], today);
    expect(list, isEmpty);
  });
}
