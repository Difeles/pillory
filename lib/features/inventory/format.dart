import 'package:flutter/widgets.dart';

import '../../domain/supply.dart';
import '../../l10n/l10n.dart';
import '../today/today_screen.dart' show formatDay;

/// The decimal mark of the current language; set by the app when the
/// language changes.
String decimalMark = ',';

/// 2 -> "2", 2.5 -> "2,5": whole numbers without a trailing ".0".
String formatQuantity(double q) {
  final s = q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toString();
  return s.replaceAll('.', decimalMark);
}

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// "Хватит до 12 ноября" and its variants, for [today].
String supplyText(BuildContext context, SupplyForecast f, DateTime today) {
  final l = context.l10n;
  if (f.coversPlan) return l.supplyCoversCourse;
  if (f.beyondHorizon) return l.supplyOverYear;
  if (f.days == 0) return l.supplyNotToday;
  final last = DateTime(today.year, today.month, today.day + f.days - 1);
  return l.supplyUntil(formatDay(context, last));
}

/// Accepts "2,5" and "2.5"; null if it is not a number.
double? parseQuantity(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));
