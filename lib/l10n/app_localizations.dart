import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'PillPal'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка'**
  String get loading;

  /// No description provided for @notSpecifiedM.
  ///
  /// In ru, this message translates to:
  /// **'Не указан'**
  String get notSpecifiedM;

  /// No description provided for @decreaseStock.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить остаток'**
  String get decreaseStock;

  /// No description provided for @increaseStock.
  ///
  /// In ru, this message translates to:
  /// **'Увеличить остаток'**
  String get increaseStock;

  /// No description provided for @streakTitle.
  ///
  /// In ru, this message translates to:
  /// **'Огненный страйк!'**
  String get streakTitle;

  /// No description provided for @streakHint.
  ///
  /// In ru, this message translates to:
  /// **'Дни без пропусков подряд. Так держать!'**
  String get streakHint;

  /// No description provided for @daysCount.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{{n} день} few{{n} дня} many{{n} дней} other{{n} дней}}'**
  String daysCount(int n);

  /// No description provided for @monShort.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get monShort;

  /// No description provided for @tueShort.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get tueShort;

  /// No description provided for @wedShort.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get wedShort;

  /// No description provided for @thuShort.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get thuShort;

  /// No description provided for @friShort.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get friShort;

  /// No description provided for @satShort.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get satShort;

  /// No description provided for @sunShort.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get sunShort;

  /// No description provided for @tabToday.
  ///
  /// In ru, this message translates to:
  /// **'Приём'**
  String get tabToday;

  /// No description provided for @tabCabinet.
  ///
  /// In ru, this message translates to:
  /// **'Аптечка'**
  String get tabCabinet;

  /// No description provided for @tabShopping.
  ///
  /// In ru, this message translates to:
  /// **'Покупки'**
  String get tabShopping;

  /// No description provided for @tabProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get tabProfile;

  /// No description provided for @date.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get date;

  /// No description provided for @time.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get time;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @chooseDate.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дату'**
  String get chooseDate;

  /// No description provided for @chooseTime.
  ///
  /// In ru, this message translates to:
  /// **'Выберите время'**
  String get chooseTime;

  /// No description provided for @previousMonth.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущий месяц'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In ru, this message translates to:
  /// **'Следующий месяц'**
  String get nextMonth;

  /// No description provided for @hours.
  ///
  /// In ru, this message translates to:
  /// **'Часы'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In ru, this message translates to:
  /// **'Минуты'**
  String get minutes;

  /// No description provided for @formTablet.
  ///
  /// In ru, this message translates to:
  /// **'Таблетки'**
  String get formTablet;

  /// No description provided for @formCapsule.
  ///
  /// In ru, this message translates to:
  /// **'Капсулы'**
  String get formCapsule;

  /// No description provided for @formSyrup.
  ///
  /// In ru, this message translates to:
  /// **'Сироп'**
  String get formSyrup;

  /// No description provided for @formSolution.
  ///
  /// In ru, this message translates to:
  /// **'Раствор'**
  String get formSolution;

  /// No description provided for @formOintment.
  ///
  /// In ru, this message translates to:
  /// **'Мазь'**
  String get formOintment;

  /// No description provided for @formCream.
  ///
  /// In ru, this message translates to:
  /// **'Крем'**
  String get formCream;

  /// No description provided for @formSpray.
  ///
  /// In ru, this message translates to:
  /// **'Спрей'**
  String get formSpray;

  /// No description provided for @formDrops.
  ///
  /// In ru, this message translates to:
  /// **'Капли'**
  String get formDrops;

  /// No description provided for @formPowder.
  ///
  /// In ru, this message translates to:
  /// **'Порошок'**
  String get formPowder;

  /// No description provided for @formSuppository.
  ///
  /// In ru, this message translates to:
  /// **'Суппозитории'**
  String get formSuppository;

  /// No description provided for @formOther.
  ///
  /// In ru, this message translates to:
  /// **'Другая'**
  String get formOther;

  /// No description provided for @catPainkiller.
  ///
  /// In ru, this message translates to:
  /// **'Обезболивающие и жаропонижающие'**
  String get catPainkiller;

  /// No description provided for @catAntipyretic.
  ///
  /// In ru, this message translates to:
  /// **'Жаропонижающие'**
  String get catAntipyretic;

  /// No description provided for @catDigestive.
  ///
  /// In ru, this message translates to:
  /// **'ЖКТ и пищеварение'**
  String get catDigestive;

  /// No description provided for @catAllergy.
  ///
  /// In ru, this message translates to:
  /// **'Антигистаминные'**
  String get catAllergy;

  /// No description provided for @catWounds.
  ///
  /// In ru, this message translates to:
  /// **'Раны и перевязки'**
  String get catWounds;

  /// No description provided for @catCold.
  ///
  /// In ru, this message translates to:
  /// **'Лекарства от простуды'**
  String get catCold;

  /// No description provided for @catSedative.
  ///
  /// In ru, this message translates to:
  /// **'Успокоительные'**
  String get catSedative;

  /// No description provided for @catCardio.
  ///
  /// In ru, this message translates to:
  /// **'Сердечные'**
  String get catCardio;

  /// No description provided for @catAntidepressant.
  ///
  /// In ru, this message translates to:
  /// **'Антидепрессанты'**
  String get catAntidepressant;

  /// No description provided for @catHormonal.
  ///
  /// In ru, this message translates to:
  /// **'КОК и гормональные'**
  String get catHormonal;

  /// No description provided for @catAntibiotic.
  ///
  /// In ru, this message translates to:
  /// **'Антибиотики'**
  String get catAntibiotic;

  /// No description provided for @catVitamins.
  ///
  /// In ru, this message translates to:
  /// **'Витамины и БАДы'**
  String get catVitamins;

  /// No description provided for @catOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get catOther;

  /// No description provided for @storageHome.
  ///
  /// In ru, this message translates to:
  /// **'Домашняя аптечка'**
  String get storageHome;

  /// No description provided for @storageFridge.
  ///
  /// In ru, this message translates to:
  /// **'Холодильник'**
  String get storageFridge;

  /// No description provided for @storageBag.
  ///
  /// In ru, this message translates to:
  /// **'С собой'**
  String get storageBag;

  /// No description provided for @mealBefore.
  ///
  /// In ru, this message translates to:
  /// **'До еды'**
  String get mealBefore;

  /// No description provided for @mealDuring.
  ///
  /// In ru, this message translates to:
  /// **'Во время'**
  String get mealDuring;

  /// No description provided for @mealAfter.
  ///
  /// In ru, this message translates to:
  /// **'После еды'**
  String get mealAfter;

  /// No description provided for @filterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get filterAll;

  /// No description provided for @filterLowOrOut.
  ///
  /// In ru, this message translates to:
  /// **'Мало или нет'**
  String get filterLowOrOut;

  /// No description provided for @filterExpiringSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро истекает'**
  String get filterExpiringSoon;

  /// No description provided for @filterExpired.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get filterExpired;

  /// No description provided for @badgeFirstWeekTitle.
  ///
  /// In ru, this message translates to:
  /// **'Первая неделя'**
  String get badgeFirstWeekTitle;

  /// No description provided for @badgeFirstWeekHint.
  ///
  /// In ru, this message translates to:
  /// **'7 дней подряд без пропусков'**
  String get badgeFirstWeekHint;

  /// No description provided for @badgeCabinetKeeperTitle.
  ///
  /// In ru, this message translates to:
  /// **'Хозяин аптечки'**
  String get badgeCabinetKeeperTitle;

  /// No description provided for @badgeCabinetKeeperHint.
  ///
  /// In ru, this message translates to:
  /// **'3 лекарства в аптечке'**
  String get badgeCabinetKeeperHint;

  /// No description provided for @badgeNoExpiredTitle.
  ///
  /// In ru, this message translates to:
  /// **'Без просрочки'**
  String get badgeNoExpiredTitle;

  /// No description provided for @badgeNoExpiredHint.
  ///
  /// In ru, this message translates to:
  /// **'Аптечка без просроченных'**
  String get badgeNoExpiredHint;

  /// No description provided for @badgeMonthTitle.
  ///
  /// In ru, this message translates to:
  /// **'Месяц без пропусков'**
  String get badgeMonthTitle;

  /// No description provided for @badgeMonthHint.
  ///
  /// In ru, this message translates to:
  /// **'30 дней подряд'**
  String get badgeMonthHint;

  /// No description provided for @badgeBigCabinetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Большая аптечка'**
  String get badgeBigCabinetTitle;

  /// No description provided for @badgeBigCabinetHint.
  ///
  /// In ru, this message translates to:
  /// **'10 лекарств в аптечке'**
  String get badgeBigCabinetHint;

  /// No description provided for @badgeFiftyTitle.
  ///
  /// In ru, this message translates to:
  /// **'50 приёмов'**
  String get badgeFiftyTitle;

  /// No description provided for @badgeFiftyHint.
  ///
  /// In ru, this message translates to:
  /// **'50 отметок «принял» за 60 дней'**
  String get badgeFiftyHint;

  /// No description provided for @badgePerfectWeekTitle.
  ///
  /// In ru, this message translates to:
  /// **'Идеальная неделя'**
  String get badgePerfectWeekTitle;

  /// No description provided for @badgePerfectWeekHint.
  ///
  /// In ru, this message translates to:
  /// **'Все приёмы за 7 дней отмечены'**
  String get badgePerfectWeekHint;

  /// No description provided for @badgeDiaryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дневник начат'**
  String get badgeDiaryTitle;

  /// No description provided for @badgeDiaryHint.
  ///
  /// In ru, this message translates to:
  /// **'3 записи о самочувствии'**
  String get badgeDiaryHint;

  /// No description provided for @unitPcs.
  ///
  /// In ru, this message translates to:
  /// **'шт.'**
  String get unitPcs;

  /// No description provided for @unitMl.
  ///
  /// In ru, this message translates to:
  /// **'мл'**
  String get unitMl;

  /// No description provided for @unitG.
  ///
  /// In ru, this message translates to:
  /// **'г'**
  String get unitG;

  /// No description provided for @unitDoses.
  ///
  /// In ru, this message translates to:
  /// **'доз'**
  String get unitDoses;

  /// No description provided for @negativeStock.
  ///
  /// In ru, this message translates to:
  /// **'Остаток не может быть отрицательным'**
  String get negativeStock;

  /// No description provided for @disposalHint.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте инструкцию и местные правила утилизации'**
  String get disposalHint;

  /// No description provided for @stockLabel.
  ///
  /// In ru, this message translates to:
  /// **'Остаток'**
  String get stockLabel;

  /// No description provided for @expiredSince.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено с {date}'**
  String expiredSince(String date);

  /// No description provided for @expiringBadge.
  ///
  /// In ru, this message translates to:
  /// **'Скоро истекает: до {date} ({when})'**
  String expiringBadge(String date, String when);

  /// No description provided for @whenToday.
  ///
  /// In ru, this message translates to:
  /// **'сегодня'**
  String get whenToday;

  /// No description provided for @whenInDays.
  ///
  /// In ru, this message translates to:
  /// **'через {n} дн.'**
  String whenInDays(int n);

  /// No description provided for @outBadge.
  ///
  /// In ru, this message translates to:
  /// **'Закончилось'**
  String get outBadge;

  /// No description provided for @lowBadge.
  ///
  /// In ru, this message translates to:
  /// **'Мало: осталось {qty}'**
  String lowBadge(String qty);

  /// No description provided for @goodUntil.
  ///
  /// In ru, this message translates to:
  /// **'Годен до {date}'**
  String goodUntil(String date);

  /// No description provided for @searchMedicines.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по {count, plural, one{{count} лекарству} few{{count} лекарствам} many{{count} лекарствам} other{{count} лекарствам}}'**
  String searchMedicines(int count);

  /// No description provided for @backToCabinet.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться в аптечку'**
  String get backToCabinet;

  /// No description provided for @archive.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get archive;

  /// No description provided for @titleCabinet.
  ///
  /// In ru, this message translates to:
  /// **'Аптечка'**
  String get titleCabinet;

  /// No description provided for @addMedicine.
  ///
  /// In ru, this message translates to:
  /// **'Добавить лекарство'**
  String get addMedicine;

  /// No description provided for @cabinetLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить аптечку'**
  String get cabinetLoadFailed;

  /// No description provided for @archiveEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Архив пуст'**
  String get archiveEmptyTitle;

  /// No description provided for @archiveEmptyText.
  ///
  /// In ru, this message translates to:
  /// **'Сюда попадают лекарства, убранные из аптечки.'**
  String get archiveEmptyText;

  /// No description provided for @cabinetEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'В аптечке пока пусто'**
  String get cabinetEmptyTitle;

  /// No description provided for @cabinetEmptyText.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первое лекарство, чтобы следить за остатком и сроком годности.'**
  String get cabinetEmptyText;

  /// No description provided for @noMedicinesWithStatus.
  ///
  /// In ru, this message translates to:
  /// **'Нет лекарств с таким статусом'**
  String get noMedicinesWithStatus;

  /// No description provided for @showAll.
  ///
  /// In ru, this message translates to:
  /// **'Показать все'**
  String get showAll;

  /// No description provided for @readinessOverline.
  ///
  /// In ru, this message translates to:
  /// **'ГОТОВНОСТЬ АПТЕЧКИ'**
  String get readinessOverline;

  /// No description provided for @okPercent.
  ///
  /// In ru, this message translates to:
  /// **'В порядке: {percent}%'**
  String okPercent(int percent);

  /// No description provided for @tileTotal.
  ///
  /// In ru, this message translates to:
  /// **'Всего'**
  String get tileTotal;

  /// No description provided for @tileExpiring.
  ///
  /// In ru, this message translates to:
  /// **'Истекают'**
  String get tileExpiring;

  /// No description provided for @tileLow.
  ///
  /// In ru, this message translates to:
  /// **'Мало'**
  String get tileLow;

  /// No description provided for @timeToBuy.
  ///
  /// In ru, this message translates to:
  /// **'Пора докупить: {count} — загляните во вкладку «Покупки»'**
  String timeToBuy(int count);

  /// No description provided for @allCategories.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get allCategories;

  /// No description provided for @pQuantityNegative.
  ///
  /// In ru, this message translates to:
  /// **'Количество не может быть отрицательным'**
  String get pQuantityNegative;

  /// No description provided for @pMedicineArchived.
  ///
  /// In ru, this message translates to:
  /// **'Лекарство в архиве'**
  String get pMedicineArchived;

  /// No description provided for @pUnitMustBe.
  ///
  /// In ru, this message translates to:
  /// **'Единица должна быть «{unit}»'**
  String pUnitMustBe(String unit);

  /// No description provided for @pNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Название обязательно'**
  String get pNameRequired;

  /// No description provided for @pUnitRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите единицу учёта'**
  String get pUnitRequired;

  /// No description provided for @pThresholdNegative.
  ///
  /// In ru, this message translates to:
  /// **'Порог не может быть отрицательным'**
  String get pThresholdNegative;

  /// No description provided for @pDosePositive.
  ///
  /// In ru, this message translates to:
  /// **'Дозировка должна быть больше нуля'**
  String get pDosePositive;

  /// No description provided for @pDoseUnitRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите единицу дозировки'**
  String get pDoseUnitRequired;

  /// No description provided for @pPickWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'Выберите дни недели'**
  String get pPickWeekdays;

  /// No description provided for @pPickDates.
  ///
  /// In ru, this message translates to:
  /// **'Выберите даты'**
  String get pPickDates;

  /// No description provided for @pEndBeforeStart.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания раньше даты начала'**
  String get pEndBeforeStart;

  /// No description provided for @pBadTime.
  ///
  /// In ru, this message translates to:
  /// **'Некорректное время'**
  String get pBadTime;

  /// No description provided for @pAlreadyTaken.
  ///
  /// In ru, this message translates to:
  /// **'Приём уже отмечен как принятый'**
  String get pAlreadyTaken;

  /// No description provided for @pNoDeductions.
  ///
  /// In ru, this message translates to:
  /// **'Списания для этой отметки не сохранены'**
  String get pNoDeductions;

  /// No description provided for @newMedicine.
  ///
  /// In ru, this message translates to:
  /// **'Новое лекарство'**
  String get newMedicine;

  /// No description provided for @medicineTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лекарство'**
  String get medicineTitle;

  /// No description provided for @addToCabinet.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в аптечку'**
  String get addToCabinet;

  /// No description provided for @secBasic.
  ///
  /// In ru, this message translates to:
  /// **'Основное'**
  String get secBasic;

  /// No description provided for @nameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название *'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, Ибупрофен Форте'**
  String get nameHint;

  /// No description provided for @enterName.
  ///
  /// In ru, this message translates to:
  /// **'Введите название'**
  String get enterName;

  /// No description provided for @secCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория действия'**
  String get secCategory;

  /// No description provided for @secForm.
  ///
  /// In ru, this message translates to:
  /// **'Форма выпуска'**
  String get secForm;

  /// No description provided for @strengthLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дозировка или концентрация'**
  String get strengthLabel;

  /// No description provided for @strengthHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, 500 мг'**
  String get strengthHint;

  /// No description provided for @secStorage.
  ///
  /// In ru, this message translates to:
  /// **'Где хранить?'**
  String get secStorage;

  /// No description provided for @secStock.
  ///
  /// In ru, this message translates to:
  /// **'Запас'**
  String get secStock;

  /// No description provided for @initialQuantity.
  ///
  /// In ru, this message translates to:
  /// **'Начальное количество'**
  String get initialQuantity;

  /// No description provided for @enterNumberZero.
  ///
  /// In ru, this message translates to:
  /// **'Введите число 0 или больше'**
  String get enterNumberZero;

  /// No description provided for @unitLabel.
  ///
  /// In ru, this message translates to:
  /// **'Единица'**
  String get unitLabel;

  /// No description provided for @expiryLabel.
  ///
  /// In ru, this message translates to:
  /// **'Срок годности'**
  String get expiryLabel;

  /// No description provided for @clearExpiry.
  ///
  /// In ru, this message translates to:
  /// **'Убрать срок годности'**
  String get clearExpiry;

  /// No description provided for @thresholdLabel.
  ///
  /// In ru, this message translates to:
  /// **'Порог низкого остатка (необязательно)'**
  String get thresholdLabel;

  /// No description provided for @thresholdHelper.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию: 20% от самой большой упаковки'**
  String get thresholdHelper;

  /// No description provided for @secLook.
  ///
  /// In ru, this message translates to:
  /// **'Внешний вид'**
  String get secLook;

  /// No description provided for @drawPill.
  ///
  /// In ru, this message translates to:
  /// **'Как выглядит'**
  String get drawPill;

  /// No description provided for @pillShape.
  ///
  /// In ru, this message translates to:
  /// **'Форма'**
  String get pillShape;

  /// No description provided for @pillColor.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get pillColor;

  /// No description provided for @pillColor2.
  ///
  /// In ru, this message translates to:
  /// **'Цвет второй половины'**
  String get pillColor2;

  /// No description provided for @pillScore.
  ///
  /// In ru, this message translates to:
  /// **'Разрез'**
  String get pillScore;

  /// No description provided for @shapeRound.
  ///
  /// In ru, this message translates to:
  /// **'Круглая'**
  String get shapeRound;

  /// No description provided for @shapeOval.
  ///
  /// In ru, this message translates to:
  /// **'Овальная'**
  String get shapeOval;

  /// No description provided for @shapeCaplet.
  ///
  /// In ru, this message translates to:
  /// **'Продолговатая'**
  String get shapeCaplet;

  /// No description provided for @shapeCapsule.
  ///
  /// In ru, this message translates to:
  /// **'Капсула'**
  String get shapeCapsule;

  /// No description provided for @shapeSquare.
  ///
  /// In ru, this message translates to:
  /// **'Квадратная'**
  String get shapeSquare;

  /// No description provided for @scoreNone.
  ///
  /// In ru, this message translates to:
  /// **'Без разреза'**
  String get scoreNone;

  /// No description provided for @scoreLine.
  ///
  /// In ru, this message translates to:
  /// **'Одна линия'**
  String get scoreLine;

  /// No description provided for @scoreCross.
  ///
  /// In ru, this message translates to:
  /// **'Крест'**
  String get scoreCross;

  /// No description provided for @colorSwatch.
  ///
  /// In ru, this message translates to:
  /// **'Цвет {n}'**
  String colorSwatch(int n);

  /// No description provided for @edit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get edit;

  /// No description provided for @toArchive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get toArchive;

  /// No description provided for @restoreFromArchive.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть из архива'**
  String get restoreFromArchive;

  /// No description provided for @inArchiveBadge.
  ///
  /// In ru, this message translates to:
  /// **'В архиве'**
  String get inArchiveBadge;

  /// No description provided for @stockSemantics.
  ///
  /// In ru, this message translates to:
  /// **'Остаток: {quantity}'**
  String stockSemantics(String quantity);

  /// No description provided for @totalStock.
  ///
  /// In ru, this message translates to:
  /// **'Общий остаток'**
  String get totalStock;

  /// No description provided for @stockInPackage.
  ///
  /// In ru, this message translates to:
  /// **'Остаток в упаковке'**
  String get stockInPackage;

  /// No description provided for @secPackages.
  ///
  /// In ru, this message translates to:
  /// **'Упаковки'**
  String get secPackages;

  /// No description provided for @takeNow.
  ///
  /// In ru, this message translates to:
  /// **'Принять сейчас'**
  String get takeNow;

  /// No description provided for @addPackage.
  ///
  /// In ru, this message translates to:
  /// **'Добавить упаковку'**
  String get addPackage;

  /// No description provided for @addedToShopping.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в список покупок'**
  String get addedToShopping;

  /// No description provided for @toShoppingList.
  ///
  /// In ru, this message translates to:
  /// **'В список покупок'**
  String get toShoppingList;

  /// No description provided for @archiveAskTitle.
  ///
  /// In ru, this message translates to:
  /// **'Убрать в архив?'**
  String get archiveAskTitle;

  /// No description provided for @archiveAskText.
  ///
  /// In ru, this message translates to:
  /// **'Действующие расписания этого лекарства будут завершены, напоминания отключены. Прошлые приёмы и история остатков сохранятся.'**
  String get archiveAskText;

  /// No description provided for @medicineRestored.
  ///
  /// In ru, this message translates to:
  /// **'Лекарство возвращено. Завершённые расписания нужно создать заново'**
  String get medicineRestored;

  /// No description provided for @takenRecorded.
  ///
  /// In ru, this message translates to:
  /// **'Записано: {qty}'**
  String takenRecorded(String qty);

  /// No description provided for @expiryPassed.
  ///
  /// In ru, this message translates to:
  /// **'Срок годности истёк {date}'**
  String expiryPassed(String date);

  /// No description provided for @packageOut.
  ///
  /// In ru, this message translates to:
  /// **'Закончилась'**
  String get packageOut;

  /// No description provided for @expiringSoonShort.
  ///
  /// In ru, this message translates to:
  /// **'Скоро истекает'**
  String get expiringSoonShort;

  /// No description provided for @otherUnitNote.
  ///
  /// In ru, this message translates to:
  /// **'Другая единица: не входит в остаток и не расходуется приёмами'**
  String get otherUnitNote;

  /// No description provided for @packageTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Упаковка'**
  String get packageTooltip;

  /// No description provided for @correctStock.
  ///
  /// In ru, this message translates to:
  /// **'Скорректировать остаток'**
  String get correctStock;

  /// No description provided for @expiryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Срок годности'**
  String get expiryTitle;

  /// No description provided for @movementHistory.
  ///
  /// In ru, this message translates to:
  /// **'История движения'**
  String get movementHistory;

  /// No description provided for @staleQuantity.
  ///
  /// In ru, this message translates to:
  /// **'Остаток изменился. Откройте корректировку заново'**
  String get staleQuantity;

  /// No description provided for @noMovements.
  ///
  /// In ru, this message translates to:
  /// **'Движений нет'**
  String get noMovements;

  /// No description provided for @stockAfter.
  ///
  /// In ru, this message translates to:
  /// **'Остаток {qty} · {when}'**
  String stockAfter(String qty, String when);

  /// No description provided for @txInitial.
  ///
  /// In ru, this message translates to:
  /// **'Начальный остаток'**
  String get txInitial;

  /// No description provided for @txIncrease.
  ///
  /// In ru, this message translates to:
  /// **'Приход'**
  String get txIncrease;

  /// No description provided for @txDecrease.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get txDecrease;

  /// No description provided for @txCorrection.
  ///
  /// In ru, this message translates to:
  /// **'Коррекция'**
  String get txCorrection;

  /// No description provided for @newPackage.
  ///
  /// In ru, this message translates to:
  /// **'Новая упаковка'**
  String get newPackage;

  /// No description provided for @quantityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get quantityLabel;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @actualStock.
  ///
  /// In ru, this message translates to:
  /// **'Фактический остаток'**
  String get actualStock;

  /// No description provided for @leftOfTotal.
  ///
  /// In ru, this message translates to:
  /// **'Осталось {left} из {total}'**
  String leftOfTotal(int left, int total);

  /// No description provided for @howManyTaken.
  ///
  /// In ru, this message translates to:
  /// **'Сколько приняли'**
  String get howManyTaken;

  /// No description provided for @enterPositive.
  ///
  /// In ru, this message translates to:
  /// **'Введите число больше нуля'**
  String get enterPositive;

  /// No description provided for @record.
  ///
  /// In ru, this message translates to:
  /// **'Записать'**
  String get record;

  /// No description provided for @tip1.
  ///
  /// In ru, this message translates to:
  /// **'Не забудь выпить стакан воды: таблетки лучше усваиваются.'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In ru, this message translates to:
  /// **'Поставь аптечку на видное место: так проще не пропускать приём.'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In ru, this message translates to:
  /// **'Каждая отметка — маленькая победа. Серия растёт!'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In ru, this message translates to:
  /// **'Проверь сроки годности раз в месяц: я подскажу, что скоро истечёт.'**
  String get tip4;

  /// No description provided for @notEnoughStock.
  ///
  /// In ru, this message translates to:
  /// **'В аптечке не хватает лекарства'**
  String get notEnoughStock;

  /// No description provided for @addIntake.
  ///
  /// In ru, this message translates to:
  /// **'Добавить приём'**
  String get addIntake;

  /// No description provided for @historyTooltip.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get historyTooltip;

  /// No description provided for @wholeMonth.
  ///
  /// In ru, this message translates to:
  /// **'Весь месяц'**
  String get wholeMonth;

  /// No description provided for @loadIntakesFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить приёмы'**
  String get loadIntakesFailed;

  /// No description provided for @noIntakesTitle.
  ///
  /// In ru, this message translates to:
  /// **'На этот день приёмов нет'**
  String get noIntakesTitle;

  /// No description provided for @noIntakesText.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите «+», чтобы добавить приём'**
  String get noIntakesText;

  /// No description provided for @courseLastDay.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня последний день курса: {name}'**
  String courseLastDay(String name);

  /// No description provided for @courseEnds.
  ///
  /// In ru, this message translates to:
  /// **'Курс {name} заканчивается {date}'**
  String courseEnds(String name, String date);

  /// No description provided for @periodMorning.
  ///
  /// In ru, this message translates to:
  /// **'Утро'**
  String get periodMorning;

  /// No description provided for @periodDay.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get periodDay;

  /// No description provided for @periodEvening.
  ///
  /// In ru, this message translates to:
  /// **'Вечер'**
  String get periodEvening;

  /// No description provided for @periodAnytime.
  ///
  /// In ru, this message translates to:
  /// **'В течение дня'**
  String get periodAnytime;

  /// No description provided for @periodDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get periodDone;

  /// No description provided for @periodWaiting.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает'**
  String get periodWaiting;

  /// No description provided for @planOverline.
  ///
  /// In ru, this message translates to:
  /// **'ПЛАН ДНЯ'**
  String get planOverline;

  /// No description provided for @takenOfTotal.
  ///
  /// In ru, this message translates to:
  /// **'{done} из {total} принято'**
  String takenOfTotal(int done, int total);

  /// No description provided for @allTaken.
  ///
  /// In ru, this message translates to:
  /// **'Всё принято — отличный день!'**
  String get allTaken;

  /// No description provided for @leftToTake.
  ///
  /// In ru, this message translates to:
  /// **'Осталось принять: {left}'**
  String leftToTake(int left);

  /// No description provided for @whisper.
  ///
  /// In ru, this message translates to:
  /// **'Пилюлькин шепчет:'**
  String get whisper;

  /// No description provided for @manageSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Управление расписанием'**
  String get manageSchedule;

  /// No description provided for @editSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Изменить расписание'**
  String get editSchedule;

  /// No description provided for @endScheduleItem.
  ///
  /// In ru, this message translates to:
  /// **'Завершить расписание'**
  String get endScheduleItem;

  /// No description provided for @scheduleAlreadyChanged.
  ///
  /// In ru, this message translates to:
  /// **'Расписание уже изменено или завершено'**
  String get scheduleAlreadyChanged;

  /// No description provided for @cancelMark.
  ///
  /// In ru, this message translates to:
  /// **'Отменить отметку'**
  String get cancelMark;

  /// No description provided for @statusTaken.
  ///
  /// In ru, this message translates to:
  /// **'Принято'**
  String get statusTaken;

  /// No description provided for @statusSkipped.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено'**
  String get statusSkipped;

  /// No description provided for @statusUnmarked.
  ///
  /// In ru, this message translates to:
  /// **'Не отмечено'**
  String get statusUnmarked;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @take.
  ///
  /// In ru, this message translates to:
  /// **'Принять'**
  String get take;

  /// No description provided for @endAskTitle.
  ///
  /// In ru, this message translates to:
  /// **'Завершить расписание?'**
  String get endAskTitle;

  /// No description provided for @endAskText.
  ///
  /// In ru, this message translates to:
  /// **'Прошлые приёмы сохранятся, будущие исчезнут.'**
  String get endAskText;

  /// No description provided for @endConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Завершить'**
  String get endConfirm;

  /// No description provided for @endsTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Расписание завершится со следующего дня: сегодня уже есть отметка'**
  String get endsTomorrow;

  /// No description provided for @supplyCoversCourse.
  ///
  /// In ru, this message translates to:
  /// **'Хватит на весь курс'**
  String get supplyCoversCourse;

  /// No description provided for @supplyOverYear.
  ///
  /// In ru, this message translates to:
  /// **'Хватит больше чем на год'**
  String get supplyOverYear;

  /// No description provided for @supplyNotToday.
  ///
  /// In ru, this message translates to:
  /// **'Не хватит даже на сегодня'**
  String get supplyNotToday;

  /// No description provided for @supplyUntil.
  ///
  /// In ru, this message translates to:
  /// **'Хватит до {date}'**
  String supplyUntil(String date);

  /// No description provided for @createMedicineFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала создайте лекарство'**
  String get createMedicineFirst;

  /// No description provided for @chooseMedicine.
  ///
  /// In ru, this message translates to:
  /// **'Выберите лекарство'**
  String get chooseMedicine;

  /// No description provided for @changesFromTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Изменения вступят в силу с завтрашнего дня: сегодня уже есть отметка'**
  String get changesFromTomorrow;

  /// No description provided for @notificationsOffHint.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления выключены. Включите их в настройках, чтобы получать напоминания'**
  String get notificationsOffHint;

  /// No description provided for @timesPerDay.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{{n} раз в день} few{{n} раза в день} many{{n} раз в день} other{{n} раза в день}}'**
  String timesPerDay(int n);

  /// No description provided for @daysShort.
  ///
  /// In ru, this message translates to:
  /// **'{n} дн.'**
  String daysShort(int n);

  /// No description provided for @coursePreview.
  ///
  /// In ru, this message translates to:
  /// **'ПРЕДПРОСМОТР КУРСА'**
  String get coursePreview;

  /// No description provided for @newIntake.
  ///
  /// In ru, this message translates to:
  /// **'Новый приём'**
  String get newIntake;

  /// No description provided for @scheduleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get scheduleTitle;

  /// No description provided for @saveIntake.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить приём'**
  String get saveIntake;

  /// No description provided for @secMedicineDose.
  ///
  /// In ru, this message translates to:
  /// **'Лекарство и дозировка'**
  String get secMedicineDose;

  /// No description provided for @cabinetEmptyCreate.
  ///
  /// In ru, this message translates to:
  /// **'В аптечке пока нет лекарств. Создайте первое.'**
  String get cabinetEmptyCreate;

  /// No description provided for @doseLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дозировка за один приём'**
  String get doseLabel;

  /// No description provided for @secRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Повторение'**
  String get secRepeat;

  /// No description provided for @repeatDaily.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get repeatDaily;

  /// No description provided for @repeatWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'По дням'**
  String get repeatWeekdays;

  /// No description provided for @repeatDates.
  ///
  /// In ru, this message translates to:
  /// **'По датам'**
  String get repeatDates;

  /// No description provided for @secWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get secWeekdays;

  /// No description provided for @secDates.
  ///
  /// In ru, this message translates to:
  /// **'Даты'**
  String get secDates;

  /// No description provided for @addDate.
  ///
  /// In ru, this message translates to:
  /// **'Добавить дату'**
  String get addDate;

  /// No description provided for @intakeDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата приёма'**
  String get intakeDate;

  /// No description provided for @secTimes.
  ///
  /// In ru, this message translates to:
  /// **'Время приёма'**
  String get secTimes;

  /// No description provided for @addTimeOptional.
  ///
  /// In ru, this message translates to:
  /// **'Добавить время (необязательно)'**
  String get addTimeOptional;

  /// No description provided for @addTime.
  ///
  /// In ru, this message translates to:
  /// **'Добавить время'**
  String get addTime;

  /// No description provided for @secMeal.
  ///
  /// In ru, this message translates to:
  /// **'Связь с приёмом пищи'**
  String get secMeal;

  /// No description provided for @mealAny.
  ///
  /// In ru, this message translates to:
  /// **'Не важно'**
  String get mealAny;

  /// No description provided for @secPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Период'**
  String get secPeriod;

  /// No description provided for @startLabel.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get startLabel;

  /// No description provided for @startHelp.
  ///
  /// In ru, this message translates to:
  /// **'Дата начала'**
  String get startHelp;

  /// No description provided for @endOptional.
  ///
  /// In ru, this message translates to:
  /// **'Окончание (необязательно)'**
  String get endOptional;

  /// No description provided for @endHelp.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания'**
  String get endHelp;

  /// No description provided for @notSpecifiedN.
  ///
  /// In ru, this message translates to:
  /// **'Не указано'**
  String get notSpecifiedN;

  /// No description provided for @clear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clear;

  /// No description provided for @historyTitle.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get historyTitle;

  /// No description provided for @historyLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить историю'**
  String get historyLoadFailed;

  /// No description provided for @historyEmpty.
  ///
  /// In ru, this message translates to:
  /// **'История пуста'**
  String get historyEmpty;

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @historySummary.
  ///
  /// In ru, this message translates to:
  /// **'За {days} дн.: принято {taken}'**
  String historySummary(int days, int taken);

  /// No description provided for @historyMissed.
  ///
  /// In ru, this message translates to:
  /// **', пропущено {n}'**
  String historyMissed(int n);

  /// No description provided for @kitFever.
  ///
  /// In ru, this message translates to:
  /// **'Жаропонижающие и обезболивающие'**
  String get kitFever;

  /// No description provided for @kitFeverItems.
  ///
  /// In ru, this message translates to:
  /// **'Парацетамол|Ибупрофен'**
  String get kitFeverItems;

  /// No description provided for @kitAntiseptic.
  ///
  /// In ru, this message translates to:
  /// **'Антисептики для ран'**
  String get kitAntiseptic;

  /// No description provided for @kitAntisepticItems.
  ///
  /// In ru, this message translates to:
  /// **'Хлоргексидин|Мирамистин'**
  String get kitAntisepticItems;

  /// No description provided for @kitDressings.
  ///
  /// In ru, this message translates to:
  /// **'Перевязочные материалы'**
  String get kitDressings;

  /// No description provided for @kitDressingsItems.
  ///
  /// In ru, this message translates to:
  /// **'Пластырь|Бинт'**
  String get kitDressingsItems;

  /// No description provided for @kitStomach.
  ///
  /// In ru, this message translates to:
  /// **'Желудок и кишечник'**
  String get kitStomach;

  /// No description provided for @kitStomachItems.
  ///
  /// In ru, this message translates to:
  /// **'Активированный уголь|Смекта'**
  String get kitStomachItems;

  /// No description provided for @kitAllergy.
  ///
  /// In ru, this message translates to:
  /// **'Аллергия'**
  String get kitAllergy;

  /// No description provided for @kitAllergyItems.
  ///
  /// In ru, this message translates to:
  /// **'Супрастин|Цетиризин'**
  String get kitAllergyItems;

  /// No description provided for @reasonExpired.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get reasonExpired;

  /// No description provided for @reasonExpiringSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро срок'**
  String get reasonExpiringSoon;

  /// No description provided for @reasonOut.
  ///
  /// In ru, this message translates to:
  /// **'Закончилось'**
  String get reasonOut;

  /// No description provided for @reasonLow.
  ///
  /// In ru, this message translates to:
  /// **'Мало'**
  String get reasonLow;

  /// No description provided for @boughtAsk.
  ///
  /// In ru, this message translates to:
  /// **'Купили {name}?'**
  String boughtAsk(String name);

  /// No description provided for @toCabinet.
  ///
  /// In ru, this message translates to:
  /// **'В аптечку'**
  String get toCabinet;

  /// No description provided for @listCopied.
  ///
  /// In ru, this message translates to:
  /// **'Список скопирован'**
  String get listCopied;

  /// No description provided for @titleShopping.
  ///
  /// In ru, this message translates to:
  /// **'Покупки'**
  String get titleShopping;

  /// No description provided for @secUrgent.
  ///
  /// In ru, this message translates to:
  /// **'Срочно докупить'**
  String get secUrgent;

  /// No description provided for @allFine.
  ///
  /// In ru, this message translates to:
  /// **'Всё в порядке: ничего не заканчивается и не истекает.'**
  String get allFine;

  /// No description provided for @toList.
  ///
  /// In ru, this message translates to:
  /// **'В список'**
  String get toList;

  /// No description provided for @secMyList.
  ///
  /// In ru, this message translates to:
  /// **'Мой список'**
  String get secMyList;

  /// No description provided for @whatToBuy.
  ///
  /// In ru, this message translates to:
  /// **'Что купить?'**
  String get whatToBuy;

  /// No description provided for @addToList.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в список'**
  String get addToList;

  /// No description provided for @listEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Список пуст'**
  String get listEmpty;

  /// No description provided for @removeFromList.
  ///
  /// In ru, this message translates to:
  /// **'Убрать из списка'**
  String get removeFromList;

  /// No description provided for @copyList.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать список'**
  String get copyList;

  /// No description provided for @secIdealKit.
  ///
  /// In ru, this message translates to:
  /// **'Собери идеальную аптечку'**
  String get secIdealKit;

  /// No description provided for @inStock.
  ///
  /// In ru, this message translates to:
  /// **'В наличии'**
  String get inStock;

  /// No description provided for @inList.
  ///
  /// In ru, this message translates to:
  /// **'В списке'**
  String get inList;

  /// No description provided for @titleProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get titleProfile;

  /// No description provided for @yourName.
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get yourName;

  /// No description provided for @streakDaysInRow.
  ///
  /// In ru, this message translates to:
  /// **'{n} дн. подряд'**
  String streakDaysInRow(int n);

  /// No description provided for @editName.
  ///
  /// In ru, this message translates to:
  /// **'Изменить имя'**
  String get editName;

  /// No description provided for @secWeek.
  ///
  /// In ru, this message translates to:
  /// **'Итоги недели'**
  String get secWeek;

  /// No description provided for @secHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get secHealth;

  /// No description provided for @diaryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дневник самочувствия'**
  String get diaryTitle;

  /// No description provided for @diarySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Настроение, с чем была проблема'**
  String get diarySubtitle;

  /// No description provided for @reportTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт для врача'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'PDF или таблица за период'**
  String get reportSubtitle;

  /// No description provided for @weekSummary.
  ///
  /// In ru, this message translates to:
  /// **'За 7 дней принято {taken} из {planned} ({percent}%)'**
  String weekSummary(int taken, int planned, int percent);

  /// No description provided for @goalText.
  ///
  /// In ru, this message translates to:
  /// **'Цель: {goal} дней подряд, осталось {left}'**
  String goalText(int goal, int left);

  /// No description provided for @secBadges.
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get secBadges;

  /// No description provided for @secSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get secSettings;

  /// No description provided for @themeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @languageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get languageTitle;

  /// No description provided for @langSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get langSystem;

  /// No description provided for @hapticsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тактильный отклик'**
  String get hapticsTitle;

  /// No description provided for @hapticsSub.
  ///
  /// In ru, this message translates to:
  /// **'Приятная отдача при приёме'**
  String get hapticsSub;

  /// No description provided for @confettiTitle.
  ///
  /// In ru, this message translates to:
  /// **'Конфетти при приёме'**
  String get confettiTitle;

  /// No description provided for @confettiSub.
  ///
  /// In ru, this message translates to:
  /// **'Анимация победы над рутиной'**
  String get confettiSub;

  /// No description provided for @hintsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подсказки о сроках'**
  String get hintsTitle;

  /// No description provided for @hintsSub.
  ///
  /// In ru, this message translates to:
  /// **'Напоминать в аптечке, что пора докупить'**
  String get hintsSub;

  /// No description provided for @notificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationsTitle;

  /// No description provided for @notificationsSub.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения, проверка, если не приходят'**
  String get notificationsSub;

  /// No description provided for @secData.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get secData;

  /// No description provided for @dataNote.
  ///
  /// In ru, this message translates to:
  /// **'Данные хранятся на этом устройстве. Если войти в аккаунт, их копия есть и в облаке. Файл резервной копии вы сохраняете сами, он не зашифрован: храните его там, где доверяете.'**
  String get dataNote;

  /// No description provided for @saveBackup.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить резервную копию'**
  String get saveBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить из копии'**
  String get restoreBackup;

  /// No description provided for @whatsYourName.
  ///
  /// In ru, this message translates to:
  /// **'Как вас зовут?'**
  String get whatsYourName;

  /// No description provided for @weekdayDone.
  ///
  /// In ru, this message translates to:
  /// **'без пропусков'**
  String get weekdayDone;

  /// No description provided for @weekdayMissed.
  ///
  /// In ru, this message translates to:
  /// **'есть пропуски'**
  String get weekdayMissed;

  /// No description provided for @weekdayNoData.
  ///
  /// In ru, this message translates to:
  /// **'нет данных'**
  String get weekdayNoData;

  /// No description provided for @badgeEarned.
  ///
  /// In ru, this message translates to:
  /// **'получено'**
  String get badgeEarned;

  /// No description provided for @badgeLocked.
  ///
  /// In ru, this message translates to:
  /// **'не получено'**
  String get badgeLocked;

  /// No description provided for @backupFailedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось'**
  String get backupFailedTitle;

  /// No description provided for @somethingWrong.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Данные не изменены.'**
  String get somethingWrong;

  /// No description provided for @backupTooLarge.
  ///
  /// In ru, this message translates to:
  /// **'Файл слишком большой для резервной копии PillPal'**
  String get backupTooLarge;

  /// No description provided for @backupNotBackup.
  ///
  /// In ru, this message translates to:
  /// **'Это не резервная копия PillPal'**
  String get backupNotBackup;

  /// No description provided for @backupNewer.
  ///
  /// In ru, this message translates to:
  /// **'Копия создана более новой версией PillPal или зашифрована. Обновите приложение'**
  String get backupNewer;

  /// No description provided for @backupCorrupt.
  ///
  /// In ru, this message translates to:
  /// **'Файл повреждён или не является резервной копией'**
  String get backupCorrupt;

  /// No description provided for @backupInconsistent.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия противоречива и не может быть восстановлена'**
  String get backupInconsistent;

  /// No description provided for @backupSaved.
  ///
  /// In ru, this message translates to:
  /// **'Копия сохранена'**
  String get backupSaved;

  /// No description provided for @backupDescribe.
  ///
  /// In ru, this message translates to:
  /// **'{medicines} лекарств{archived}, {schedules} расписаний, {logs} отметок{last}'**
  String backupDescribe(
    int medicines,
    String archived,
    int schedules,
    int logs,
    String last,
  );

  /// No description provided for @backupArchivedPart.
  ///
  /// In ru, this message translates to:
  /// **' (в архиве: {n})'**
  String backupArchivedPart(int n);

  /// No description provided for @backupLastPart.
  ///
  /// In ru, this message translates to:
  /// **', последняя {date}'**
  String backupLastPart(String date);

  /// No description provided for @replaceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заменить данные?'**
  String get replaceTitle;

  /// No description provided for @replaceText.
  ///
  /// In ru, this message translates to:
  /// **'В копии: {backup}.\n\nСейчас на устройстве: {current}.\n\nВсе текущие данные будут заменены полностью. Это нельзя отменить.'**
  String replaceText(String backup, String current);

  /// No description provided for @saveCurrentFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сначала сохранить текущие'**
  String get saveCurrentFirst;

  /// No description provided for @replace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get replace;

  /// No description provided for @dataRestored.
  ///
  /// In ru, this message translates to:
  /// **'Данные восстановлены'**
  String get dataRestored;

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @notificationsOn.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания включены'**
  String get notificationsOn;

  /// No description provided for @notificationsOff.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания выключены'**
  String get notificationsOff;

  /// No description provided for @notifDeniedText.
  ///
  /// In ru, this message translates to:
  /// **'Без разрешения приложение не сможет напомнить о приёме. Если окно с запросом не появляется, включите уведомления для PillPal в настройках телефона.'**
  String get notifDeniedText;

  /// No description provided for @notifOnText.
  ///
  /// In ru, this message translates to:
  /// **'Если приём не отмечен, через 15 минут придёт второе напоминание. В уведомлении есть кнопки «Принял», «Через 10 мин» и «Через 30 мин».'**
  String get notifOnText;

  /// No description provided for @allowNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить уведомления'**
  String get allowNotifications;

  /// No description provided for @exactAlarms.
  ///
  /// In ru, this message translates to:
  /// **'Напоминать точно по времени'**
  String get exactAlarms;

  /// No description provided for @exactAlarmsSub.
  ///
  /// In ru, this message translates to:
  /// **'Без этого Android может задержать уведомление'**
  String get exactAlarmsSub;

  /// No description provided for @testNotification.
  ///
  /// In ru, this message translates to:
  /// **'Проверить уведомление'**
  String get testNotification;

  /// No description provided for @soundTitle.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get soundTitle;

  /// No description provided for @soundSub.
  ///
  /// In ru, this message translates to:
  /// **'Сигнал при напоминании'**
  String get soundSub;

  /// No description provided for @vibrationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вибрация'**
  String get vibrationTitle;

  /// No description provided for @vibrationIos.
  ///
  /// In ru, this message translates to:
  /// **'На iPhone вибрацией управляет система'**
  String get vibrationIos;

  /// No description provided for @vibrationSub.
  ///
  /// In ru, this message translates to:
  /// **'Вибрировать при напоминании'**
  String get vibrationSub;

  /// No description provided for @quietTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тихие часы'**
  String get quietTitle;

  /// No description provided for @quietSub.
  ///
  /// In ru, this message translates to:
  /// **'В это время напоминания приходят без звука'**
  String get quietSub;

  /// No description provided for @quietFromLabel.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get quietFromLabel;

  /// No description provided for @quietToLabel.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get quietToLabel;

  /// No description provided for @quietFromTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тихие часы с'**
  String get quietFromTitle;

  /// No description provided for @quietToTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тихие часы до'**
  String get quietToTitle;

  /// No description provided for @batteryNote.
  ///
  /// In ru, this message translates to:
  /// **'Не приходят? На некоторых телефонах экономия заряда останавливает напоминания: в настройках телефона разрешите PillPal работать без ограничений.'**
  String get batteryNote;

  /// No description provided for @moodBad.
  ///
  /// In ru, this message translates to:
  /// **'Плохо'**
  String get moodBad;

  /// No description provided for @moodSoSo.
  ///
  /// In ru, this message translates to:
  /// **'Так себе'**
  String get moodSoSo;

  /// No description provided for @moodOk.
  ///
  /// In ru, this message translates to:
  /// **'Нормально'**
  String get moodOk;

  /// No description provided for @moodGood.
  ///
  /// In ru, this message translates to:
  /// **'Хорошо'**
  String get moodGood;

  /// No description provided for @moodGreat.
  ///
  /// In ru, this message translates to:
  /// **'Отлично'**
  String get moodGreat;

  /// No description provided for @diaryEntry.
  ///
  /// In ru, this message translates to:
  /// **'Запись'**
  String get diaryEntry;

  /// No description provided for @diaryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Отмечайте самочувствие и с чем была проблема: записи попадут в отчёт для врача'**
  String get diaryEmpty;

  /// No description provided for @deleteEntry.
  ///
  /// In ru, this message translates to:
  /// **'Удалить запись'**
  String get deleteEntry;

  /// No description provided for @newEntry.
  ///
  /// In ru, this message translates to:
  /// **'Новая запись'**
  String get newEntry;

  /// No description provided for @howDoYouFeel.
  ///
  /// In ru, this message translates to:
  /// **'Самочувствие'**
  String get howDoYouFeel;

  /// No description provided for @noteLabel.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get noteLabel;

  /// No description provided for @reportSaved.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт сохранён'**
  String get reportSaved;

  /// No description provided for @days7.
  ///
  /// In ru, this message translates to:
  /// **'7 дней'**
  String get days7;

  /// No description provided for @days30.
  ///
  /// In ru, this message translates to:
  /// **'30 дней'**
  String get days30;

  /// No description provided for @days90.
  ///
  /// In ru, this message translates to:
  /// **'90 дней'**
  String get days90;

  /// No description provided for @noIntakesInPeriod.
  ///
  /// In ru, this message translates to:
  /// **'За этот период приёмов не было'**
  String get noIntakesInPeriod;

  /// No description provided for @medicineTakenOf.
  ///
  /// In ru, this message translates to:
  /// **'{name}: принято {taken} из {planned}'**
  String medicineTakenOf(String name, int taken, int planned);

  /// No description provided for @notMarkedPart.
  ///
  /// In ru, this message translates to:
  /// **', не отмечено {n}'**
  String notMarkedPart(int n);

  /// No description provided for @diaryCount.
  ///
  /// In ru, this message translates to:
  /// **'Записей в дневнике: {n}'**
  String diaryCount(int n);

  /// No description provided for @savePdf.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить PDF'**
  String get savePdf;

  /// No description provided for @saveCsv.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить таблицу (CSV)'**
  String get saveCsv;

  /// No description provided for @welcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Я PillPal'**
  String get welcomeTitle;

  /// No description provided for @welcomeText.
  ///
  /// In ru, this message translates to:
  /// **'Помогу не забывать про лекарства и следить за аптечкой.'**
  String get welcomeText;

  /// No description provided for @welcomeP1.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания о приёме'**
  String get welcomeP1;

  /// No description provided for @welcomeP1t.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление в нужное время и кнопка «Принял».'**
  String get welcomeP1t;

  /// No description provided for @welcomeP2.
  ///
  /// In ru, this message translates to:
  /// **'Аптечка под контролем'**
  String get welcomeP2;

  /// No description provided for @welcomeP2t.
  ///
  /// In ru, this message translates to:
  /// **'Остатки, сроки годности и подсказка, что пора докупить.'**
  String get welcomeP2t;

  /// No description provided for @welcomeP3.
  ///
  /// In ru, this message translates to:
  /// **'Всё хранится у вас'**
  String get welcomeP3;

  /// No description provided for @welcomeP3t.
  ///
  /// In ru, this message translates to:
  /// **'Данные остаются на этом устройстве. Облако — только если вы войдёте в аккаунт.'**
  String get welcomeP3t;

  /// No description provided for @nameOptional.
  ///
  /// In ru, this message translates to:
  /// **'Как вас зовут? (необязательно)'**
  String get nameOptional;

  /// No description provided for @enableReminders.
  ///
  /// In ru, this message translates to:
  /// **'Включить напоминания'**
  String get enableReminders;

  /// No description provided for @skipReminders.
  ///
  /// In ru, this message translates to:
  /// **'Пока без напоминаний'**
  String get skipReminders;

  /// No description provided for @followUpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не забыли? {name}'**
  String followUpTitle(String name);

  /// No description provided for @actionTaken.
  ///
  /// In ru, this message translates to:
  /// **'Принял'**
  String get actionTaken;

  /// No description provided for @actionSnooze.
  ///
  /// In ru, this message translates to:
  /// **'Через 10 мин'**
  String get actionSnooze;

  /// No description provided for @channelName.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания о приёме'**
  String get channelName;

  /// No description provided for @channelDescription.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания о запланированных приёмах'**
  String get channelDescription;

  /// No description provided for @testNotificationBody.
  ///
  /// In ru, this message translates to:
  /// **'Так будут выглядеть напоминания'**
  String get testNotificationBody;

  /// No description provided for @csvTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт PillPal'**
  String get csvTitle;

  /// No description provided for @csvMedicine.
  ///
  /// In ru, this message translates to:
  /// **'Лекарство'**
  String get csvMedicine;

  /// No description provided for @csvPlanned.
  ///
  /// In ru, this message translates to:
  /// **'Запланировано'**
  String get csvPlanned;

  /// No description provided for @csvTaken.
  ///
  /// In ru, this message translates to:
  /// **'Принято'**
  String get csvTaken;

  /// No description provided for @csvSkipped.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено'**
  String get csvSkipped;

  /// No description provided for @csvMissed.
  ///
  /// In ru, this message translates to:
  /// **'Не отмечено'**
  String get csvMissed;

  /// No description provided for @csvDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get csvDate;

  /// No description provided for @csvTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get csvTime;

  /// No description provided for @csvMood.
  ///
  /// In ru, this message translates to:
  /// **'Самочувствие (1-5)'**
  String get csvMood;

  /// No description provided for @csvNote.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get csvNote;

  /// No description provided for @pdfTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт о приёме лекарств'**
  String get pdfTitle;

  /// No description provided for @pdfMedicines.
  ///
  /// In ru, this message translates to:
  /// **'Лекарства'**
  String get pdfMedicines;

  /// No description provided for @pdfNoIntakes.
  ///
  /// In ru, this message translates to:
  /// **'За этот период приёмов не было.'**
  String get pdfNoIntakes;

  /// No description provided for @pdfPlanned.
  ///
  /// In ru, this message translates to:
  /// **'По плану'**
  String get pdfPlanned;

  /// No description provided for @pdfNoEntries.
  ///
  /// In ru, this message translates to:
  /// **'Записей нет.'**
  String get pdfNoEntries;

  /// No description provided for @pdfWhen.
  ///
  /// In ru, this message translates to:
  /// **'Когда'**
  String get pdfWhen;

  /// No description provided for @pdfValues.
  ///
  /// In ru, this message translates to:
  /// **'Показатели'**
  String get pdfValues;

  /// No description provided for @pdfFooter.
  ///
  /// In ru, this message translates to:
  /// **'Сформировано в PillPal {stamp}. Справочные данные, не медицинский документ.'**
  String pdfFooter(String stamp);

  /// No description provided for @moodText.
  ///
  /// In ru, this message translates to:
  /// **'самочувствие {n}/5'**
  String moodText(int n);

  /// No description provided for @validatorFillOne.
  ///
  /// In ru, this message translates to:
  /// **'Заполните хотя бы одно поле'**
  String get validatorFillOne;

  /// No description provided for @accountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт и облако'**
  String get accountTitle;

  /// No description provided for @accountSubSignedOut.
  ///
  /// In ru, this message translates to:
  /// **'Не выполнен вход'**
  String get accountSubSignedOut;

  /// No description provided for @accountNotAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Облако пока не подключено к этой сборке приложения. Данные хранятся на этом устройстве.'**
  String get accountNotAvailable;

  /// No description provided for @accountIntro.
  ///
  /// In ru, this message translates to:
  /// **'Войдите, чтобы хранить копию данных (лекарства, расписания, дневник) в облачном аккаунте и открывать её на других телефонах.'**
  String get accountIntro;

  /// No description provided for @emailLabel.
  ///
  /// In ru, this message translates to:
  /// **'Электронная почта'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get passwordLabel;

  /// No description provided for @signIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPassword;

  /// No description provided for @resetSent.
  ///
  /// In ru, this message translates to:
  /// **'Письмо для сброса пароля отправлено'**
  String get resetSent;

  /// No description provided for @enterEmail.
  ///
  /// In ru, this message translates to:
  /// **'Введите почту'**
  String get enterEmail;

  /// No description provided for @enterEmailPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите почту и пароль'**
  String get enterEmailPassword;

  /// No description provided for @signedInAs.
  ///
  /// In ru, this message translates to:
  /// **'Вы вошли как {email}'**
  String signedInAs(String email);

  /// No description provided for @syncedAt.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировано {when}'**
  String syncedAt(String when);

  /// No description provided for @syncing.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация…'**
  String get syncing;

  /// No description provided for @syncedJustNow.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировано'**
  String get syncedJustNow;

  /// No description provided for @syncNow.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировать сейчас'**
  String get syncNow;

  /// No description provided for @signOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get signOut;

  /// No description provided for @signOutNote.
  ///
  /// In ru, this message translates to:
  /// **'Данные останутся на этом телефоне, но перестанут отправляться в облако.'**
  String get signOutNote;

  /// No description provided for @deleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountText.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт и копия данных в облаке будут удалены. Данные на этом телефоне останутся. Введите пароль, чтобы подтвердить.'**
  String get deleteAccountText;

  /// No description provided for @accountDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт удалён'**
  String get accountDeleted;

  /// No description provided for @conflictTitle.
  ///
  /// In ru, this message translates to:
  /// **'Данные есть и здесь, и в облаке'**
  String get conflictTitle;

  /// No description provided for @conflictText.
  ///
  /// In ru, this message translates to:
  /// **'Выберите, какие оставить. Вторые будут заменены полностью.'**
  String get conflictText;

  /// No description provided for @useCloudData.
  ///
  /// In ru, this message translates to:
  /// **'Взять данные из облака'**
  String get useCloudData;

  /// No description provided for @useDeviceData.
  ///
  /// In ru, this message translates to:
  /// **'Оставить данные с этого телефона'**
  String get useDeviceData;

  /// No description provided for @authInvalidEmail.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте адрес почты'**
  String get authInvalidEmail;

  /// No description provided for @authWrongCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверная почта или пароль'**
  String get authWrongCredentials;

  /// No description provided for @authEmailInUse.
  ///
  /// In ru, this message translates to:
  /// **'Эта почта уже зарегистрирована'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль слишком простой: нужно хотя бы 6 символов'**
  String get authWeakPassword;

  /// No description provided for @authNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером. Проверьте интернет'**
  String get authNetwork;

  /// No description provided for @authTooMany.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Попробуйте позже'**
  String get authTooMany;

  /// No description provided for @authOther.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось. Попробуйте ещё раз'**
  String get authOther;

  /// No description provided for @syncProblemNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось связаться с облаком. Попробуем снова позже.'**
  String get syncProblemNetwork;

  /// No description provided for @syncProblemTooLarge.
  ///
  /// In ru, this message translates to:
  /// **'Данных слишком много для облачной копии.'**
  String get syncProblemTooLarge;

  /// No description provided for @syncProblemOther.
  ///
  /// In ru, this message translates to:
  /// **'Облачная копия не подошла. Данные на телефоне не изменены.'**
  String get syncProblemOther;

  /// No description provided for @extendCourse.
  ///
  /// In ru, this message translates to:
  /// **'Продлить'**
  String get extendCourse;

  /// No description provided for @extendCourseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Продлить курс: {name}'**
  String extendCourseTitle(String name);

  /// No description provided for @extendDays.
  ///
  /// In ru, this message translates to:
  /// **'Ещё {n} дн.'**
  String extendDays(int n);

  /// No description provided for @actionSnooze30.
  ///
  /// In ru, this message translates to:
  /// **'Через 30 мин'**
  String get actionSnooze30;

  /// No description provided for @secRepeatYearly.
  ///
  /// In ru, this message translates to:
  /// **'Повторять курс каждый год'**
  String get secRepeatYearly;

  /// No description provided for @repeatYearlyHint.
  ///
  /// In ru, this message translates to:
  /// **'Для сезонных курсов, например витамина D осенью и зимой'**
  String get repeatYearlyHint;

  /// No description provided for @repeatNone.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get repeatNone;

  /// No description provided for @repeatYears.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{ещё {n} год} few{ещё {n} года} many{ещё {n} лет} other{ещё {n} года}}'**
  String repeatYears(int n);

  /// No description provided for @symptomHeadache.
  ///
  /// In ru, this message translates to:
  /// **'Головная боль'**
  String get symptomHeadache;

  /// No description provided for @symptomNausea.
  ///
  /// In ru, this message translates to:
  /// **'Тошнота'**
  String get symptomNausea;

  /// No description provided for @symptomDizziness.
  ///
  /// In ru, this message translates to:
  /// **'Головокружение'**
  String get symptomDizziness;

  /// No description provided for @symptomWeakness.
  ///
  /// In ru, this message translates to:
  /// **'Слабость'**
  String get symptomWeakness;

  /// No description provided for @symptomFever.
  ///
  /// In ru, this message translates to:
  /// **'Температура'**
  String get symptomFever;

  /// No description provided for @symptomStomachache.
  ///
  /// In ru, this message translates to:
  /// **'Боль в животе'**
  String get symptomStomachache;

  /// No description provided for @symptomHeartburn.
  ///
  /// In ru, this message translates to:
  /// **'Изжога'**
  String get symptomHeartburn;

  /// No description provided for @symptomCough.
  ///
  /// In ru, this message translates to:
  /// **'Кашель'**
  String get symptomCough;

  /// No description provided for @symptomInsomnia.
  ///
  /// In ru, this message translates to:
  /// **'Плохой сон'**
  String get symptomInsomnia;

  /// No description provided for @symptomRash.
  ///
  /// In ru, this message translates to:
  /// **'Сыпь'**
  String get symptomRash;

  /// No description provided for @symptomAnxiety.
  ///
  /// In ru, this message translates to:
  /// **'Тревога'**
  String get symptomAnxiety;

  /// No description provided for @symptomPain.
  ///
  /// In ru, this message translates to:
  /// **'Боль'**
  String get symptomPain;

  /// No description provided for @symptomsTitle.
  ///
  /// In ru, this message translates to:
  /// **'С чем была проблема'**
  String get symptomsTitle;

  /// No description provided for @symptomOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get symptomOther;

  /// No description provided for @symptomOwnTitle.
  ///
  /// In ru, this message translates to:
  /// **'Своё'**
  String get symptomOwnTitle;

  /// No description provided for @symptomOwnLabel.
  ///
  /// In ru, this message translates to:
  /// **'Что беспокоило'**
  String get symptomOwnLabel;

  /// No description provided for @csvSymptoms.
  ///
  /// In ru, this message translates to:
  /// **'Проблема'**
  String get csvSymptoms;

  /// No description provided for @validatorMaxSymptoms.
  ///
  /// In ru, this message translates to:
  /// **'Не больше 12 пунктов в записи'**
  String get validatorMaxSymptoms;

  /// No description provided for @achievementsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get achievementsTitle;

  /// No description provided for @badgesCount.
  ///
  /// In ru, this message translates to:
  /// **'Получено {n} из {total}'**
  String badgesCount(int n, int total);

  /// No description provided for @settingsSub.
  ///
  /// In ru, this message translates to:
  /// **'Вид, язык, уведомления, копия данных'**
  String get settingsSub;

  /// No description provided for @takeOutsideSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Принять вне расписания'**
  String get takeOutsideSchedule;

  /// No description provided for @nothingToTake.
  ///
  /// In ru, this message translates to:
  /// **'В аптечке нет лекарств с остатком'**
  String get nothingToTake;

  /// No description provided for @deleteForever.
  ///
  /// In ru, this message translates to:
  /// **'Удалить навсегда'**
  String get deleteForever;

  /// No description provided for @deleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deleteConfirm;

  /// No description provided for @deleteMedicineAskTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить лекарство?'**
  String get deleteMedicineAskTitle;

  /// No description provided for @deleteMedicineAskText.
  ///
  /// In ru, this message translates to:
  /// **'«{name}» исчезнет вместе с упаковками, расписаниями и историей приёмов. Это нельзя отменить. Если лекарство просто больше не нужно, уберите его в архив.'**
  String deleteMedicineAskText(String name);

  /// No description provided for @deletePackage.
  ///
  /// In ru, this message translates to:
  /// **'Удалить упаковку'**
  String get deletePackage;

  /// No description provided for @deletePackageAskTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить упаковку?'**
  String get deletePackageAskTitle;

  /// No description provided for @deletePackageAskText.
  ///
  /// In ru, this message translates to:
  /// **'Упаковка и её история исчезнут, остаток лекарства уменьшится на {qty}.'**
  String deletePackageAskText(String qty);

  /// No description provided for @pLastPackage.
  ///
  /// In ru, this message translates to:
  /// **'Единственную упаковку удалить нельзя: удалите лекарство'**
  String get pLastPackage;

  /// No description provided for @deleteScheduleItem.
  ///
  /// In ru, this message translates to:
  /// **'Удалить расписание'**
  String get deleteScheduleItem;

  /// No description provided for @deleteScheduleAskTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить расписание?'**
  String get deleteScheduleAskTitle;

  /// No description provided for @deleteScheduleAskText.
  ///
  /// In ru, this message translates to:
  /// **'Расписание и все его отметки исчезнут, принятые таблетки вернутся в аптечку. Если лекарство просто больше не принимаете, лучше завершите расписание.'**
  String get deleteScheduleAskText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
