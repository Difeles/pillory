// Drift's documented check() pattern reads the column inside its own getter.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../domain/medicine_form.dart';
import '../domain/models.dart';

/// Stores a calendar date as `yyyy-MM-dd` text, so it never shifts with the
/// device time zone (unlike a stored instant).
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) {
    final p = fromDb.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  @override
  String toSql(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

@DataClassName('MedicineRow')
class Medicines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1)();
  TextColumn get form => textEnum<MedicineForm>().nullable()();
  TextColumn get strength => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MedicinePackageRow')
@TableIndex(name: 'idx_packages_medicine', columns: {#medicineId})
class MedicinePackages extends Table {
  TextColumn get id => text()();
  TextColumn get medicineId =>
      text().references(Medicines, #id, onDelete: KeyAction.cascade)();
  RealColumn get initialQuantity =>
      real().check(initialQuantity.isBiggerOrEqualValue(0))();

  /// Backstop for the domain rule: a package can never go below zero.
  RealColumn get quantity => real().check(quantity.isBiggerOrEqualValue(0))();
  TextColumn get unit => text().withLength(min: 1)();
  TextColumn get expiresOn =>
      text().map(const DateOnlyConverter()).nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('InventoryTransactionRow')
@TableIndex(name: 'idx_transactions_package', columns: {#packageId})
class InventoryTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get packageId =>
      text().references(MedicinePackages, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<TransactionKind>()();
  RealColumn get delta => real()();
  RealColumn get quantityAfter =>
      real().check(quantityAfter.isBiggerOrEqualValue(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
