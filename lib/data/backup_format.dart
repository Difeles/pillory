import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;

import '../domain/medicine_form.dart';
import '../domain/models.dart';
import '../domain/pill_look.dart';
import '../domain/schedule.dart';
import 'app_database.dart';
import 'tables.dart';

const backupFormat = 'pillory-backup';

/// The version of the JSON contract below. It changes only when a file written
/// by an older app would no longer be read the same way; additive fields do
/// not need it. A file with a higher number is refused, an older one is
/// normalised into [BackupData] by [parseBackup].
const backupFormatVersion = 1;

/// Larger files are refused before they are parsed.
const maxBackupBytes = 20 * 1024 * 1024;

enum BackupProblem { tooLarge, notBackup, newerFormat, corrupt, inconsistent }

class BackupException implements Exception {
  const BackupException(this.problem, this.message);

  final BackupProblem problem;

  /// For the user, in Russian like the rest of the app's messages.
  final String message;

  @override
  String toString() => 'BackupException($problem): $message';
}

/// Every row of the database, as the current schema has them. What is
/// restored is exactly this, so a parsed file and a database are the same
/// thing to the restore.
class BackupData {
  const BackupData({
    required this.schemaVersion,
    required this.medicines,
    required this.packages,
    required this.transactions,
    required this.schedules,
    required this.intakeLogs,
    required this.intakeDeductions,
    this.diary = const [],
    this.shopping = const [],
    this.settings = const [],
    this.periodDays = const [],
    this.createdAt,
  });

  /// The SQLite schema the data was written from; only tells which fields an
  /// old file can lack. Not the file's contract (that is [backupFormatVersion]).
  final int schemaVersion;
  final DateTime? createdAt;
  final List<MedicineRow> medicines;
  final List<MedicinePackageRow> packages;
  final List<InventoryTransactionRow> transactions;
  final List<ScheduleRow> schedules;
  final List<IntakeLogRow> intakeLogs;
  final List<IntakeDeductionRow> intakeDeductions;

  /// Since schema 8; a file written before it has none of these, and
  /// restoring it leaves the diary, shopping list and settings alone.
  final List<DiaryEntryRow> diary;
  final List<ShoppingItemRow> shopping;
  final List<AppSettingRow> settings;

  /// Since schema 12; a file from before it leaves the calendar alone.
  final List<PeriodDayRow> periodDays;

  bool get hasExtras => schemaVersion >= 8;
  bool get hasCycle => schemaVersion >= 12;

  Map<String, int> get counts => {
    'medicines': medicines.length,
    'packages': packages.length,
    'transactions': transactions.length,
    'schedules': schedules.length,
    'intakeLogs': intakeLogs.length,
    'intakeDeductions': intakeDeductions.length,
    'diary': diary.length,
    'shopping': shopping.length,
    'settings': settings.length,
    'periodDays': periodDays.length,
  };

  bool get isEmpty => counts.values.every((n) => n == 0);

  int get archivedMedicines =>
      medicines.where((m) => m.archivedAt != null).length;

  /// The day of the latest mark that is not a reset one.
  DateTime? get lastMarkDay {
    final days = [
      for (final l in intakeLogs)
        if (l.status != IntakeStatus.pending) l.day,
    ]..sort();
    return days.lastOrNull;
  }
}

const _day = DateOnlyConverter();
List<String> _items(String csv) => csv.isEmpty ? const [] : csv.split(',');
String _ts(DateTime t) => t.toUtc().toIso8601String();

