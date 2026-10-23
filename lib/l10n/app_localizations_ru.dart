// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'PillPal';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get retry => 'Повторить';

  @override
  String get loading => 'Загрузка';

  @override
  String get notSpecifiedM => 'Не указан';

  @override
  String get decreaseStock => 'Уменьшить остаток';

  @override
  String get increaseStock => 'Увеличить остаток';

  @override
  String get streakTitle => 'Огненный страйк!';

  @override
  String get streakHint => 'Дни без пропусков подряд. Так держать!';

  @override
  String daysCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дней',
      many: '$n дней',
      few: '$n дня',
      one: '$n день',
    );
    return '$_temp0';
  }

  @override
  String get monShort => 'Пн';

  @override
  String get tueShort => 'Вт';

  @override
  String get wedShort => 'Ср';

  @override
  String get thuShort => 'Чт';

  @override
  String get friShort => 'Пт';

  @override
  String get satShort => 'Сб';

  @override
  String get sunShort => 'Вс';

  @override
  String get tabToday => 'Приём';

  @override
  String get tabCabinet => 'Аптечка';

  @override
  String get tabShopping => 'Покупки';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get date => 'Дата';

  @override
  String get time => 'Время';

  @override
  String get close => 'Закрыть';

  @override
  String get done => 'Готово';

  @override
  String get chooseDate => 'Выберите дату';

  @override
  String get chooseTime => 'Выберите время';

  @override
  String get previousMonth => 'Предыдущий месяц';

  @override
  String get nextMonth => 'Следующий месяц';

  @override
  String get hours => 'Часы';

  @override
  String get minutes => 'Минуты';

  @override
  String get formTablet => 'Таблетки';

  @override
  String get formCapsule => 'Капсулы';

  @override
  String get formSyrup => 'Сироп';

  @override
  String get formSolution => 'Раствор';

  @override
  String get formOintment => 'Мазь';

  @override
  String get formCream => 'Крем';

  @override
  String get formSpray => 'Спрей';

  @override
  String get formDrops => 'Капли';

  @override
  String get formPowder => 'Порошок';

  @override
  String get formSuppository => 'Суппозитории';

  @override
  String get formOther => 'Другая';

  @override
  String get catPainkiller => 'Обезболивающие и жаропонижающие';

  @override
  String get catAntipyretic => 'Жаропонижающие';

  @override
  String get catDigestive => 'ЖКТ и пищеварение';

  @override
  String get catAllergy => 'Антигистаминные';

  @override
  String get catWounds => 'Раны и перевязки';

  @override
  String get catCold => 'Лекарства от простуды';

  @override
  String get catSedative => 'Успокоительные';

  @override
  String get catCardio => 'Сердечные';

  @override
  String get catAntidepressant => 'Антидепрессанты';

  @override
  String get catHormonal => 'КОК и гормональные';

  @override
  String get catAntibiotic => 'Антибиотики';

  @override
  String get catVitamins => 'Витамины и БАДы';

  @override
  String get catOther => 'Другое';

  @override
  String get storageHome => 'Домашняя аптечка';

  @override
  String get storageFridge => 'Холодильник';

  @override
  String get storageBag => 'С собой';

  @override
  String get mealBefore => 'До еды';

  @override
  String get mealDuring => 'Во время';

  @override
  String get mealAfter => 'После еды';

  @override
  String get filterAll => 'Все';

  @override
  String get filterLowOrOut => 'Мало или нет';

  @override
  String get filterExpiringSoon => 'Скоро истекает';

  @override
  String get filterExpired => 'Просрочено';

  @override
  String get badgeFirstWeekTitle => 'Первая неделя';

  @override
  String get badgeFirstWeekHint => '7 дней подряд без пропусков';

  @override
  String get badgeCabinetKeeperTitle => 'Хозяин аптечки';

  @override
  String get badgeCabinetKeeperHint => '3 лекарства в аптечке';

  @override
  String get badgeNoExpiredTitle => 'Без просрочки';

  @override
  String get badgeNoExpiredHint => 'Аптечка без просроченных';

  @override
  String get badgeMonthTitle => 'Месяц без пропусков';

  @override
  String get badgeMonthHint => '30 дней подряд';

  @override
  String get badgeBigCabinetTitle => 'Большая аптечка';

  @override
  String get badgeBigCabinetHint => '10 лекарств в аптечке';

  @override
  String get badgeFiftyTitle => '50 приёмов';

  @override
  String get badgeFiftyHint => '50 отметок «принял» за 60 дней';

  @override
  String get badgePerfectWeekTitle => 'Идеальная неделя';

  @override
  String get badgePerfectWeekHint => 'Все приёмы за 7 дней отмечены';

  @override
  String get badgeDiaryTitle => 'Дневник начат';

  @override
  String get badgeDiaryHint => '3 записи о самочувствии';

  @override
  String get unitPcs => 'шт.';

  @override
  String get unitMl => 'мл';

  @override
  String get unitG => 'г';

  @override
  String get unitDoses => 'доз';

  @override
  String get negativeStock => 'Остаток не может быть отрицательным';

  @override
  String get disposalHint =>
      'Проверьте инструкцию и местные правила утилизации';

  @override
  String get stockLabel => 'Остаток';

  @override
  String expiredSince(String date) {
    return 'Просрочено с $date';
  }

  @override
  String expiringBadge(String date, String when) {
    return 'Скоро истекает: до $date ($when)';
  }

  @override
  String get whenToday => 'сегодня';

  @override
  String whenInDays(int n) {
    return 'через $n дн.';
  }

  @override
  String get outBadge => 'Закончилось';

  @override
  String lowBadge(String qty) {
    return 'Мало: осталось $qty';
  }

  @override
  String goodUntil(String date) {
    return 'Годен до $date';
  }

  @override
  String searchMedicines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лекарствам',
      many: '$count лекарствам',
      few: '$count лекарствам',
      one: '$count лекарству',
    );
    return 'Поиск по $_temp0';
  }

  @override
  String get backToCabinet => 'Вернуться в аптечку';

  @override
  String get archive => 'Архив';

  @override
  String get titleCabinet => 'Аптечка';

  @override
  String get addMedicine => 'Добавить лекарство';

  @override
  String get cabinetLoadFailed => 'Не удалось загрузить аптечку';

  @override
  String get archiveEmptyTitle => 'Архив пуст';

  @override
  String get archiveEmptyText =>
      'Сюда попадают лекарства, убранные из аптечки.';

  @override
  String get cabinetEmptyTitle => 'В аптечке пока пусто';

  @override
  String get cabinetEmptyText =>
      'Добавьте первое лекарство, чтобы следить за остатком и сроком годности.';

  @override
  String get noMedicinesWithStatus => 'Нет лекарств с таким статусом';

  @override
  String get showAll => 'Показать все';

  @override
  String get readinessOverline => 'ГОТОВНОСТЬ АПТЕЧКИ';

  @override
  String okPercent(int percent) {
    return 'В порядке: $percent%';
  }

  @override
  String get tileTotal => 'Всего';

  @override
  String get tileExpiring => 'Истекают';

  @override
  String get tileLow => 'Мало';

  @override
  String timeToBuy(int count) {
    return 'Пора докупить: $count — загляните во вкладку «Покупки»';
  }

  @override
  String get allCategories => 'Все категории';

  @override
  String get pQuantityNegative => 'Количество не может быть отрицательным';

  @override
  String get pMedicineArchived => 'Лекарство в архиве';

  @override
  String pUnitMustBe(String unit) {
    return 'Единица должна быть «$unit»';
  }

  @override
  String get pNameRequired => 'Название обязательно';

  @override
  String get pUnitRequired => 'Укажите единицу учёта';

  @override
  String get pThresholdNegative => 'Порог не может быть отрицательным';

  @override
  String get pDosePositive => 'Дозировка должна быть больше нуля';

  @override
  String get pDoseUnitRequired => 'Укажите единицу дозировки';

  @override
  String get pPickWeekdays => 'Выберите дни недели';

  @override
  String get pPickDates => 'Выберите даты';

  @override
  String get pEndBeforeStart => 'Дата окончания раньше даты начала';

  @override
  String get pBadTime => 'Некорректное время';

  @override
  String get pAlreadyTaken => 'Приём уже отмечен как принятый';

  @override
  String get pNoDeductions => 'Списания для этой отметки не сохранены';

  @override
  String get newMedicine => 'Новое лекарство';

  @override
  String get medicineTitle => 'Лекарство';

  @override
  String get addToCabinet => 'Добавить в аптечку';

  @override
  String get secBasic => 'Основное';

  @override
  String get nameLabel => 'Название *';

  @override
  String get nameHint => 'Например, Ибупрофен Форте';

  @override
  String get enterName => 'Введите название';

  @override
  String get secCategory => 'Категория действия';

  @override
  String get secForm => 'Форма выпуска';

  @override
  String get strengthLabel => 'Дозировка или концентрация';

  @override
  String get strengthHint => 'Например, 500 мг';

  @override
  String get secStorage => 'Где хранить?';

  @override
  String get secStock => 'Запас';

  @override
  String get initialQuantity => 'Начальное количество';

  @override
  String get enterNumberZero => 'Введите число 0 или больше';

  @override
  String get unitLabel => 'Единица';

  @override
  String get expiryLabel => 'Срок годности';

  @override
  String get clearExpiry => 'Убрать срок годности';

  @override
  String get thresholdLabel => 'Порог низкого остатка (необязательно)';

  @override
  String get thresholdHelper => 'По умолчанию: 20% от самой большой упаковки';

  @override
  String get secLook => 'Внешний вид';

  @override
  String get drawPill => 'Как выглядит';

  @override
  String get pillShape => 'Форма';

  @override
  String get pillColor => 'Цвет';

  @override
  String get pillColor2 => 'Цвет второй половины';

  @override
  String get pillScore => 'Разрез';

  @override
  String get shapeRound => 'Круглая';

  @override
  String get shapeOval => 'Овальная';

  @override
  String get shapeCaplet => 'Продолговатая';

  @override
  String get shapeCapsule => 'Капсула';

  @override
  String get shapeSquare => 'Квадратная';

  @override
  String get scoreNone => 'Без разреза';

  @override
  String get scoreLine => 'Одна линия';

  @override
  String get scoreCross => 'Крест';

  @override
  String colorSwatch(int n) {
    return 'Цвет $n';
  }

  @override
  String get edit => 'Изменить';

  @override
  String get toArchive => 'В архив';

  @override
  String get restoreFromArchive => 'Вернуть из архива';

  @override
  String get inArchiveBadge => 'В архиве';

  @override
  String stockSemantics(String quantity) {
    return 'Остаток: $quantity';
  }

  @override
  String get totalStock => 'Общий остаток';

  @override
  String get stockInPackage => 'Остаток в упаковке';

  @override
  String get secPackages => 'Упаковки';

  @override
  String get takeNow => 'Принять сейчас';

  @override
  String get addPackage => 'Добавить упаковку';

  @override
  String get addedToShopping => 'Добавлено в список покупок';

  @override
  String get toShoppingList => 'В список покупок';

  @override
  String get archiveAskTitle => 'Убрать в архив?';

  @override
  String get archiveAskText =>
      'Действующие расписания этого лекарства будут завершены, напоминания отключены. Прошлые приёмы и история остатков сохранятся.';

  @override
  String get medicineRestored =>
      'Лекарство возвращено. Завершённые расписания нужно создать заново';

  @override
  String takenRecorded(String qty) {
    return 'Записано: $qty';
  }

  @override
  String expiryPassed(String date) {
    return 'Срок годности истёк $date';
  }

  @override
  String get packageOut => 'Закончилась';

  @override
  String get expiringSoonShort => 'Скоро истекает';

  @override
  String get otherUnitNote =>
      'Другая единица: не входит в остаток и не расходуется приёмами';

  @override
  String get packageTooltip => 'Упаковка';

  @override
  String get correctStock => 'Скорректировать остаток';

  @override
  String get expiryTitle => 'Срок годности';

  @override
  String get movementHistory => 'История движения';

  @override
  String get staleQuantity =>
      'Остаток изменился. Откройте корректировку заново';

  @override
  String get noMovements => 'Движений нет';

  @override
  String stockAfter(String qty, String when) {
    return 'Остаток $qty · $when';
  }

  @override
  String get txInitial => 'Начальный остаток';

  @override
  String get txIncrease => 'Приход';

  @override
  String get txDecrease => 'Расход';

  @override
  String get txCorrection => 'Коррекция';

  @override
  String get newPackage => 'Новая упаковка';

  @override
  String get quantityLabel => 'Количество';

  @override
  String get add => 'Добавить';

  @override
  String get actualStock => 'Фактический остаток';

  @override
  String leftOfTotal(int left, int total) {
    return 'Осталось $left из $total';
  }

  @override
  String get howManyTaken => 'Сколько приняли';

  @override
  String get enterPositive => 'Введите число больше нуля';

  @override
  String get record => 'Записать';

  @override
  String get tip1 =>
      'Не забудь выпить стакан воды: таблетки лучше усваиваются.';

  @override
  String get tip2 =>
      'Поставь аптечку на видное место: так проще не пропускать приём.';

  @override
  String get tip3 => 'Каждая отметка — маленькая победа. Серия растёт!';

  @override
  String get tip4 =>
      'Проверь сроки годности раз в месяц: я подскажу, что скоро истечёт.';

  @override
  String get notEnoughStock => 'В аптечке не хватает лекарства';

  @override
  String get addIntake => 'Добавить приём';

  @override
  String get historyTooltip => 'История';

  @override
  String get wholeMonth => 'Весь месяц';

  @override
  String get loadIntakesFailed => 'Не удалось загрузить приёмы';

  @override
  String get noIntakesTitle => 'На этот день приёмов нет';

  @override
  String get noIntakesText => 'Нажмите «+», чтобы добавить приём';

  @override
  String courseLastDay(String name) {
    return 'Сегодня последний день курса: $name';
  }

  @override
  String courseEnds(String name, String date) {
    return 'Курс $name заканчивается $date';
  }

  @override
  String get periodMorning => 'Утро';

  @override
  String get periodDay => 'День';

  @override
  String get periodEvening => 'Вечер';

  @override
  String get periodAnytime => 'В течение дня';

  @override
  String get periodDone => 'Выполнено';

  @override
  String get periodWaiting => 'Ожидает';

  @override
  String get planOverline => 'ПЛАН ДНЯ';

  @override
  String takenOfTotal(int done, int total) {
    return '$done из $total принято';
  }

  @override
  String get allTaken => 'Всё принято — отличный день!';

  @override
  String leftToTake(int left) {
    return 'Осталось принять: $left';
  }

  @override
  String get whisper => 'Пилюлькин шепчет:';

  @override
  String get manageSchedule => 'Управление расписанием';

  @override
  String get editSchedule => 'Изменить расписание';

  @override
  String get endScheduleItem => 'Завершить расписание';

  @override
  String get scheduleAlreadyChanged => 'Расписание уже изменено или завершено';

  @override
  String get cancelMark => 'Отменить отметку';

  @override
  String get statusTaken => 'Принято';

  @override
  String get statusSkipped => 'Пропущено';

  @override
  String get statusUnmarked => 'Не отмечено';

  @override
  String get skip => 'Пропустить';

  @override
  String get take => 'Принять';

  @override
  String get endAskTitle => 'Завершить расписание?';

  @override
  String get endAskText => 'Прошлые приёмы сохранятся, будущие исчезнут.';

  @override
  String get endConfirm => 'Завершить';

  @override
  String get endsTomorrow =>
      'Расписание завершится со следующего дня: сегодня уже есть отметка';

  @override
  String get supplyCoversCourse => 'Хватит на весь курс';

  @override
  String get supplyOverYear => 'Хватит больше чем на год';

  @override
  String get supplyNotToday => 'Не хватит даже на сегодня';

  @override
  String supplyUntil(String date) {
    return 'Хватит до $date';
  }

  @override
  String get createMedicineFirst => 'Сначала создайте лекарство';

  @override
  String get chooseMedicine => 'Выберите лекарство';

  @override
  String get changesFromTomorrow =>
      'Изменения вступят в силу с завтрашнего дня: сегодня уже есть отметка';

  @override
  String get notificationsOffHint =>
      'Уведомления выключены. Включите их в настройках, чтобы получать напоминания';

  @override
  String timesPerDay(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n раза в день',
      many: '$n раз в день',
      few: '$n раза в день',
      one: '$n раз в день',
    );
    return '$_temp0';
  }

  @override
  String daysShort(int n) {
    return '$n дн.';
  }

  @override
  String get coursePreview => 'ПРЕДПРОСМОТР КУРСА';

  @override
  String get newIntake => 'Новый приём';

  @override
  String get scheduleTitle => 'Расписание';

  @override
  String get saveIntake => 'Сохранить приём';

  @override
  String get secMedicineDose => 'Лекарство и дозировка';

  @override
  String get cabinetEmptyCreate =>
      'В аптечке пока нет лекарств. Создайте первое.';

  @override
  String get doseLabel => 'Дозировка за один приём';

  @override
  String get secRepeat => 'Повторение';

  @override
  String get repeatDaily => 'Каждый день';

  @override
  String get repeatWeekdays => 'По дням';

  @override
  String get repeatDates => 'По датам';

  @override
  String get secWeekdays => 'Дни недели';

  @override
  String get secDates => 'Даты';

  @override
  String get addDate => 'Добавить дату';

  @override
  String get intakeDate => 'Дата приёма';

  @override
  String get secTimes => 'Время приёма';

  @override
  String get addTimeOptional => 'Добавить время (необязательно)';

  @override
  String get addTime => 'Добавить время';

  @override
  String get secMeal => 'Связь с приёмом пищи';

  @override
  String get mealAny => 'Не важно';

  @override
  String get secPeriod => 'Период';

  @override
  String get startLabel => 'Начало';

  @override
  String get startHelp => 'Дата начала';

  @override
  String get endOptional => 'Окончание (необязательно)';

  @override
  String get endHelp => 'Дата окончания';

  @override
  String get notSpecifiedN => 'Не указано';

  @override
  String get clear => 'Очистить';

  @override
  String get historyTitle => 'История';

  @override
  String get historyLoadFailed => 'Не удалось загрузить историю';

  @override
  String get historyEmpty => 'История пуста';

  @override
  String get all => 'Все';

  @override
  String historySummary(int days, int taken) {
    return 'За $days дн.: принято $taken';
  }

  @override
  String historyMissed(int n) {
    return ', пропущено $n';
  }

  @override
  String get kitFever => 'Жаропонижающие и обезболивающие';

  @override
  String get kitFeverItems => 'Парацетамол|Ибупрофен';

  @override
  String get kitAntiseptic => 'Антисептики для ран';

  @override
  String get kitAntisepticItems => 'Хлоргексидин|Мирамистин';

  @override
  String get kitDressings => 'Перевязочные материалы';

  @override
  String get kitDressingsItems => 'Пластырь|Бинт';

  @override
  String get kitStomach => 'Желудок и кишечник';

  @override
  String get kitStomachItems => 'Активированный уголь|Смекта';

  @override
  String get kitAllergy => 'Аллергия';

  @override
  String get kitAllergyItems => 'Супрастин|Цетиризин';

  @override
  String get reasonExpired => 'Просрочено';

  @override
  String get reasonExpiringSoon => 'Скоро срок';

  @override
  String get reasonOut => 'Закончилось';

  @override
  String get reasonLow => 'Мало';

  @override
  String boughtAsk(String name) {
    return 'Купили $name?';
  }

  @override
  String get toCabinet => 'В аптечку';

  @override
  String get listCopied => 'Список скопирован';

  @override
  String get titleShopping => 'Покупки';

  @override
  String get secUrgent => 'Срочно докупить';

  @override
  String get allFine => 'Всё в порядке: ничего не заканчивается и не истекает.';

  @override
  String get toList => 'В список';

  @override
  String get secMyList => 'Мой список';

  @override
  String get whatToBuy => 'Что купить?';

  @override
  String get addToList => 'Добавить в список';

  @override
  String get listEmpty => 'Список пуст';

  @override
  String get removeFromList => 'Убрать из списка';

  @override
  String get copyList => 'Скопировать список';

  @override
  String get secIdealKit => 'Собери идеальную аптечку';

  @override
  String get inStock => 'В наличии';

  @override
  String get inList => 'В списке';

  @override
  String get titleProfile => 'Профиль';

  @override
  String get yourName => 'Ваше имя';

  @override
  String streakDaysInRow(int n) {
    return '$n дн. подряд';
  }

  @override
  String get editName => 'Изменить имя';

  @override
  String get secWeek => 'Итоги недели';

  @override
  String get secHealth => 'Здоровье';

  @override
  String get diaryTitle => 'Дневник самочувствия';

  @override
  String get diarySubtitle => 'Настроение, с чем была проблема';

  @override
  String get reportTitle => 'Отчёт для врача';

  @override
  String get reportSubtitle => 'PDF или таблица за период';

  @override
  String weekSummary(int taken, int planned, int percent) {
    return 'За 7 дней принято $taken из $planned ($percent%)';
  }

  @override
  String goalText(int goal, int left) {
    return 'Цель: $goal дней подряд, осталось $left';
  }

  @override
  String get secBadges => 'Достижения';

  @override
  String get secSettings => 'Настройки';

  @override
  String get themeTitle => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get languageTitle => 'Язык';

  @override
  String get langSystem => 'Как в системе';

  @override
  String get hapticsTitle => 'Тактильный отклик';

  @override
  String get hapticsSub => 'Приятная отдача при приёме';

  @override
  String get confettiTitle => 'Конфетти при приёме';

  @override
  String get confettiSub => 'Анимация победы над рутиной';

  @override
  String get hintsTitle => 'Подсказки о сроках';

  @override
  String get hintsSub => 'Напоминать в аптечке, что пора докупить';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsSub => 'Разрешения, проверка, если не приходят';

  @override
  String get secData => 'Данные';

  @override
  String get dataNote =>
      'Данные хранятся на этом устройстве. Если войти в аккаунт, их копия есть и в облаке. Файл резервной копии вы сохраняете сами, он не зашифрован: храните его там, где доверяете.';

  @override
  String get saveBackup => 'Сохранить резервную копию';

  @override
  String get restoreBackup => 'Восстановить из копии';

  @override
  String get whatsYourName => 'Как вас зовут?';

  @override
  String get weekdayDone => 'без пропусков';

  @override
  String get weekdayMissed => 'есть пропуски';

  @override
  String get weekdayNoData => 'нет данных';

  @override
  String get badgeEarned => 'получено';

  @override
  String get badgeLocked => 'не получено';

  @override
  String get backupFailedTitle => 'Не удалось';

  @override
  String get somethingWrong => 'Что-то пошло не так. Данные не изменены.';

  @override
  String get backupTooLarge =>
      'Файл слишком большой для резервной копии PillPal';

  @override
  String get backupNotBackup => 'Это не резервная копия PillPal';

  @override
  String get backupNewer =>
      'Копия создана более новой версией PillPal или зашифрована. Обновите приложение';

  @override
  String get backupCorrupt => 'Файл повреждён или не является резервной копией';

  @override
  String get backupInconsistent =>
      'Резервная копия противоречива и не может быть восстановлена';

  @override
  String get backupSaved => 'Копия сохранена';

  @override
  String backupDescribe(
    int medicines,
    String archived,
    int schedules,
    int logs,
    String last,
  ) {
    return '$medicines лекарств$archived, $schedules расписаний, $logs отметок$last';
  }

  @override
  String backupArchivedPart(int n) {
    return ' (в архиве: $n)';
  }

  @override
  String backupLastPart(String date) {
    return ', последняя $date';
  }

  @override
  String get replaceTitle => 'Заменить данные?';

  @override
  String replaceText(String backup, String current) {
    return 'В копии: $backup.\n\nСейчас на устройстве: $current.\n\nВсе текущие данные будут заменены полностью. Это нельзя отменить.';
  }

  @override
  String get saveCurrentFirst => 'Сначала сохранить текущие';

  @override
  String get replace => 'Заменить';

  @override
  String get dataRestored => 'Данные восстановлены';

  @override
  String get ok => 'OK';

  @override
  String get notificationsOn => 'Напоминания включены';

  @override
  String get notificationsOff => 'Напоминания выключены';

  @override
  String get notifDeniedText =>
      'Без разрешения приложение не сможет напомнить о приёме. Если окно с запросом не появляется, включите уведомления для PillPal в настройках телефона.';

  @override
  String get notifOnText =>
      'Если приём не отмечен, через 15 минут придёт второе напоминание. В уведомлении есть кнопки «Принял», «Через 10 мин» и «Через 30 мин».';

  @override
  String get allowNotifications => 'Разрешить уведомления';

  @override
  String get exactAlarms => 'Напоминать точно по времени';

  @override
  String get exactAlarmsSub => 'Без этого Android может задержать уведомление';

  @override
  String get testNotification => 'Проверить уведомление';

  @override
  String get soundTitle => 'Звук';

  @override
  String get soundSub => 'Сигнал при напоминании';

  @override
  String get vibrationTitle => 'Вибрация';

  @override
  String get vibrationIos => 'На iPhone вибрацией управляет система';

  @override
  String get vibrationSub => 'Вибрировать при напоминании';

  @override
  String get quietTitle => 'Тихие часы';

  @override
  String get quietSub => 'В это время напоминания приходят без звука';

  @override
  String get quietFromLabel => 'С';

  @override
  String get quietToLabel => 'До';

  @override
  String get quietFromTitle => 'Тихие часы с';

  @override
  String get quietToTitle => 'Тихие часы до';

  @override
  String get batteryNote =>
      'Не приходят? На некоторых телефонах экономия заряда останавливает напоминания: в настройках телефона разрешите PillPal работать без ограничений.';

  @override
  String get moodBad => 'Плохо';

  @override
  String get moodSoSo => 'Так себе';

  @override
  String get moodOk => 'Нормально';

  @override
  String get moodGood => 'Хорошо';

  @override
  String get moodGreat => 'Отлично';

  @override
  String get diaryEntry => 'Запись';

  @override
  String get diaryEmpty =>
      'Отмечайте самочувствие и с чем была проблема: записи попадут в отчёт для врача';

  @override
  String get deleteEntry => 'Удалить запись';

  @override
  String get newEntry => 'Новая запись';

  @override
  String get howDoYouFeel => 'Самочувствие';

  @override
  String get noteLabel => 'Заметка';

  @override
  String get reportSaved => 'Отчёт сохранён';

  @override
  String get days7 => '7 дней';

  @override
  String get days30 => '30 дней';

  @override
  String get days90 => '90 дней';

  @override
  String get noIntakesInPeriod => 'За этот период приёмов не было';

  @override
  String medicineTakenOf(String name, int taken, int planned) {
    return '$name: принято $taken из $planned';
  }

  @override
  String notMarkedPart(int n) {
    return ', не отмечено $n';
  }

  @override
  String diaryCount(int n) {
    return 'Записей в дневнике: $n';
  }

  @override
  String get savePdf => 'Сохранить PDF';

  @override
  String get saveCsv => 'Сохранить таблицу (CSV)';

  @override
  String get welcomeTitle => 'Привет! Я PillPal';

  @override
  String get welcomeText =>
      'Помогу не забывать про лекарства и следить за аптечкой.';

  @override
  String get welcomeP1 => 'Напоминания о приёме';

  @override
  String get welcomeP1t => 'Уведомление в нужное время и кнопка «Принял».';

  @override
  String get welcomeP2 => 'Аптечка под контролем';

  @override
  String get welcomeP2t =>
      'Остатки, сроки годности и подсказка, что пора докупить.';

  @override
  String get welcomeP3 => 'Всё хранится у вас';

  @override
  String get welcomeP3t =>
      'Данные остаются на этом устройстве. Облако — только если вы войдёте в аккаунт.';

  @override
  String get nameOptional => 'Как вас зовут? (необязательно)';

  @override
  String get enableReminders => 'Включить напоминания';

  @override
  String get skipReminders => 'Пока без напоминаний';

  @override
  String followUpTitle(String name) {
    return 'Не забыли? $name';
  }

  @override
  String get actionTaken => 'Принял';

  @override
  String get actionSnooze => 'Через 10 мин';

  @override
  String get channelName => 'Напоминания о приёме';

  @override
  String get channelDescription => 'Напоминания о запланированных приёмах';

  @override
  String get testNotificationBody => 'Так будут выглядеть напоминания';

  @override
  String get csvTitle => 'Отчёт PillPal';

  @override
  String get csvMedicine => 'Лекарство';

  @override
  String get csvPlanned => 'Запланировано';

  @override
  String get csvTaken => 'Принято';

  @override
  String get csvSkipped => 'Пропущено';

  @override
  String get csvMissed => 'Не отмечено';

  @override
  String get csvDate => 'Дата';

  @override
  String get csvTime => 'Время';

  @override
  String get csvMood => 'Самочувствие (1-5)';

  @override
  String get csvNote => 'Заметка';

  @override
  String get pdfTitle => 'Отчёт о приёме лекарств';

  @override
  String get pdfMedicines => 'Лекарства';

  @override
  String get pdfNoIntakes => 'За этот период приёмов не было.';

  @override
  String get pdfPlanned => 'По плану';

  @override
  String get pdfNoEntries => 'Записей нет.';

  @override
  String get pdfWhen => 'Когда';

  @override
  String get pdfValues => 'Показатели';

  @override
  String pdfFooter(String stamp) {
    return 'Сформировано в PillPal $stamp. Справочные данные, не медицинский документ.';
  }

  @override
  String moodText(int n) {
    return 'самочувствие $n/5';
  }

  @override
  String get validatorFillOne => 'Заполните хотя бы одно поле';

  @override
  String get accountTitle => 'Аккаунт и облако';

  @override
  String get accountSubSignedOut => 'Не выполнен вход';

  @override
  String get accountNotAvailable =>
      'Облако пока не подключено к этой сборке приложения. Данные хранятся на этом устройстве.';

  @override
  String get accountIntro =>
      'Войдите, чтобы хранить копию данных (лекарства, расписания, дневник) в облачном аккаунте и открывать её на других телефонах.';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get resetSent => 'Письмо для сброса пароля отправлено';

  @override
  String get enterEmail => 'Введите почту';

  @override
  String get enterEmailPassword => 'Введите почту и пароль';

  @override
  String signedInAs(String email) {
    return 'Вы вошли как $email';
  }

  @override
  String syncedAt(String when) {
    return 'Синхронизировано $when';
  }

  @override
  String get syncing => 'Синхронизация…';

  @override
  String get syncedJustNow => 'Синхронизировано';

  @override
  String get syncNow => 'Синхронизировать сейчас';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutNote =>
      'Данные останутся на этом телефоне, но перестанут отправляться в облако.';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountText =>
      'Аккаунт и копия данных в облаке будут удалены. Данные на этом телефоне останутся. Введите пароль, чтобы подтвердить.';

  @override
  String get accountDeleted => 'Аккаунт удалён';

  @override
  String get conflictTitle => 'Данные есть и здесь, и в облаке';

  @override
  String get conflictText =>
      'Выберите, какие оставить. Вторые будут заменены полностью.';

  @override
  String get useCloudData => 'Взять данные из облака';

  @override
  String get useDeviceData => 'Оставить данные с этого телефона';

  @override
  String get authInvalidEmail => 'Проверьте адрес почты';

  @override
  String get authWrongCredentials => 'Неверная почта или пароль';

  @override
  String get authEmailInUse => 'Эта почта уже зарегистрирована';

  @override
  String get authWeakPassword =>
      'Пароль слишком простой: нужно хотя бы 6 символов';

  @override
  String get authNetwork => 'Нет связи с сервером. Проверьте интернет';

  @override
  String get authTooMany => 'Слишком много попыток. Попробуйте позже';

  @override
  String get authOther => 'Не получилось. Попробуйте ещё раз';

  @override
  String get syncProblemNetwork =>
      'Не удалось связаться с облаком. Попробуем снова позже.';

  @override
  String get syncProblemTooLarge => 'Данных слишком много для облачной копии.';

  @override
  String get syncProblemOther =>
      'Облачная копия не подошла. Данные на телефоне не изменены.';

  @override
  String get extendCourse => 'Продлить';

  @override
  String extendCourseTitle(String name) {
    return 'Продлить курс: $name';
  }

  @override
  String extendDays(int n) {
    return 'Ещё $n дн.';
  }

  @override
  String get actionSnooze30 => 'Через 30 мин';

  @override
  String get secRepeatYearly => 'Повторять курс каждый год';

  @override
  String get repeatYearlyHint =>
      'Для сезонных курсов, например витамина D осенью и зимой';

  @override
  String get repeatNone => 'Нет';

  @override
  String repeatYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'ещё $n года',
      many: 'ещё $n лет',
      few: 'ещё $n года',
      one: 'ещё $n год',
    );
    return '$_temp0';
  }

  @override
  String get symptomHeadache => 'Головная боль';

  @override
  String get symptomNausea => 'Тошнота';

  @override
  String get symptomDizziness => 'Головокружение';

  @override
  String get symptomWeakness => 'Слабость';

  @override
  String get symptomFever => 'Температура';

  @override
  String get symptomStomachache => 'Боль в животе';

  @override
  String get symptomHeartburn => 'Изжога';

  @override
  String get symptomCough => 'Кашель';

  @override
  String get symptomInsomnia => 'Плохой сон';

  @override
  String get symptomRash => 'Сыпь';

  @override
  String get symptomAnxiety => 'Тревога';

  @override
  String get symptomPain => 'Боль';

  @override
  String get symptomsTitle => 'С чем была проблема';

  @override
  String get symptomOther => 'Другое';

  @override
  String get symptomOwnTitle => 'Своё';

  @override
  String get symptomOwnLabel => 'Что беспокоило';

  @override
  String get csvSymptoms => 'Проблема';

  @override
  String get validatorMaxSymptoms => 'Не больше 12 пунктов в записи';

  @override
  String get achievementsTitle => 'Достижения';

  @override
  String badgesCount(int n, int total) {
    return 'Получено $n из $total';
  }

  @override
  String get settingsSub => 'Вид, язык, уведомления, копия данных';

  @override
  String get takeOutsideSchedule => 'Принять вне расписания';

  @override
  String get nothingToTake => 'В аптечке нет лекарств с остатком';
}
