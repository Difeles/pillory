import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/domain/models.dart';

void main() {
  MedicinePackage pkg(String id, double q, String unit, [DateTime? expires]) =>
      MedicinePackage(
        id: id,
        medicineId: 'm',
        initialQuantity: q,
        quantity: q,
        unit: unit,
        expiresOn: expires,
        createdAt: DateTime(2026),
      );

  test('only packages in the medicine unit are counted', () {
    final stock = MedicineStock(
      medicine: Medicine(
        id: 'm',
        name: 'X',
        unit: 'шт.',
        createdAt: DateTime(2026),
      ),
      packages: [
        pkg('a', 3, 'шт.', DateTime(2027, 5)),
        pkg('b', 100, 'мл', DateTime(2026, 11)),
        pkg('c', 2, 'шт.'),
      ],
    );
    expect(stock.unit, 'шт.');
    expect(stock.totalQuantity, 5);
    expect(stock.counted.map((p) => p.id), ['a', 'c']);
    expect(stock.foreign.map((p) => p.id), ['b']);
    // The foreign package's earlier expiry does not count either.
    expect(stock.nearestExpiry, DateTime(2027, 5));
    expect(stock.primaryPackage.id, 'a');
  });

  test('the package in use is the one that expires first', () {
    final stock = MedicineStock(
      medicine: Medicine(
        id: 'm',
        name: 'X',
        unit: 'шт.',
        createdAt: DateTime(2026),
      ),
      packages: [
        pkg('full', 28, 'шт.', DateTime(2028)),
        pkg('open', 25, 'шт.', DateTime(2027)),
      ],
    );
    expect(stock.primaryPackage.id, 'open');
  });

  test('a used-up package does not hide the next one', () {
    final medicine = Medicine(
      id: 'm',
      name: 'X',
      unit: 'шт.',
      createdAt: DateTime(2026),
    );
    final stock = MedicineStock(
      medicine: medicine,
      packages: [pkg('a', 0, 'шт.'), pkg('b', 10, 'шт.')],
    );
    expect(stock.primaryPackage.id, 'b');
    final empty = MedicineStock(
      medicine: medicine,
      packages: [pkg('a', 0, 'шт.')],
    );
    expect(empty.primaryPackage.id, 'a');
  });
}