/// The file's text. Rows are ordered by id, so the same data always gives the
/// same text.
String encodeBackup(BackupData d) {
  List<T> byId<T>(List<T> rows, String Function(T) id) =>
      [...rows]..sort((a, b) => id(a).compareTo(id(b)));
  return jsonEncode({
    'format': backupFormat,
    'formatVersion': backupFormatVersion,
    'schemaVersion': d.schemaVersion,
    'createdAt': _ts(d.createdAt ?? DateTime.now()),
    // Reserved for a password-protected variant.
    'encryption': null,
    'counts': d.counts,
    'data': {
      'medicines': [
        for (final m in byId(d.medicines, (r) => r.id))
          {
            'id': m.id,
            'name': m.name,
            'form': m.form?.name,
            'strength': m.strength,
            'unit': m.unit,
            'lowStockThreshold': m.lowStockThreshold,
            'category': m.category?.name,
            'storage': m.storage?.name,
            'look': m.look,
            'archivedAt': m.archivedAt == null ? null : _ts(m.archivedAt!),
            'createdAt': _ts(m.createdAt),
          },
      ],
      'packages': [
        for (final p in byId(d.packages, (r) => r.id))
          {
            'id': p.id,
            'medicineId': p.medicineId,
            'initialQuantity': p.initialQuantity,
            'quantity': p.quantity,
            'unit': p.unit,
            'expiresOn': p.expiresOn == null ? null : _day.toSql(p.expiresOn!),
            'createdAt': _ts(p.createdAt),
          },
      ],
      'transactions': [
        for (final t in byId(d.transactions, (r) => r.id))
          {
            'id': t.id,
            'packageId': t.packageId,
            'kind': t.kind.name,
            'delta': t.delta,
            'quantityAfter': t.quantityAfter,
            'createdAt': _ts(t.createdAt),
          },
      ],
      'schedules': [
        for (final s in byId(d.schedules, (r) => r.id))
          {
            'id': s.id,
            'medicineId': s.medicineId,
            'kind': s.kind.name,
            'weekdays': _items(s.weekdays).map(int.parse).toList(),
            'dates': _items(s.dates),
            'startDate': _day.toSql(s.startDate),
            'endDate': s.endDate == null ? null : _day.toSql(s.endDate!),
            'times': _items(s.times).map(int.parse).toList(),
            'dose': s.dose,
            'doseUnit': s.doseUnit,
            'mealRelation': s.mealRelation?.name,
            'createdAt': _ts(s.createdAt),
          },
      ],
      'intakeLogs': [
        for (final l in byId(d.intakeLogs, (r) => r.id))
          {
            'id': l.id,
            'scheduleId': l.scheduleId,
            'day': _day.toSql(l.day),
            'slot': l.slot,
            'status': l.status.name,
            'deductionsTracked': l.deductionsTracked,
            'takenAt': _ts(l.takenAt),
            'medicineName': l.medicineName,
            'medicineForm': l.medicineForm?.name,
            'medicineStrength': l.medicineStrength,
          },
      ],
      'intakeDeductions': [
        for (final x in byId(d.intakeDeductions, (r) => r.id))
          {
            'id': x.id,
            'intakeLogId': x.intakeLogId,
            'packageId': x.packageId,
            'amount': x.amount,
            'restoredAt': x.restoredAt == null ? null : _ts(x.restoredAt!),
          },
      ],
      'diary': [
        for (final e in byId(d.diary, (r) => r.id))
          {
            'id': e.id,
            'at': _ts(e.at),
            'mood': e.mood,
            'symptoms': e.symptoms,
            'migraine': e.migraine,
            'note': e.note,
          },
      ],
      'shopping': [
        for (final i in byId(d.shopping, (r) => r.id))
          {
            'id': i.id,
            'name': i.name,
            'medicineId': i.medicineId,
            'checked': i.checked,
            'createdAt': _ts(i.createdAt),
          },
      ],
      'periodDays': [for (final p in d.periodDays) _day.toSql(p.day)],
      'settings': [
        for (final x in byId(d.settings, (r) => r.key))
          {'key': x.key, 'value': x.value},
      ],
    },
  });
}

