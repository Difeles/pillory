import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/domain/models.dart';
import 'package:pillory/domain/stock_status.dart';

void main() {
  final today = DateTime(2026, 10, 19);
  DateTime inDays(int n) => DateTime(2026, 10, 19 + n);

  MedicinePackage pkg(
    double qty, {
    double? initial,
    String unit = 'шт.',
    DateTime? expires,
  }) => MedicinePackage(
    id: '${qty}_${expires}_$unit',
    medicineId: 'm',
    initialQuantity: initial ?? qty,
    quantity: qty,
    unit: unit,
    expiresOn: expires,
    createdAt: DateTime(2026),
  );

  MedicineStock stock(
    List<MedicinePackage> packages, {
    String name = 'Аспирин',
    double? threshold,
    DateTime? archivedAt,
  }) => MedicineStock(
    medicine: Medicine(
      id: name,
      name: name,
      unit: 'шт.',
      createdAt: DateTime(2026),
      lowStockThreshold: threshold,
      archivedAt: archivedAt,
    ),
    packages: packages,
  );

  group('package status and its boundary dates', () {
    PackageStatus at(DateTime? e, {double qty = 1}) =>
        packageStatus(pkg(qty, expires: e), today);

    test('yesterday is expired, today is still good but expiring', () {
      expect(at(inDays(-1)), PackageStatus.expired);
      expect(at(inDays(0)), PackageStatus.expiringSoon);
    });

    test('the horizon is 30 days, inclusive', () {
      expect(at(inDays(30)), PackageStatus.expiringSoon);
      expect(at(inDays(31)), PackageStatus.ok);
    });

    test('a clock change does not move the horizon', () {
      // Europe switches clocks on 2026-10-25, inside the window.
      final t = DateTime(2026, 10, 25);
      expect(
        packageStatus(pkg(1, expires: DateTime(2026, 11, 24)), t),
        PackageStatus.expiringSoon,
      );
      expect(
        packageStatus(pkg(1, expires: DateTime(2026, 11, 25)), t),
        PackageStatus.ok,
      );
    });

    test('no date is fine; an empty package is just empty', () {
      expect(at(null), PackageStatus.ok);
      expect(at(inDays(-5), qty: 0), PackageStatus.empty);
      expect(at(inDays(5), qty: 0), PackageStatus.empty);
    });

    test('the time of day in the date does not matter', () {
      expect(
        packageStatus(pkg(1, expires: DateTime(2026, 10, 18, 23, 59)), today),
        PackageStatus.expired,
      );
      expect(
        packageStatus(
          pkg(1, expires: DateTime(2026, 10, 19, 23, 59)),
          DateTime(2026, 10, 19, 8),
        ),
        PackageStatus.expiringSoon,
      );
    });
  });

  test('days until counts calendar days across a clock change', () {
    expect(daysUntil(DateTime(2026, 10, 26), DateTime(2026, 10, 24, 22)), 2);
    expect(daysUntil(DateTime(2026, 10, 19), today), 0);
    expect(daysUntil(DateTime(2026, 10, 18), today), -1);
  });

  group('assessing a medicine', () {
    test('mixed packages: an expired one does not make the rest low', () {
      final a = assess(
        stock([pkg(5, expires: inDays(-3)), pkg(20, expires: inDays(200))]),
        today,
      );
      expect(a.usable, 20);
      expect(a.hasExpired, isTrue);
      expect(a.earliestExpired, inDays(-3));
      expect(a.isOut || a.isLow, isFalse);
      expect(a.problem, StockProblem.expired);
      expect(a.matches(StockFilter.expired), isTrue);
      expect(a.matches(StockFilter.lowOrOut), isFalse);
    });

    test('only expired stock is no usable stock', () {
      final a = assess(stock([pkg(8, expires: inDays(-1))]), today);
      expect(a.usable, 0);
      expect(a.isOut, isTrue);
      expect(a.hasExpired, isTrue);
      expect(a.matches(StockFilter.lowOrOut), isTrue);
      expect(a.matches(StockFilter.expired), isTrue);
    });

    test('zero stock is out, whatever the threshold', () {
      final a = assess(stock([pkg(0, initial: 10)], threshold: 100), today);
      expect(a.isOut, isTrue);
      expect(a.isLow, isFalse);
      expect(a.problem, StockProblem.out);
      // An empty package with an old date raises no expiry alarm.
      expect(
        assess(
          stock([pkg(0, initial: 10, expires: inDays(-9))]),
          today,
        ).hasExpired,
        isFalse,
      );
    });

    test('the default threshold is 20% of the biggest package', () {
      MedicineStock s(double q) => stock([pkg(q, initial: 30)]);
      expect(assess(s(6), today).isLow, isTrue); // exactly 20%
      expect(assess(s(6.001), today).isLow, isFalse);
      expect(assess(s(0.5), today).isLow, isTrue);
      final two = assess(
        stock([pkg(1, initial: 10), pkg(19, initial: 100)]),
        today,
      );
      expect(two.threshold, 20); // the 100-sized package sets it
      expect(two.isLow, isTrue); // 20 in total
    });

    test('an own threshold replaces the default rule', () {
      MedicineStock s(double q, double t) =>
          stock([pkg(q, initial: 100)], threshold: t);
      expect(assess(s(3, 3), today).isLow, isTrue);
      expect(assess(s(4, 3), today).isLow, isFalse);
      // The default would call 20 low; the own threshold says it is fine.
      expect(assess(s(20, 5), today).isLow, isFalse);
      // A threshold of 0: only "out" counts.
      expect(assess(s(0.5, 0), today).isLow, isFalse);
      expect(assess(s(0, 0), today).isOut, isTrue);
    });

    test('packages in another unit are left out of everything', () {
      final a = assess(
        stock([
          pkg(2, initial: 10),
          pkg(500, initial: 500, unit: 'мл', expires: inDays(-10)),
        ]),
        today,
      );
      expect(a.usable, 2);
      expect(a.threshold, 2); // from the 10-sized package, not the 500 ml
      expect(a.hasExpired, isFalse);
      expect(a.isLow, isTrue);
    });

    test('the card shows one problem, in priority order', () {
      StockProblem? p(List<MedicinePackage> l) =>
          assess(stock(l), today).problem;
      expect(
        p([
          pkg(1, initial: 10, expires: inDays(-1)),
          pkg(1, initial: 10, expires: inDays(5)),
        ]),
        StockProblem.expired,
      );
      // Expiring soon beats low.
      expect(
        p([pkg(1, initial: 10, expires: inDays(5))]),
        StockProblem.expiringSoon,
      );
      expect(p([pkg(1, initial: 10)]), StockProblem.low);
      expect(p([pkg(0, initial: 10)]), StockProblem.out);
      expect(p([pkg(9, initial: 10)]), isNull);
    });
  });

  group('filters and sorting', () {
    final list = [
      stock([pkg(30, expires: inDays(400))], name: 'Анальгин'),
      stock([pkg(30, expires: inDays(-2))], name: 'Бром'),
      stock([pkg(30, expires: inDays(-9))], name: 'Валидол'),
      stock([pkg(30, expires: inDays(20))], name: 'Глицин'),
      stock([pkg(30, expires: inDays(3))], name: 'Дротаверин'),
      stock([pkg(0, initial: 10)], name: 'Ибупрофен'),
      stock([pkg(1, initial: 10)], name: 'Кеторол'),
      stock([pkg(2, initial: 20)], name: 'Лоратадин'),
      stock(
        [pkg(0, initial: 10)],
        name: 'Архивное',
        archivedAt: DateTime(2026),
      ),
    ];
    List<String> names(StockFilter f) => [
      for (final a in filterStock(list, f, today)) a.stock.medicine.name,
    ];

    test('all keeps the order by name and leaves out the archived', () {
      expect(names(StockFilter.all), [
        'Анальгин', 'Бром', 'Валидол', 'Глицин', 'Дротаверин', 'Ибупрофен',
        'Кеторол', 'Лоратадин', // prettier-ignore
      ]);
    });

    test('expired: the oldest date first', () {
      expect(names(StockFilter.expired), ['Валидол', 'Бром']);
    });

    test('expiring soon: the nearest date first', () {
      expect(names(StockFilter.expiringSoon), ['Дротаверин', 'Глицин']);
    });

    test(
      'low or out: out first, then the emptiest relative to its threshold',
      () {
        // Бром and Валидол have only expired stock: usable 0, so they are out.
        expect(names(StockFilter.lowOrOut), [
          'Бром', 'Валидол', 'Ибупрофен', // out, by name
          'Кеторол', // 1 of threshold 2
          'Лоратадин', // 2 of threshold 4: fuller
        ]);
      },
    );

    test('a medicine can match several filters', () {
      final both = filterStock(
        [
          stock([pkg(3, initial: 30, expires: inDays(4))]),
        ],
        StockFilter.expiringSoon,
        today,
      ).single;
      expect(both.matches(StockFilter.lowOrOut), isTrue);
      expect(both.matches(StockFilter.expiringSoon), isTrue);
    });
  });
}
