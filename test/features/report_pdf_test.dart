import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/l10n/app_localizations.dart';
import 'package:pillory/domain/report.dart';
import 'package:pillory/features/profile/report_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the report becomes a PDF with the Cyrillic font embedded', () async {
    final r = ReportData(
      name: 'Аня',
      from: DateTime(2026, 10),
      to: DateTime(2026, 10, 20),
      medicines: const [
        MedicineSummary(name: 'Аспирин', taken: 5, skipped: 1, missed: 2),
      ],
      diary: const [],
    );
    final bytes = await reportPdf(
      r,
      DateTime(2026, 10, 20, 9),
      lookupAppLocalizations(const Locale('ru')),
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(5000));
  });
}
