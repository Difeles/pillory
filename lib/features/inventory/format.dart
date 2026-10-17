/// 2 -> "2", 2.5 -> "2,5": whole numbers without a trailing ".0".
String formatQuantity(double q) {
  final s = q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toString();
  return s.replaceAll('.', ',');
}

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Accepts "2,5" and "2.5"; null if it is not a number.
double? parseQuantity(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));
