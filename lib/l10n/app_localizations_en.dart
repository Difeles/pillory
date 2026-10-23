// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PillPal';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading';

  @override
  String get notSpecifiedM => 'Not set';

  @override
  String get decreaseStock => 'Decrease stock';

  @override
  String get increaseStock => 'Increase stock';

  @override
  String get streakTitle => 'On fire!';

  @override
  String get streakHint => 'Days in a row without a miss. Keep it up!';

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '$n day',
    );
    return '$_temp0';
  }

  @override
  String get monShort => 'Mon';

  @override
  String get tueShort => 'Tue';

  @override
  String get wedShort => 'Wed';

  @override
  String get thuShort => 'Thu';

  @override
  String get friShort => 'Fri';

  @override
  String get satShort => 'Sat';

  @override
  String get sunShort => 'Sun';

  @override
  String get tabToday => 'Today';

  @override
  String get tabCabinet => 'Cabinet';

  @override
  String get tabShopping => 'Shopping';

  @override
  String get tabProfile => 'Profile';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get chooseTime => 'Choose a time';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String get formTablet => 'Tablets';

  @override
  String get formCapsule => 'Capsules';

  @override
  String get formSyrup => 'Syrup';

  @override
  String get formSolution => 'Solution';

  @override
  String get formOintment => 'Ointment';

  @override
  String get formCream => 'Cream';

  @override
  String get formSpray => 'Spray';

  @override
  String get formDrops => 'Drops';

  @override
  String get formPowder => 'Powder';

  @override
  String get formSuppository => 'Suppositories';

  @override
  String get formOther => 'Other';

  @override
  String get catPainkiller => 'Pain and fever relief';

  @override
  String get catAntipyretic => 'Fever reducers';

  @override
  String get catDigestive => 'Digestion';

  @override
  String get catAllergy => 'Antihistamines';

  @override
  String get catWounds => 'Wounds and dressings';

  @override
  String get catCold => 'Cold remedies';

  @override
  String get catSedative => 'Sedatives';

  @override
  String get catCardio => 'Heart';

  @override
  String get catAntidepressant => 'Antidepressants';

  @override
  String get catHormonal => 'Hormonal';

  @override
  String get catAntibiotic => 'Antibiotics';

  @override
  String get catVitamins => 'Vitamins and supplements';

  @override
  String get catOther => 'Other';

  @override
  String get storageHome => 'Home cabinet';

  @override
  String get storageFridge => 'Fridge';

  @override
  String get storageBag => 'On me';

  @override
  String get mealBefore => 'Before meals';

  @override
  String get mealDuring => 'With meals';

  @override
  String get mealAfter => 'After meals';

  @override
  String get filterAll => 'All';

  @override
  String get filterLowOrOut => 'Low or out';

  @override
  String get filterExpiringSoon => 'Expiring soon';

  @override
  String get filterExpired => 'Expired';

  @override
  String get badgeFirstWeekTitle => 'First week';

  @override
  String get badgeFirstWeekHint => '7 days in a row without a miss';

  @override
  String get badgeCabinetKeeperTitle => 'Cabinet keeper';

  @override
  String get badgeCabinetKeeperHint => '3 medicines in the cabinet';

  @override
  String get badgeNoExpiredTitle => 'Nothing expired';

  @override
  String get badgeNoExpiredHint => 'No expired medicines';

  @override
  String get badgeMonthTitle => 'A month without a miss';

  @override
  String get badgeMonthHint => '30 days in a row';

  @override
  String get badgeBigCabinetTitle => 'Big cabinet';

  @override
  String get badgeBigCabinetHint => '10 medicines in the cabinet';

  @override
  String get badgeFiftyTitle => '50 intakes';

  @override
  String get badgeFiftyHint => '50 \"taken\" marks in 60 days';

  @override
  String get badgePerfectWeekTitle => 'Perfect week';

  @override
  String get badgePerfectWeekHint =>
      'Every intake of the last 7 days is marked';

  @override
  String get badgeDiaryTitle => 'Diary started';

  @override
  String get badgeDiaryHint => '3 wellbeing entries';

  @override
  String get unitPcs => 'pcs';

  @override
  String get unitMl => 'ml';

  @override
  String get unitG => 'g';

  @override
  String get unitDoses => 'doses';

  @override
  String get negativeStock => 'Stock cannot go below zero';

  @override
  String get disposalHint => 'Check the leaflet and local disposal rules';

  @override
  String get stockLabel => 'Stock';

  @override
  String expiredSince(String date) {
    return 'Expired on $date';
  }

  @override
  String expiringBadge(String date, String when) {
    return 'Expiring soon: until $date ($when)';
  }

  @override
  String get whenToday => 'today';

  @override
  String whenInDays(int n) {
    return 'in $n d';
  }

  @override
  String get outBadge => 'Out of stock';

  @override
  String lowBadge(String qty) {
    return 'Low: $qty left';
  }

  @override
  String goodUntil(String date) {
    return 'Good until $date';
  }

  @override
  String searchMedicines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicines',
      one: '$count medicine',
    );
    return 'Search $_temp0';
  }

  @override
  String get backToCabinet => 'Back to the cabinet';

  @override
  String get archive => 'Archive';

  @override
  String get titleCabinet => 'Cabinet';

  @override
  String get addMedicine => 'Add medicine';

  @override
  String get cabinetLoadFailed => 'Could not load the cabinet';

  @override
  String get archiveEmptyTitle => 'The archive is empty';

  @override
  String get archiveEmptyText =>
      'Medicines you remove from the cabinet end up here.';

  @override
  String get cabinetEmptyTitle => 'The cabinet is empty';

  @override
  String get cabinetEmptyText =>
      'Add your first medicine to track its stock and expiry date.';

  @override
  String get noMedicinesWithStatus => 'No medicines with this status';

  @override
  String get showAll => 'Show all';

  @override
  String get readinessOverline => 'CABINET READINESS';

  @override
  String okPercent(int percent) {
    return 'All good: $percent%';
  }

  @override
  String get tileTotal => 'Total';

  @override
  String get tileExpiring => 'Expiring';

  @override
  String get tileLow => 'Low';

  @override
  String timeToBuy(int count) {
    return 'Time to restock: $count. See the Shopping tab';
  }

  @override
  String get allCategories => 'All categories';

  @override
  String get pQuantityNegative => 'The quantity cannot be negative';

  @override
  String get pMedicineArchived => 'The medicine is archived';

  @override
  String pUnitMustBe(String unit) {
    return 'The unit must be \"$unit\"';
  }

  @override
  String get pNameRequired => 'The name is required';

  @override
  String get pUnitRequired => 'Choose a unit';

  @override
  String get pThresholdNegative => 'The threshold cannot be negative';

  @override
  String get pDosePositive => 'The dose must be more than zero';

  @override
  String get pDoseUnitRequired => 'Choose the dose unit';

  @override
  String get pPickWeekdays => 'Choose the days of the week';

  @override
  String get pPickDates => 'Choose the dates';

  @override
  String get pEndBeforeStart => 'The end date is before the start date';

  @override
  String get pBadTime => 'Invalid time';

  @override
  String get pAlreadyTaken => 'This intake is already marked as taken';

  @override
  String get pNoDeductions => 'The deductions for this mark were not saved';

  @override
  String get newMedicine => 'New medicine';

  @override
  String get medicineTitle => 'Medicine';

  @override
  String get addToCabinet => 'Add to the cabinet';

  @override
  String get secBasic => 'Basics';

  @override
  String get nameLabel => 'Name *';

  @override
  String get nameHint => 'E.g. Ibuprofen Forte';

  @override
  String get enterName => 'Enter a name';

  @override
  String get secCategory => 'Category';

  @override
  String get secForm => 'Form';

  @override
  String get strengthLabel => 'Strength or concentration';

  @override
  String get strengthHint => 'E.g. 500 mg';

  @override
  String get secStorage => 'Where is it kept?';

  @override
  String get secStock => 'Stock';

  @override
  String get initialQuantity => 'Initial quantity';

  @override
  String get enterNumberZero => 'Enter a number, 0 or more';

  @override
  String get unitLabel => 'Unit';

  @override
  String get expiryLabel => 'Expiry date';

  @override
  String get clearExpiry => 'Clear the expiry date';

  @override
  String get thresholdLabel => 'Low-stock threshold (optional)';

  @override
  String get thresholdHelper => 'Default: 20% of the biggest package';

  @override
  String get secLook => 'Appearance';

  @override
  String get drawPill => 'How it looks';

  @override
  String get pillShape => 'Shape';

  @override
  String get pillColor => 'Colour';

  @override
  String get pillColor2 => 'Colour of the other half';

  @override
  String get pillScore => 'Score';

  @override
  String get shapeRound => 'Round';

  @override
  String get shapeOval => 'Oval';

  @override
  String get shapeCaplet => 'Oblong';

  @override
  String get shapeCapsule => 'Capsule';

  @override
  String get shapeSquare => 'Square';

  @override
  String get scoreNone => 'No score';

  @override
  String get scoreLine => 'One line';

  @override
  String get scoreCross => 'Cross';

  @override
  String colorSwatch(int n) {
    return 'Colour $n';
  }

  @override
  String get edit => 'Edit';

  @override
  String get toArchive => 'Archive';

  @override
  String get restoreFromArchive => 'Restore from the archive';

  @override
  String get inArchiveBadge => 'Archived';

  @override
  String stockSemantics(String quantity) {
    return 'Stock: $quantity';
  }

  @override
  String get totalStock => 'Total stock';

  @override
  String get stockInPackage => 'Left in the package';

  @override
  String get secPackages => 'Packages';

  @override
  String get takeNow => 'Take now';

  @override
  String get addPackage => 'Add a package';

  @override
  String get addedToShopping => 'Added to the shopping list';

  @override
  String get toShoppingList => 'Add to the shopping list';

  @override
  String get archiveAskTitle => 'Move to the archive?';

  @override
  String get archiveAskText =>
      'Running schedules of this medicine will end and reminders will stop. Past intakes and the stock history stay.';

  @override
  String get medicineRestored =>
      'The medicine is back. Ended schedules need to be created again';

  @override
  String takenRecorded(String qty) {
    return 'Recorded: $qty';
  }

  @override
  String expiryPassed(String date) {
    return 'Expired on $date';
  }

  @override
  String get packageOut => 'Used up';

  @override
  String get expiringSoonShort => 'Expiring soon';

  @override
  String get otherUnitNote =>
      'Another unit: not counted in the stock and not used by intakes';

  @override
  String get packageTooltip => 'Package';

  @override
  String get correctStock => 'Correct the stock';

  @override
  String get expiryTitle => 'Expiry date';

  @override
  String get movementHistory => 'Stock history';

  @override
  String get staleQuantity =>
      'The stock has changed. Open the correction again';

  @override
  String get noMovements => 'No movements';

  @override
  String stockAfter(String qty, String when) {
    return 'Stock $qty · $when';
  }

  @override
  String get txInitial => 'Initial stock';

  @override
  String get txIncrease => 'Added';

  @override
  String get txDecrease => 'Used';

  @override
  String get txCorrection => 'Correction';

  @override
  String get newPackage => 'New package';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get add => 'Add';

  @override
  String get actualStock => 'Actual stock';

  @override
  String leftOfTotal(int left, int total) {
    return '$left of $total left';
  }

  @override
  String get howManyTaken => 'How many did you take';

  @override
  String get enterPositive => 'Enter a number above zero';

  @override
  String get record => 'Record';

  @override
  String get tip1 => 'Remember a glass of water: pills absorb better.';

  @override
  String get tip2 =>
      'Keep the cabinet where you can see it: it is easier not to miss a dose.';

  @override
  String get tip3 => 'Every mark is a small win. The streak grows!';

  @override
  String get tip4 =>
      'Check expiry dates once a month: I will tell you what expires soon.';

  @override
  String get notEnoughStock => 'Not enough of this medicine in the cabinet';

  @override
  String get addIntake => 'Add an intake';

  @override
  String get historyTooltip => 'History';

  @override
  String get wholeMonth => 'Whole month';

  @override
  String get loadIntakesFailed => 'Could not load the intakes';

  @override
  String get noIntakesTitle => 'No intakes for this day';

  @override
  String get noIntakesText => 'Tap \"+\" to add an intake';

  @override
  String courseLastDay(String name) {
    return 'Last day of the course today: $name';
  }

  @override
  String courseEnds(String name, String date) {
    return 'The $name course ends on $date';
  }

  @override
  String get periodMorning => 'Morning';

  @override
  String get periodDay => 'Afternoon';

  @override
  String get periodEvening => 'Evening';

  @override
  String get periodAnytime => 'Any time';

  @override
  String get periodDone => 'Done';

  @override
  String get periodWaiting => 'Waiting';

  @override
  String get planOverline => 'TODAY\'S PLAN';

  @override
  String takenOfTotal(int done, int total) {
    return '$done of $total taken';
  }

  @override
  String get allTaken => 'All taken, a great day!';

  @override
  String leftToTake(int left) {
    return 'Left to take: $left';
  }

  @override
  String get whisper => 'Pillulkin whispers:';

  @override
  String get manageSchedule => 'Manage the schedule';

  @override
  String get editSchedule => 'Edit the schedule';

  @override
  String get endScheduleItem => 'End the schedule';

  @override
  String get scheduleAlreadyChanged =>
      'The schedule has already been changed or ended';

  @override
  String get cancelMark => 'Undo the mark';

  @override
  String get statusTaken => 'Taken';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusUnmarked => 'Not marked';

  @override
  String get skip => 'Skip';

  @override
  String get take => 'Take';

  @override
  String get endAskTitle => 'End the schedule?';

  @override
  String get endAskText => 'Past intakes stay, future ones disappear.';

  @override
  String get endConfirm => 'End';

  @override
  String get endsTomorrow =>
      'The schedule will end from the next day: today already has a mark';

  @override
  String get supplyCoversCourse => 'Enough for the whole course';

  @override
  String get supplyOverYear => 'Enough for more than a year';

  @override
  String get supplyNotToday => 'Not even enough for today';

  @override
  String supplyUntil(String date) {
    return 'Enough until $date';
  }

  @override
  String get createMedicineFirst => 'Create a medicine first';

  @override
  String get chooseMedicine => 'Choose a medicine';

  @override
  String get changesFromTomorrow =>
      'Changes apply from tomorrow: today already has a mark';

  @override
  String get notificationsOffHint =>
      'Notifications are off. Turn them on in settings to get reminders';

  @override
  String timesPerDay(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n times a day',
      one: 'once a day',
    );
    return '$_temp0';
  }

  @override
  String daysShort(int n) {
    return '$n d';
  }

  @override
  String get coursePreview => 'COURSE PREVIEW';

  @override
  String get newIntake => 'New intake';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get saveIntake => 'Save the intake';

  @override
  String get secMedicineDose => 'Medicine and dose';

  @override
  String get cabinetEmptyCreate =>
      'The cabinet has no medicines yet. Create the first one.';

  @override
  String get doseLabel => 'Dose per intake';

  @override
  String get secRepeat => 'Repeat';

  @override
  String get repeatDaily => 'Every day';

  @override
  String get repeatWeekdays => 'On weekdays';

  @override
  String get repeatDates => 'On dates';

  @override
  String get secWeekdays => 'Days of the week';

  @override
  String get secDates => 'Dates';

  @override
  String get addDate => 'Add a date';

  @override
  String get intakeDate => 'Intake date';

  @override
  String get secTimes => 'Times';

  @override
  String get addTimeOptional => 'Add a time (optional)';

  @override
  String get addTime => 'Add a time';

  @override
  String get secMeal => 'Relation to meals';

  @override
  String get mealAny => 'Any time';

  @override
  String get secPeriod => 'Period';

  @override
  String get startLabel => 'Start';

  @override
  String get startHelp => 'Start date';

  @override
  String get endOptional => 'End (optional)';

  @override
  String get endHelp => 'End date';

  @override
  String get notSpecifiedN => 'Not set';

  @override
  String get clear => 'Clear';

  @override
  String get historyTitle => 'History';

  @override
  String get historyLoadFailed => 'Could not load the history';

  @override
  String get historyEmpty => 'The history is empty';

  @override
  String get all => 'All';

  @override
  String historySummary(int days, int taken) {
    return 'Last $days d: taken $taken';
  }

  @override
  String historyMissed(int n) {
    return ', missed $n';
  }

  @override
  String get kitFever => 'Fever and pain relief';

  @override
  String get kitFeverItems => 'Paracetamol|Ibuprofen';

  @override
  String get kitAntiseptic => 'Wound antiseptics';

  @override
  String get kitAntisepticItems => 'Chlorhexidine|Hydrogen peroxide';

  @override
  String get kitDressings => 'Dressings';

  @override
  String get kitDressingsItems => 'Plasters|Bandage';

  @override
  String get kitStomach => 'Stomach and bowels';

  @override
  String get kitStomachItems => 'Activated charcoal|Diosmectite';

  @override
  String get kitAllergy => 'Allergy';

  @override
  String get kitAllergyItems => 'Chlorphenamine|Cetirizine';

  @override
  String get reasonExpired => 'Expired';

  @override
  String get reasonExpiringSoon => 'Expires soon';

  @override
  String get reasonOut => 'Out of stock';

  @override
  String get reasonLow => 'Low';

  @override
  String boughtAsk(String name) {
    return 'Did you buy $name?';
  }

  @override
  String get toCabinet => 'To the cabinet';

  @override
  String get listCopied => 'The list is copied';

  @override
  String get titleShopping => 'Shopping';

  @override
  String get secUrgent => 'Buy soon';

  @override
  String get allFine => 'All good: nothing is running out or expiring.';

  @override
  String get toList => 'To the list';

  @override
  String get secMyList => 'My list';

  @override
  String get whatToBuy => 'What to buy?';

  @override
  String get addToList => 'Add to the list';

  @override
  String get listEmpty => 'The list is empty';

  @override
  String get removeFromList => 'Remove from the list';

  @override
  String get copyList => 'Copy the list';

  @override
  String get secIdealKit => 'Build the ideal cabinet';

  @override
  String get inStock => 'In stock';

  @override
  String get inList => 'On the list';

  @override
  String get titleProfile => 'Profile';

  @override
  String get yourName => 'Your name';

  @override
  String streakDaysInRow(int n) {
    return '$n d in a row';
  }

  @override
  String get editName => 'Edit the name';

  @override
  String get secWeek => 'This week';

  @override
  String get secHealth => 'Health';

  @override
  String get diaryTitle => 'Wellbeing diary';

  @override
  String get diarySubtitle => 'Mood and what the trouble was';

  @override
  String get reportTitle => 'Doctor\'s report';

  @override
  String get reportSubtitle => 'PDF or a table for a period';

  @override
  String weekSummary(int taken, int planned, int percent) {
    return 'Last 7 days: $taken of $planned taken ($percent%)';
  }

  @override
  String goalText(int goal, int left) {
    return 'Goal: $goal days in a row, $left to go';
  }

  @override
  String get secBadges => 'Achievements';

  @override
  String get secSettings => 'Settings';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSystem => 'Like the system';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageTitle => 'Language';

  @override
  String get langSystem => 'Like the system';

  @override
  String get hapticsTitle => 'Haptics';

  @override
  String get hapticsSub => 'A nice tap when you take a dose';

  @override
  String get confettiTitle => 'Confetti on intake';

  @override
  String get confettiSub => 'A victory over routine';

  @override
  String get hintsTitle => 'Expiry hints';

  @override
  String get hintsSub => 'Tell me in the cabinet when it is time to restock';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSub => 'Permissions, a check if they do not arrive';

  @override
  String get secData => 'Data';

  @override
  String get dataNote =>
      'Data is kept on this device. If you sign in, a copy is also in the cloud. A backup file is saved by you and is not encrypted: keep it somewhere you trust.';

  @override
  String get saveBackup => 'Save a backup';

  @override
  String get restoreBackup => 'Restore from a backup';

  @override
  String get whatsYourName => 'What is your name?';

  @override
  String get weekdayDone => 'no misses';

  @override
  String get weekdayMissed => 'has misses';

  @override
  String get weekdayNoData => 'no data';

  @override
  String get badgeEarned => 'earned';

  @override
  String get badgeLocked => 'not earned';

  @override
  String get backupFailedTitle => 'Could not do it';

  @override
  String get somethingWrong => 'Something went wrong. Your data is unchanged.';

  @override
  String get backupTooLarge => 'The file is too large for a PillPal backup';

  @override
  String get backupNotBackup => 'This is not a PillPal backup';

  @override
  String get backupNewer =>
      'The backup was made by a newer PillPal or is encrypted. Update the app';

  @override
  String get backupCorrupt => 'The file is damaged or is not a backup';

  @override
  String get backupInconsistent =>
      'The backup is inconsistent and cannot be restored';

  @override
  String get backupSaved => 'The backup is saved';

  @override
  String backupDescribe(
    int medicines,
    String archived,
    int schedules,
    int logs,
    String last,
  ) {
    return '$medicines medicines$archived, $schedules schedules, $logs marks$last';
  }

  @override
  String backupArchivedPart(int n) {
    return ' ($n archived)';
  }

  @override
  String backupLastPart(String date) {
    return ', latest $date';
  }

  @override
  String get replaceTitle => 'Replace the data?';

  @override
  String replaceText(String backup, String current) {
    return 'In the backup: $backup.\n\nOn this device now: $current.\n\nAll current data will be replaced completely. This cannot be undone.';
  }

  @override
  String get saveCurrentFirst => 'Save the current data first';

  @override
  String get replace => 'Replace';

  @override
  String get dataRestored => 'The data is restored';

  @override
  String get ok => 'OK';

  @override
  String get notificationsOn => 'Reminders are on';

  @override
  String get notificationsOff => 'Reminders are off';

  @override
  String get notifDeniedText =>
      'Without permission the app cannot remind you. If the prompt does not appear, turn notifications on for PillPal in the phone settings.';

  @override
  String get notifOnText =>
      'If an intake is not marked, a second reminder comes after 15 minutes. The notification has \"Taken\", \"In 10 min\" and \"In 30 min\" buttons.';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get exactAlarms => 'Remind at the exact time';

  @override
  String get exactAlarmsSub => 'Without it Android may delay the notification';

  @override
  String get testNotification => 'Send a test notification';

  @override
  String get soundTitle => 'Sound';

  @override
  String get soundSub => 'A sound with the reminder';

  @override
  String get vibrationTitle => 'Vibration';

  @override
  String get vibrationIos => 'On iPhone the system controls vibration';

  @override
  String get vibrationSub => 'Vibrate with the reminder';

  @override
  String get quietTitle => 'Quiet hours';

  @override
  String get quietSub => 'Reminders come without sound at this time';

  @override
  String get quietFromLabel => 'From';

  @override
  String get quietToLabel => 'To';

  @override
  String get quietFromTitle => 'Quiet hours from';

  @override
  String get quietToTitle => 'Quiet hours until';

  @override
  String get batteryNote =>
      'Not arriving? On some phones battery saving stops reminders: in the phone settings let PillPal run without restrictions.';

  @override
  String get moodBad => 'Bad';

  @override
  String get moodSoSo => 'So-so';

  @override
  String get moodOk => 'Okay';

  @override
  String get moodGood => 'Good';

  @override
  String get moodGreat => 'Great';

  @override
  String get diaryEntry => 'Entry';

  @override
  String get diaryEmpty =>
      'Note how you feel and what was wrong: the entries go into the doctor\'s report';

  @override
  String get deleteEntry => 'Delete the entry';

  @override
  String get newEntry => 'New entry';

  @override
  String get howDoYouFeel => 'How do you feel';

  @override
  String get noteLabel => 'Note';

  @override
  String get reportSaved => 'The report is saved';

  @override
  String get days7 => '7 days';

  @override
  String get days30 => '30 days';

  @override
  String get days90 => '90 days';

  @override
  String get noIntakesInPeriod => 'No intakes in this period';

  @override
  String medicineTakenOf(String name, int taken, int planned) {
    return '$name: $taken of $planned taken';
  }

  @override
  String notMarkedPart(int n) {
    return ', not marked $n';
  }

  @override
  String diaryCount(int n) {
    return 'Diary entries: $n';
  }

  @override
  String get savePdf => 'Save PDF';

  @override
  String get saveCsv => 'Save a table (CSV)';

  @override
  String get welcomeTitle => 'Hi! I am PillPal';

  @override
  String get welcomeText =>
      'I will help you remember your medicines and keep track of the cabinet.';

  @override
  String get welcomeP1 => 'Intake reminders';

  @override
  String get welcomeP1t => 'A notification on time and a \"Taken\" button.';

  @override
  String get welcomeP2 => 'The cabinet under control';

  @override
  String get welcomeP2t =>
      'Stock, expiry dates and a hint when it is time to restock.';

  @override
  String get welcomeP3 => 'Your data stays yours';

  @override
  String get welcomeP3t =>
      'The data stays on this device. The cloud only if you sign in to an account.';

  @override
  String get nameOptional => 'What is your name? (optional)';

  @override
  String get enableReminders => 'Turn on reminders';

  @override
  String get skipReminders => 'Not now';

  @override
  String followUpTitle(String name) {
    return 'Forgot? $name';
  }

  @override
  String get actionTaken => 'Taken';

  @override
  String get actionSnooze => 'In 10 min';

  @override
  String get channelName => 'Intake reminders';

  @override
  String get channelDescription => 'Reminders about scheduled intakes';

  @override
  String get testNotificationBody => 'This is how reminders will look';

  @override
  String get csvTitle => 'PillPal report';

  @override
  String get csvMedicine => 'Medicine';

  @override
  String get csvPlanned => 'Planned';

  @override
  String get csvTaken => 'Taken';

  @override
  String get csvSkipped => 'Skipped';

  @override
  String get csvMissed => 'Not marked';

  @override
  String get csvDate => 'Date';

  @override
  String get csvTime => 'Time';

  @override
  String get csvMood => 'Mood (1-5)';

  @override
  String get csvNote => 'Note';

  @override
  String get pdfTitle => 'Medication report';

  @override
  String get pdfMedicines => 'Medicines';

  @override
  String get pdfNoIntakes => 'No intakes in this period.';

  @override
  String get pdfPlanned => 'Planned';

  @override
  String get pdfNoEntries => 'No entries.';

  @override
  String get pdfWhen => 'When';

  @override
  String get pdfValues => 'Measurements';

  @override
  String pdfFooter(String stamp) {
    return 'Made with PillPal on $stamp. Reference data, not a medical document.';
  }

  @override
  String moodText(int n) {
    return 'mood $n/5';
  }

  @override
  String get validatorFillOne => 'Fill in at least one field';

  @override
  String get accountTitle => 'Account and cloud';

  @override
  String get accountSubSignedOut => 'Not signed in';

  @override
  String get accountNotAvailable =>
      'The cloud is not connected to this build of the app. Your data stays on this device.';

  @override
  String get accountIntro =>
      'Sign in to keep a copy of your data (medicines, schedules, diary) in a cloud account and open it on other phones.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create an account';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get resetSent => 'A password reset email has been sent';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterEmailPassword => 'Enter your email and password';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String syncedAt(String when) {
    return 'Synced $when';
  }

  @override
  String get syncing => 'Syncing…';

  @override
  String get syncedJustNow => 'Synced';

  @override
  String get syncNow => 'Sync now';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutNote =>
      'Your data stays on this phone but stops going to the cloud.';

  @override
  String get deleteAccount => 'Delete the account';

  @override
  String get deleteAccountTitle => 'Delete the account?';

  @override
  String get deleteAccountText =>
      'The account and the cloud copy will be deleted. The data on this phone stays. Enter your password to confirm.';

  @override
  String get accountDeleted => 'The account is deleted';

  @override
  String get conflictTitle => 'There is data here and in the cloud';

  @override
  String get conflictText =>
      'Choose which to keep. The others will be replaced completely.';

  @override
  String get useCloudData => 'Use the cloud data';

  @override
  String get useDeviceData => 'Keep the data on this phone';

  @override
  String get authInvalidEmail => 'Check the email address';

  @override
  String get authWrongCredentials => 'Wrong email or password';

  @override
  String get authEmailInUse => 'This email is already registered';

  @override
  String get authWeakPassword =>
      'The password is too weak: use at least 6 characters';

  @override
  String get authNetwork =>
      'Cannot reach the server. Check the internet connection';

  @override
  String get authTooMany => 'Too many attempts. Try again later';

  @override
  String get authOther => 'That did not work. Try again';

  @override
  String get syncProblemNetwork =>
      'Could not reach the cloud. We will try again later.';

  @override
  String get syncProblemTooLarge => 'There is too much data for a cloud copy.';

  @override
  String get syncProblemOther =>
      'The cloud copy could not be used. The data on the phone is unchanged.';

  @override
  String get extendCourse => 'Extend';

  @override
  String extendCourseTitle(String name) {
    return 'Extend the course: $name';
  }

  @override
  String extendDays(int n) {
    return '$n more days';
  }

  @override
  String get actionSnooze30 => 'In 30 min';

  @override
  String get secRepeatYearly => 'Repeat the course every year';

  @override
  String get repeatYearlyHint =>
      'For seasonal courses, such as vitamin D in autumn and winter';

  @override
  String get repeatNone => 'No';

  @override
  String repeatYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n more years',
      one: '$n more year',
    );
    return '$_temp0';
  }

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomDizziness => 'Dizziness';

  @override
  String get symptomWeakness => 'Weakness';

  @override
  String get symptomFever => 'Fever';

  @override
  String get symptomStomachache => 'Stomach ache';

  @override
  String get symptomHeartburn => 'Heartburn';

  @override
  String get symptomCough => 'Cough';

  @override
  String get symptomInsomnia => 'Poor sleep';

  @override
  String get symptomRash => 'Rash';

  @override
  String get symptomAnxiety => 'Anxiety';

  @override
  String get symptomPain => 'Pain';

  @override
  String get symptomsTitle => 'What was the trouble';

  @override
  String get symptomOther => 'Other';

  @override
  String get symptomOwnTitle => 'Your own';

  @override
  String get symptomOwnLabel => 'What bothered you';

  @override
  String get csvSymptoms => 'Trouble';

  @override
  String get validatorMaxSymptoms => 'At most 12 items in an entry';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String badgesCount(int n, int total) {
    return '$n of $total earned';
  }

  @override
  String get settingsSub => 'Look, language, notifications, data copy';

  @override
  String get takeOutsideSchedule => 'Take outside the schedule';

  @override
  String get nothingToTake => 'No medicine with stock in the cabinet';
}