/// Reads and checks a whole file; nothing is written anywhere. Either every
/// row is valid and every reference resolves, or a [BackupException] says why
/// the file is refused.
BackupData parseBackup(Uint8List bytes) {
  if (bytes.length > maxBackupBytes) {
    throw const BackupException(
      BackupProblem.tooLarge,
      'Файл слишком большой для резервной копии PillPal',
    );
  }
  final Object? root;
  try {
    root = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    throw const BackupException(
      BackupProblem.corrupt,
      'Файл повреждён или не является резервной копией',
    );
  }
  if (root is! Map<String, Object?> || root['format'] != backupFormat) {
    throw const BackupException(
      BackupProblem.notBackup,
      'Это не резервная копия PillPal',
    );
  }
  final version = root['formatVersion'];
  if (version is! int || version < 1) {
    throw const BackupException(
      BackupProblem.corrupt,
      'В файле нет версии формата',
    );
  }
  if (version > backupFormatVersion) {
    throw const BackupException(
      BackupProblem.newerFormat,
      'Копия создана более новой версией PillPal. Обновите приложение, '
      'чтобы её восстановить',
    );
  }
  if (root['encryption'] != null) {
    throw const BackupException(
      BackupProblem.newerFormat,
      'Эта версия PillPal не умеет открывать зашифрованные копии',
    );
  }
  final data = _Obj(root, 'файл');
  final schema = data.int_('schemaVersion');
  if (schema < 1) _bad('файл', 'schemaVersion');
  final createdAt = data.ts('createdAt');
  final counts = data.obj('counts');
  final tables = data.obj('data');

  // An old schema lacks whole tables; they are then empty.
  List<_Obj> rows(String key, {int since = 1}) {
    final raw = tables.m[key];
    if (raw == null && schema < since) return const [];
    if (raw is! List) _bad('data', key);
    return [
      for (final (i, r) in raw.indexed)
        if (r is Map<String, Object?>)
          _Obj(r, '$key[$i]', schema: schema)
        else
          _bad(key, '[$i]'),
    ];
  }

  final medicines = [
    for (final r in rows('medicines'))
      MedicineRow(
        id: r.str('id'),
        name: r.str('name', nonEmpty: true),
        form: r.enumOrNull('form', MedicineForm.values),
        strength: r.strOrNull('strength'),
        // Older files: filled below, as the v5 migration does.
        unit: r.strOrNull('unit'),
        lowStockThreshold: r.numOrNull('lowStockThreshold'),
        category: r.enumOrNull('category', MedicineCategory.values),
        storage: r.enumOrNull('storage', StorageSpot.values),
        look: r.lookOrNull('look'),
        archivedAt: r.tsOrNull('archivedAt'),
        createdAt: r.ts('createdAt'),
      ),
  ];
  final packages = [
    for (final r in rows('packages'))
      MedicinePackageRow(
        id: r.str('id'),
        medicineId: r.str('medicineId'),
        initialQuantity: r.num_('initialQuantity', min: 0),
        quantity: r.num_('quantity', min: 0),
        unit: r.str('unit', nonEmpty: true),
        expiresOn: r.dayOrNull('expiresOn'),
        createdAt: r.ts('createdAt'),
      ),
  ];
  final transactions = [
    for (final r in rows('transactions'))
      InventoryTransactionRow(
        id: r.str('id'),
        packageId: r.str('packageId'),
        kind: r.enum_('kind', TransactionKind.values),
        delta: r.num_('delta'),
        quantityAfter: r.num_('quantityAfter', min: 0),
        createdAt: r.ts('createdAt'),
      ),
  ];
  final schedules = [
    for (final r in rows('schedules'))
      ScheduleRow(
        id: r.str('id'),
        medicineId: r.str('medicineId'),
        kind: r.enum_('kind', ScheduleKind.values),
        weekdays: r.list('weekdays', _isWeekday),
        dates: r.list('dates', _isDay),
        startDate: r.day('startDate'),
        endDate: r.dayOrNull('endDate'),
        times: r.list('times', _isMinute),
        dose: r.num_('dose', min: 0, exclusive: true),
        doseUnit: r.str('doseUnit', nonEmpty: true),
        mealRelation: r.enumOrNull('mealRelation', MealRelation.values),
        createdAt: r.ts('createdAt'),
      ),
  ];
  final logs = [
    for (final r in rows('intakeLogs'))
      IntakeLogRow(
        id: r.str('id'),
        scheduleId: r.str('scheduleId'),
        day: r.day('day'),
        slot: r.intOr('slot', untimedSlot, since: 3, valid: _isSlot),
        status: r.enumOr('status', IntakeStatus.values, IntakeStatus.taken, 3),
        deductionsTracked: r.boolOr('deductionsTracked', false, since: 3),
        takenAt: r.ts('takenAt'),
        medicineName: r.strOrNull('medicineName'),
        medicineForm: r.enumOrNull('medicineForm', MedicineForm.values),
        medicineStrength: r.strOrNull('medicineStrength'),
      ),
  ];
  final deductions = [
    for (final r in rows('intakeDeductions', since: 4))
      IntakeDeductionRow(
        id: r.str('id'),
        intakeLogId: r.str('intakeLogId'),
        packageId: r.str('packageId'),
        amount: r.num_('amount', min: 0, exclusive: true),
        restoredAt: r.tsOrNull('restoredAt'),
      ),
  ];

  final diary = [
    for (final r in rows('diary', since: 8))
      DiaryEntryRow(
        id: r.str('id'),
        at: r.ts('at'),
        mood: r.intOrNull('mood', min: 1, max: 5),
        symptoms: r.strOrNull('symptoms'),
        migraine: r.intOrNull('migraine', min: 1, max: 3),
        note: r.strOrNull('note'),
      ),
  ];
  final shopping = [
    for (final r in rows('shopping', since: 8))
      ShoppingItemRow(
        id: r.str('id'),
        name: r.str('name', nonEmpty: true),
        medicineId: r.strOrNull('medicineId'),
        checked: r.boolOr('checked', false, since: 8),
        createdAt: r.ts('createdAt'),
      ),
  ];
  final rawDays = tables.m['periodDays'];
  if (rawDays != null && rawDays is! List) _bad('data', 'periodDays');
  final periodDays = [
    for (final (i, v) in ((rawDays as List?) ?? const []).indexed)
      PeriodDayRow(
        day: (v is String ? _parseDay(v) : null) ?? _bad('periodDays', '[$i]'),
      ),
  ];
  final settings = [
    for (final r in rows('settings', since: 8))
      AppSettingRow(key: r.str('key', nonEmpty: true), value: r.str('value')),
  ];

  // Same unit rule as the v5 migration: that of the oldest package.
  final normalized = [
    for (final m in medicines)
      m.unit != null
          ? m
          : m.copyWith(
              unit: Value.absentIfNull(
                ([...packages.where((p) => p.medicineId == m.id)]
                      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
                    .firstOrNull
                    ?.unit,
              ),
            ),
  ];

  final backup = BackupData(
    schemaVersion: schema,
    createdAt: createdAt,
    medicines: normalized,
    packages: packages,
    transactions: transactions,
    schedules: schedules,
    intakeLogs: logs,
    intakeDeductions: deductions,
    diary: diary,
    shopping: shopping,
    settings: settings,
    periodDays: periodDays,
  );
  _checkConsistency(backup, counts);
  return backup;
}

bool _isWeekday(String s) {
  final n = int.tryParse(s);
  return n != null && n >= 1 && n <= 7;
}

bool _isMinute(String s) {
  final n = int.tryParse(s);
  return n != null && n >= 0 && n < 1440;
}

bool _isDay(String s) => _parseDay(s) != null;
bool _isSlot(int n) => n == untimedSlot || (n >= 0 && n < 1440);

DateTime? _parseDay(String s) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) return null;
  final d = _day.fromSql(s);
  return _day.toSql(d) == s ? d : null; // rejects 2026-02-31
}

