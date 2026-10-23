import 'dart:async';

import 'package:drift/drift.dart';

import '../core/ids.dart';
import '../domain/extras.dart';
import 'app_database.dart';

/// The manual shopping list and the app settings.
class DriftExtrasRepository implements ExtrasRepository {
  DriftExtrasRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;
  final _settingsChanged = StreamController<void>.broadcast(sync: true);

  @override
  Stream<void> get userSettingsChanged => _settingsChanged.stream;

  @override
  Stream<List<ShoppingItem>> watchShopping() =>
      (_db.select(
        _db.shoppingItems,
      )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch().map(
        (rows) => [
          for (final r in rows)
            ShoppingItem(
              id: r.id,
              name: r.name,
              medicineId: r.medicineId,
              checked: r.checked,
            ),
        ],
      );

  @override
  Future<void> addShopping(String name, {String? medicineId}) async {
    final n = name.trim();
    if (n.isEmpty) return;
    // Compared in Dart: SQLite's lower() leaves Cyrillic capitals alone.
    final names = await _db.select(_db.shoppingItems).map((r) => r.name).get();
    if (names.any((x) => x.toLowerCase() == n.toLowerCase())) return;
    await _db
        .into(_db.shoppingItems)
        .insert(
          ShoppingItemsCompanion.insert(
            id: generateId(),
            name: n,
            medicineId: Value(medicineId),
            createdAt: _now(),
          ),
        );
  }

  @override
  Future<void> setChecked(String id, bool checked) =>
      (_db.update(_db.shoppingItems)..where((t) => t.id.equals(id))).write(
        ShoppingItemsCompanion(checked: Value(checked)),
      );

  @override
  Future<void> removeShopping(String id) =>
      (_db.delete(_db.shoppingItems)..where((t) => t.id.equals(id))).go();

  @override
  Stream<AppPrefs> watchPrefs() => _db
      .select(_db.appSettings)
      .watch()
      .map((rows) => AppPrefs.fromMap({for (final r in rows) r.key: r.value}));

  @override
  Future<String?> getPref(String key) async => (await (_db.select(
    _db.appSettings,
  )..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  @override
  Future<void> setPref(String key, String value) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value),
        );
    if (!key.startsWith(devicePrefix)) _settingsChanged.add(null);
  }
}
