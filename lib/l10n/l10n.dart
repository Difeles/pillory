import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get _lang => Localizations.localeOf(this).languageCode;

  /// "20 октября" / "October 20".
  String dayMonth(DateTime d) => DateFormat.MMMMd(_lang).format(d);

  /// "Октябрь 2026" / "October 2026", the month as a heading.
  String monthYear(DateTime d) => '${monthName(d)} ${d.year}';

  /// "Октябрь" / "October", the month as a heading.
  String monthName(DateTime d) {
    final s = DateFormat.LLLL(_lang).format(d);
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }
}

/// The app's own strings and the framework's (date picker, back button).
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// The languages the app speaks.
const supportedAppLocales = [Locale('ru'), Locale('en')];

/// The locale for a saved choice ('ru', 'en' or null / 'system' for the
/// device's): Russian or English, and English for any other device language.
Locale resolveAppLocale(String? choice, Locale device) {
  for (final l in supportedAppLocales) {
    if (l.languageCode == choice) return l;
  }
  return device.languageCode == 'ru' ? const Locale('ru') : const Locale('en');
}

extension WeekdayNames on AppLocalizations {
  /// "Mon".."Sun" for [weekday] ([DateTime.monday]..[DateTime.sunday]).
  String weekdayShort(int weekday) => switch (weekday) {
    DateTime.monday => monShort,
    DateTime.tuesday => tueShort,
    DateTime.wednesday => wedShort,
    DateTime.thursday => thuShort,
    DateTime.friday => friShort,
    DateTime.saturday => satShort,
    _ => sunShort,
  };
}

/// The strings for code that has no [BuildContext] (notifications, reports):
/// the saved language choice, else the device's.
AppLocalizations appL10n([String? choice]) => lookupAppLocalizations(
  resolveAppLocale(choice, PlatformDispatcher.instance.locale),
);
