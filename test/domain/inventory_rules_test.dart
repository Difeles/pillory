import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/core/ids.dart';
import 'package:pillory/domain/errors.dart';
import 'package:pillory/domain/inventory_rules.dart';
import 'package:pillory/domain/medicine_form.dart';
import 'package:pillory/domain/models.dart';

void main() {
  group('applyDelta', () {
    test('adds and subtracts', () {
      expect(applyDelta(5, 1), 6);
      expect(applyDelta(5, -2), 3);
    });

    test('allows reaching exactly zero', () {
      expect(applyDelta(2, -2), 0);
    });

    test('refuses to go below zero', () {
      expect(
        () => applyDelta(0, -1),
        throwsA(isA<InsufficientStockException>()),
      );
      expect(
        () => applyDelta(1, -1.5),
        throwsA(isA<InsufficientStockException>()),
      );
    });

    test('does not accumulate float noise', () {
      expect(applyDelta(0.1, 0.2), 0.3);
      // Without normalizing, 0.3 - 0.1 - 0.2 is a tiny negative number.
      expect(applyDelta(applyDelta(0.3, -0.1), -0.2), 0);
    });
  });

  group('dates', () {
    test('dateOnly drops the time of day', () {
      expect(dateOnly(DateTime(2027, 3, 5, 23, 59)), DateTime(2027, 3, 5));
    });

    test('isExpired compares calendar days', () {
      final now = DateTime(2026, 10, 17, 15);
      expect(isExpired(DateTime(2026, 10, 16), now), isTrue);
      expect(isExpired(DateTime(2026, 10, 17), now), isFalse); // today is valid
      expect(isExpired(DateTime(2026, 10, 18), now), isFalse);
      expect(isExpired(null, now), isFalse);
    });
  });

  group('validateNewMedicine', () {
    NewMedicine draft({
      String name = 'Аспирин',
      double quantity = 10,
      String unit = 'шт.',
      String? strength,
      DateTime? expiresOn,
    }) => NewMedicine(
      name: name,
      initialQuantity: quantity,
      unit: unit,
      strength: strength,
      expiresOn: expiresOn,
    );

    test('trims text, drops blank strength and normalizes the date', () {
      final v = validateNewMedicine(
        NewMedicine(
          name: '  Аспирин ',
          form: MedicineForm.tablet,
          strength: '   ',
          initialQuantity: 10,
          unit: ' шт. ',
          expiresOn: DateTime(2027, 1, 2, 18),
        ),
      );
      expect(v.name, 'Аспирин');
      expect(v.strength, isNull);
      expect(v.unit, 'шт.');
      expect(v.expiresOn, DateTime(2027, 1, 2));
    });

    test('name is required', () {
      expect(
        () => validateNewMedicine(draft(name: '   ')),
        throwsA(isA<InvalidMedicineException>()),
      );
    });

    test('quantity must be a finite number, zero or more', () {
      for (final q in [-1.0, double.nan, double.infinity]) {
        expect(
          () => validateNewMedicine(draft(quantity: q)),
          throwsA(isA<InvalidMedicineException>()),
          reason: '$q',
        );
      }
      expect(validateNewMedicine(draft(quantity: 0)).initialQuantity, 0);
    });

    test('unit is required', () {
      expect(
        () => validateNewMedicine(draft(unit: ' ')),
        throwsA(isA<InvalidMedicineException>()),
      );
    });
  });

  group('MedicineStock', () {
    MedicinePackage pkg(String id, double qty, DateTime? exp, int minute) =>
        MedicinePackage(
          id: id,
          medicineId: 'm',
          initialQuantity: qty,
          quantity: qty,
          unit: 'шт.',
          expiresOn: exp,
          createdAt: DateTime(2026, 1, 1, 0, minute),
        );

    test('total sums packages; nearest expiry ignores empty packages', () {
      final stock = MedicineStock(
        medicine: Medicine(
          id: 'm',
          name: 'X',
          unit: 'шт.',
          createdAt: DateTime(2026),
        ),
        packages: [
          pkg('a', 0, DateTime(2026, 2, 1), 0), // empty: its date is irrelevant
          pkg('b', 3, DateTime(2027, 5, 1), 1),
          pkg('c', 2, DateTime(2026, 12, 1), 2),
        ],
      );
      expect(stock.totalQuantity, 5);
      expect(stock.nearestExpiry, DateTime(2026, 12, 1));
    });
  });

  group('generateId', () {
    test('is a UUID v4 and unique', () {
      final uuid = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      final ids = {for (var i = 0; i < 500; i++) generateId()};
      expect(ids.length, 500);
      expect(ids.every(uuid.hasMatch), isTrue);
    });
  });
}