Never _bad(String where, String what) => throw BackupException(
  BackupProblem.corrupt,
  'Повреждена резервная копия: $where, поле «$what»',
);

Never _broken(String what) => throw BackupException(
  BackupProblem.inconsistent,
  'Резервная копия противоречива: $what',
);

void _checkConsistency(BackupData d, _Obj counts) {
  for (final e in d.counts.entries) {
    final declared = counts.m[e.key];
    if (declared != e.value && !(declared == null && e.value == 0)) {
      _broken('в «${e.key}» ${e.value} записей вместо $declared');
    }
  }
  Set<String> ids(String table, Iterable<String> all) {
    final set = <String>{};
    for (final id in all) {
      if (!set.add(id)) _broken('повторяется id в «$table»');
    }
    return set;
  }

  final medicineIds = ids('medicines', d.medicines.map((r) => r.id));
  final packageIds = ids('packages', d.packages.map((r) => r.id));
  ids('transactions', d.transactions.map((r) => r.id));
  final scheduleIds = ids('schedules', d.schedules.map((r) => r.id));
  final logIds = ids('intakeLogs', d.intakeLogs.map((r) => r.id));
  ids('intakeDeductions', d.intakeDeductions.map((r) => r.id));
  ids('diary', d.diary.map((r) => r.id));
  ids('shopping', d.shopping.map((r) => r.id));
  ids('settings', d.settings.map((r) => r.key));

  void ref(Set<String> parents, String id, String what) {
    if (!parents.contains(id)) {
      _broken('$what ссылается на отсутствующую запись');
    }
  }

  for (final p in d.packages) {
    ref(medicineIds, p.medicineId, 'упаковка');
  }
  for (final t in d.transactions) {
    ref(packageIds, t.packageId, 'движение запаса');
  }
  for (final s in d.schedules) {
    ref(medicineIds, s.medicineId, 'расписание');
  }
  for (final x in d.intakeDeductions) {
    ref(logIds, x.intakeLogId, 'списание');
    ref(packageIds, x.packageId, 'списание');
  }
  final marks = <(String, DateTime, int)>{};
  for (final l in d.intakeLogs) {
    ref(scheduleIds, l.scheduleId, 'отметка приёма');
    if (!marks.add((l.scheduleId, l.day, l.slot))) {
      _broken('две отметки на один приём');
    }
  }
}

