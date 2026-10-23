import 'dart:async';

import 'package:pillory/core/ids.dart';
import 'package:pillory/domain/extras.dart';

/// In-memory shopping list and settings for widget tests.
class FakeExtrasRepository implements ExtrasRepository {
  final _items = <ShoppingItem>[];
  // Tests start past the welcome screen unless they say otherwise.
  final _prefs = <String, String>{
    PrefKey.onboarded: 'true',
    // The tests read Russian; the test device's own language is English.
    PrefKey.language: 'ru',
  };
  final _changes = StreamController<void>.broadcast(sync: true);
  final _settingsChanged = StreamController<void>.broadcast(sync: true);

  @override
  Stream<void> get userSettingsChanged => _settingsChanged.stream;

  @override
  Stream<List<ShoppingItem>> watchShopping() async* {
    yield [..._items];
    await for (final _ in _changes.stream) {
      yield [..._items];
    }
  }

  @override
  Future<void> addShopping(String name, {String? medicineId}) async {
    final n = name.trim();
    if (n.isEmpty ||
        _items.any((i) => i.name.toLowerCase() == n.toLowerCase())) {
      return;
    }
    _items.add(
      ShoppingItem(
        id: generateId(),
        name: n,
        checked: false,
        medicineId: medicineId,
      ),
    );
    _changes.add(null);
  }

  @override
  Future<void> setChecked(String id, bool checked) async {
    final i = _items.indexWhere((x) => x.id == id);
    final o = _items[i];
    _items[i] = ShoppingItem(
      id: o.id,
      name: o.name,
      checked: checked,
      medicineId: o.medicineId,
    );
    _changes.add(null);
  }

  @override
  Future<void> removeShopping(String id) async {
    _items.removeWhere((i) => i.id == id);
    _changes.add(null);
  }

  @override
  Stream<AppPrefs> watchPrefs() async* {
    yield AppPrefs.fromMap(_prefs);
    await for (final _ in _changes.stream) {
      yield AppPrefs.fromMap(_prefs);
    }
  }

  @override
  Future<String?> getPref(String key) async => _prefs[key];

  @override
  Future<void> setPref(String key, String value) async {
    _prefs[key] = value;
    _changes.add(null);
    if (!key.startsWith(devicePrefix)) _settingsChanged.add(null);
  }
}
