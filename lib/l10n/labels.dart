import '../data/backup_format.dart' show BackupProblem;
import '../domain/achievements.dart';
import '../domain/medicine_form.dart';
import '../domain/pill_look.dart';
import '../domain/stock_status.dart';
import '../features/inventory/format.dart' show formatQuantity;
import 'app_localizations.dart';

/// The names of the app's enums and units in the current language. The enums'
/// own `label` is the Russian default and is not shown to the user.
extension EnumLabels on AppLocalizations {
  String form(MedicineForm f) => switch (f) {
    MedicineForm.tablet => formTablet,
    MedicineForm.capsule => formCapsule,
    MedicineForm.syrup => formSyrup,
    MedicineForm.solution => formSolution,
    MedicineForm.ointment => formOintment,
    MedicineForm.cream => formCream,
    MedicineForm.spray => formSpray,
    MedicineForm.drops => formDrops,
    MedicineForm.powder => formPowder,
    MedicineForm.suppository => formSuppository,
    MedicineForm.other => formOther,
  };

  String category(MedicineCategory c) => switch (c) {
    MedicineCategory.painkiller => catPainkiller,
    MedicineCategory.antipyretic => catAntipyretic,
    MedicineCategory.digestive => catDigestive,
    MedicineCategory.allergy => catAllergy,
    MedicineCategory.wounds => catWounds,
    MedicineCategory.cold => catCold,
    MedicineCategory.sedative => catSedative,
    MedicineCategory.cardio => catCardio,
    MedicineCategory.antidepressant => catAntidepressant,
    MedicineCategory.hormonal => catHormonal,
    MedicineCategory.antibiotic => catAntibiotic,
    MedicineCategory.vitamins => catVitamins,
    MedicineCategory.other => catOther,
  };

  String storage(StorageSpot s) => switch (s) {
    StorageSpot.home => storageHome,
    StorageSpot.fridge => storageFridge,
    StorageSpot.bag => storageBag,
  };

  String meal(MealRelation m) => switch (m) {
    MealRelation.before => mealBefore,
    MealRelation.during => mealDuring,
    MealRelation.after => mealAfter,
  };

  String stockFilter(StockFilter f) => switch (f) {
    StockFilter.all => filterAll,
    StockFilter.lowOrOut => filterLowOrOut,
    StockFilter.expiringSoon => filterExpiringSoon,
    StockFilter.expired => filterExpired,
  };

  String badgeTitle(AppBadge b) => switch (b) {
    AppBadge.firstWeek => badgeFirstWeekTitle,
    AppBadge.cabinetKeeper => badgeCabinetKeeperTitle,
    AppBadge.noExpired => badgeNoExpiredTitle,
    AppBadge.month => badgeMonthTitle,
    AppBadge.bigCabinet => badgeBigCabinetTitle,
    AppBadge.fifty => badgeFiftyTitle,
    AppBadge.perfectWeek => badgePerfectWeekTitle,
    AppBadge.diary => badgeDiaryTitle,
  };

  String badgeHint(AppBadge b) => switch (b) {
    AppBadge.firstWeek => badgeFirstWeekHint,
    AppBadge.cabinetKeeper => badgeCabinetKeeperHint,
    AppBadge.noExpired => badgeNoExpiredHint,
    AppBadge.month => badgeMonthHint,
    AppBadge.bigCabinet => badgeBigCabinetHint,
    AppBadge.fifty => badgeFiftyHint,
    AppBadge.perfectWeek => badgePerfectWeekHint,
    AppBadge.diary => badgeDiaryHint,
  };

  String shape(PillShape s) => switch (s) {
    PillShape.round => shapeRound,
    PillShape.oval => shapeOval,
    PillShape.caplet => shapeCaplet,
    PillShape.capsule => shapeCapsule,
    PillShape.square => shapeSquare,
  };

  String score(PillScore s) => switch (s) {
    PillScore.none => scoreNone,
    PillScore.line => scoreLine,
    PillScore.cross => scoreCross,
  };

  /// The text of a refused backup file; in Russian the file's own detailed
  /// message is kept.
  String backupProblem(BackupProblem p) => switch (p) {
    BackupProblem.tooLarge => backupTooLarge,
    BackupProblem.notBackup => backupNotBackup,
    BackupProblem.newerFormat => backupNewer,
    BackupProblem.corrupt => backupCorrupt,
    BackupProblem.inconsistent => backupInconsistent,
  };

  /// "2,5 шт." / "2.5 pcs".
  String quantity(double q, String stored) =>
      '${formatQuantity(q)} ${unit(stored)}';

  /// A unit as stored ('шт.', 'мл', 'г', 'доз') in this language; a unit the
  /// user typed stays as it is.
  String unit(String stored) => switch (stored) {
    'шт.' => unitPcs,
    'мл' => unitMl,
    'г' => unitG,
    'доз' => unitDoses,
    _ => stored,
  };

  /// The text of a validation or state error thrown with a Russian
  /// `message`; an unknown message is shown as it is.
  /// A diary trouble: a known name in this language, else as typed.
  String symptom(String key) => switch (key) {
    'headache' => symptomHeadache,
    'nausea' => symptomNausea,
    'dizziness' => symptomDizziness,
    'weakness' => symptomWeakness,
    'fever' => symptomFever,
    'stomachache' => symptomStomachache,
    'heartburn' => symptomHeartburn,
    'cough' => symptomCough,
    'insomnia' => symptomInsomnia,
    'rash' => symptomRash,
    'anxiety' => symptomAnxiety,
    'pain' => symptomPain,
    _ => key,
  };

  String problem(String message) {
    final unit = RegExp('^Единица должна быть «(.*)»\$').firstMatch(message);
    if (unit != null) return pUnitMustBe(this.unit(unit.group(1)!));
    return switch (message) {
      'Количество не может быть отрицательным' => pQuantityNegative,
      'Остаток не может быть отрицательным' => negativeStock,
      'Лекарство в архиве' => pMedicineArchived,
      'Единственную упаковку удалить нельзя: удалите лекарство' => pLastPackage,
      'Название обязательно' => pNameRequired,
      'Укажите единицу учёта' => pUnitRequired,
      'Порог не может быть отрицательным' => pThresholdNegative,
      'Дозировка должна быть больше нуля' => pDosePositive,
      'Укажите единицу дозировки' => pDoseUnitRequired,
      'Выберите дни недели' => pPickWeekdays,
      'Выберите даты' => pPickDates,
      'Дата окончания раньше даты начала' => pEndBeforeStart,
      'Некорректное время' => pBadTime,
      'Приём уже отмечен как принятый' => pAlreadyTaken,
      'Списания для этой отметки не сохранены' => pNoDeductions,
      'Заполните хотя бы одно поле' => validatorFillOne,
      'Не больше 12 пунктов в записи' => validatorMaxSymptoms,
      _ => message,
    };
  }
}