/// Typed access to one JSON object; any wrong or missing field is a
/// [BackupProblem.corrupt] naming the place. [schema] decides which fields an
/// old file may lack.
class _Obj {
  _Obj(this.m, this.where, {this.schema = 0});

  final Map<String, Object?> m;
  final String where;
  final int schema;

  bool _absent(String k, int since) => !m.containsKey(k) && schema < since;

  T _get<T>(String k) {
    final v = m[k];
    return v is T ? v : _bad(where, k);
  }

  T? _getOrNull<T>(String k) {
    return m[k] == null ? null : _get<T>(k);
  }

  _Obj obj(String k) => _Obj(_get<Map<String, Object?>>(k), k);

  String str(String k, {bool nonEmpty = false}) {
    final v = _get<String>(k);
    if (nonEmpty && v.isEmpty) _bad(where, k);
    return v;
  }

  String? strOrNull(String k) => _getOrNull<String>(k);

  /// A pill look as stored; text that is not one is refused.
  String? lookOrNull(String k) {
    final v = _getOrNull<String>(k);
    return v == null || PillLook.tryParse(v) != null ? v : _bad(where, k);
  }

  int int_(String k) => _get<int>(k);

  int intOr(
    String k,
    int def, {
    required int since,
    required bool Function(int) valid,
  }) {
    if (_absent(k, since)) return def;
    final v = _get<int>(k);
    return valid(v) ? v : _bad(where, k);
  }

  bool boolOr(String k, bool def, {required int since}) =>
      _absent(k, since) ? def : _get<bool>(k);

  int? intOrNull(String k, {int? min, int? max}) {
    final v = _getOrNull<int>(k);
    if (v != null && ((min != null && v < min) || (max != null && v > max))) {
      _bad(where, k);
    }
    return v;
  }

  double num_(String k, {double? min, bool exclusive = false}) {
    final v = _get<num>(k).toDouble();
    if (min != null && (exclusive ? v <= min : v < min)) _bad(where, k);
    return v;
  }

  double? numOrNull(String k) => _getOrNull<num>(k)?.toDouble();

  DateTime ts(String k) {
    final v = DateTime.tryParse(_get<String>(k));
    return v != null && v.isUtc ? v : _bad(where, k);
  }

  DateTime? tsOrNull(String k) => m[k] == null ? null : ts(k);

  DateTime day(String k) => _parseDay(_get<String>(k)) ?? _bad(where, k);

  DateTime? dayOrNull(String k) => m[k] == null ? null : day(k);

  T enum_<T extends Enum>(String k, List<T> values) {
    final name = _get<String>(k);
    return values.where((e) => e.name == name).firstOrNull ?? _bad(where, k);
  }

  T? enumOrNull<T extends Enum>(String k, List<T> values) =>
      m[k] == null ? null : enum_(k, values);

  T enumOr<T extends Enum>(String k, List<T> values, T def, int since) =>
      _absent(k, since) ? def : enum_(k, values);

  /// A list stored as the database does: comma-separated text. Absent means
  /// empty, as the column defaults do.
  String list(String k, bool Function(String) valid) {
    if (!m.containsKey(k)) return '';
    final items = _get<List<Object?>>(k);
    final out = <String>[];
    for (final i in items) {
      final s = i is int ? '$i' : (i is String ? i : _bad(where, k));
      if (!valid(s)) _bad(where, k);
      out.add(s);
    }
    return out.join(',');
  }
}
