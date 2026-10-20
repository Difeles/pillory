class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.checked,
    this.medicineId,
  });

  final String id;
  final String name;
  final bool checked;
  final String? medicineId;
}

abstract final class PrefKey {
  static const name = 'profileName';
  static const haptics = 'haptics';
  static const confetti = 'confetti';
  static const hints = 'expiryHints';
  static const appearance = 'appearance';
}

/// Which colours the app uses: the device's choice, or one of its own.
enum Appearance { system, light, dark }

/// App settings with their defaults (all switches on).
class AppPrefs {
  const AppPrefs({
    this.name = '',
    this.haptics = true,
    this.confetti = true,
    this.hints = true,
    this.appearance = Appearance.system,
  });

  factory AppPrefs.fromMap(Map<String, String> m) => AppPrefs(
    name: m[PrefKey.name] ?? '',
    haptics: m[PrefKey.haptics] != 'false',
    confetti: m[PrefKey.confetti] != 'false',
    hints: m[PrefKey.hints] != 'false',
    appearance:
        Appearance.values.asNameMap()[m[PrefKey.appearance]] ??
        Appearance.system,
  );

  final String name;
  final bool haptics;
  final bool confetti;
  final bool hints;
  final Appearance appearance;
}

/// The manual shopping list and the app settings.
abstract interface class ExtrasRepository {
  Stream<List<ShoppingItem>> watchShopping();

  /// Adds an item; a name already on the list is not added twice.
  Future<void> addShopping(String name, {String? medicineId});
  Future<void> setChecked(String id, bool checked);
  Future<void> removeShopping(String id);
  Stream<AppPrefs> watchPrefs();
  Future<void> setPref(String key, String value);
}
