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

/// Settings with this prefix stay on the device: a backup neither carries
/// them nor replaces them.
const devicePrefix = 'local.';

abstract final class PrefKey {
  static const name = 'profileName';
  static const haptics = 'haptics';
  static const confetti = 'confetti';
  static const hints = 'expiryHints';
  static const appearance = 'appearance';
  static const onboarded = 'onboarded';
  static const sound = 'reminderSound';
  static const vibration = 'reminderVibration';
  static const quiet = 'quietHours';
  static const quietFrom = 'quietFrom';
  static const quietTo = 'quietTo';
  static const language = 'language';
  static const cloudRevision = '${devicePrefix}cloudRevision';
  static const cloudUid = '${devicePrefix}cloudUid';
  static const cloudSyncedAt = '${devicePrefix}cloudSyncedAt';
  static const cloudDirty = '${devicePrefix}cloudDirty';
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
    this.onboarded = false,
    this.sound = true,
    this.vibration = true,
    this.quiet = false,
    this.quietFrom = 23 * 60,
    this.quietTo = 7 * 60,
    this.language = 'system',
  });

  factory AppPrefs.fromMap(Map<String, String> m) => AppPrefs(
    name: m[PrefKey.name] ?? '',
    haptics: m[PrefKey.haptics] != 'false',
    confetti: m[PrefKey.confetti] != 'false',
    hints: m[PrefKey.hints] != 'false',
    appearance:
        Appearance.values.asNameMap()[m[PrefKey.appearance]] ??
        Appearance.system,
    onboarded: m[PrefKey.onboarded] == 'true',
    sound: m[PrefKey.sound] != 'false',
    vibration: m[PrefKey.vibration] != 'false',
    quiet: m[PrefKey.quiet] == 'true',
    quietFrom: int.tryParse(m[PrefKey.quietFrom] ?? '') ?? 23 * 60,
    quietTo: int.tryParse(m[PrefKey.quietTo] ?? '') ?? 7 * 60,
    language: m[PrefKey.language] ?? 'system',
  );

  final String name;
  final bool haptics;
  final bool confetti;
  final bool hints;
  final Appearance appearance;

  /// The welcome screen has been dealt with (or the cabinet already had data).
  final bool onboarded;

  /// Reminders make a sound / vibrate (vibration is Android only: iOS follows
  /// the system).
  final bool sound;
  final bool vibration;

  /// Reminders inside [quietFrom]..[quietTo] (minutes from midnight, may wrap
  /// past midnight) come without sound or vibration.
  final bool quiet;
  final int quietFrom;
  final int quietTo;

  /// 'system', 'ru' or 'en'.
  final String language;

  /// Whether a reminder at [minuteOfDay] falls in the quiet hours.
  bool isQuiet(int minuteOfDay) {
    if (!quiet || quietFrom == quietTo) return false;
    return quietFrom < quietTo
        ? minuteOfDay >= quietFrom && minuteOfDay < quietTo
        : minuteOfDay >= quietFrom || minuteOfDay < quietTo;
  }
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

  /// One setting by its key, or null. Keys that start with [devicePrefix]
  /// belong to this device: they are not part of backups.
  Future<String?> getPref(String key);

  /// Fires when the user's own settings change (not the device's, see
  /// [devicePrefix]): they are part of the cloud copy.
  Stream<void> get userSettingsChanged;
}
