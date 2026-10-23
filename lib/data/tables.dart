// Drift's documented check() pattern reads the column inside its own getter.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../domain/medicine_form.dart';
import '../domain/models.dart';
import '../domain/schedule.dart';

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

  /// The one unit all packages of this medicine are counted in. Nullable only
  /// because older rows are filled in by the v5 migration.
  TextColumn get unit => text().nullable()();

  /// Own low-stock threshold, in the medicine's unit. Null: use the app rule
  /// (a share of the biggest package).
  RealColumn get lowStockThreshold => real().nullable()();

  TextColumn get category => textEnum<MedicineCategory>().nullable()();
  TextColumn get storage => textEnum<StorageSpot>().nullable()();

  /// How the pill is drawn (see PillLook.encode); null: the form's icon.
  TextColumn get look => text().nullable()();

  /// Set when the medicine is archived: hidden from the cabinet, nothing is
  /// deleted.
  DateTimeColumn get archivedAt => dateTime().nullable()();
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

@DataClassName('ScheduleRow')
@TableIndex(name: 'idx_schedules_medicine', columns: {#medicineId})
class Schedules extends Table {
  TextColumn get id => text()();

  /// The cabinet's own medicine, never a copy.
  TextColumn get medicineId =>
      text().references(Medicines, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => textEnum<ScheduleKind>()();

  /// Comma-separated weekday numbers, 1 = Monday.
  TextColumn get weekdays => text().withDefault(const Constant(''))();

  /// Comma-separated `yyyy-MM-dd`.
  TextColumn get dates => text().withDefault(const Constant(''))();
  TextColumn get startDate => text().map(const DateOnlyConverter())();
  TextColumn get endDate => text().map(const DateOnlyConverter()).nullable()();

  /// Comma-separated minutes from midnight; empty means one untimed intake.
  TextColumn get times => text().withDefault(const Constant(''))();

  TextColumn get mealRelation => textEnum<MealRelation>().nullable()();

  /// Per intake; independent of any package quantity.
  RealColumn get dose => real().check(dose.isBiggerThanValue(0))();
  TextColumn get doseUnit => text().withLength(min: 1)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

const untimedSlot = -1;

/// One marked intake (taken or skipped). The unique key is what makes a
/// repeated mark a no-op. A reset mark stays as a `pending` row, so its
/// deductions and restores remain traceable; marking again reuses the row.
@DataClassName('IntakeLogRow')
class IntakeLogs extends Table {
  TextColumn get id => text()();
  TextColumn get scheduleId =>
      text().references(Schedules, #id, onDelete: KeyAction.cascade)();
  TextColumn get day => text().map(const DateOnlyConverter())();

  /// Minutes from midnight of the taken intake, [untimedSlot] if untimed
  /// (not NULL, because NULLs never collide in a unique key).
  IntColumn get slot => integer().withDefault(const Constant(untimedSlot))();
  TextColumn get status =>
      textEnum<IntakeStatus>().withDefault(Constant(IntakeStatus.taken.name))();

  /// Whether every stock deduction of this mark is in [IntakeDeductions].
  /// False for marks made before deductions were recorded: they cannot be
  /// undone, as the stock cannot be restored exactly.
  BoolColumn get deductionsTracked =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get takenAt => dateTime()();

  /// The medicine as it was when the intake was marked, so history reads the
  /// same after a rename. All null for marks made before v5 (and while
  /// pending): those follow the current medicine.
  TextColumn get medicineName => text().nullable()();
  TextColumn get medicineForm => textEnum<MedicineForm>().nullable()();
  TextColumn get medicineStrength => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {scheduleId, day, slot},
  ];
}

/// The exact packages and amounts one "taken" mark took from stock.
/// [restoredAt] is set once the amount has been given back.
@DataClassName('IntakeDeductionRow')
@TableIndex(name: 'idx_deductions_log', columns: {#intakeLogId})
class IntakeDeductions extends Table {
  TextColumn get id => text()();
  TextColumn get intakeLogId =>
      text().references(IntakeLogs, #id, onDelete: KeyAction.cascade)();
  TextColumn get packageId =>
      text().references(MedicinePackages, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real().check(amount.isBiggerThanValue(0))();
  DateTimeColumn get restoredAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A manually added shopping-list entry. [medicineId] is plain text, not a
/// reference: the entry outlives a deleted or restored medicine.
@DataClassName('ShoppingItemRow')
class ShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1)();
  TextColumn get medicineId => text().nullable()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Key-value app settings (profile name, switches).
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// One entry of the wellbeing diary: a mood, what the trouble was and a note;
/// an entry has at least one of them.
@DataClassName('DiaryEntryRow')
@TableIndex(name: 'idx_diary_at', columns: {#at})
class DiaryEntries extends Table {
  TextColumn get id => text()();

  /// When it was measured or felt.
  DateTimeColumn get at => dateTime()();

  /// 1 (bad) to 5 (great).
  IntColumn get mood =>
      integer().nullable().check(mood.isNull() | mood.isBetweenValues(1, 5))();

  /// What the trouble was: a JSON list of names (see lib/domain/diary.dart).
  TextColumn get symptoms => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
