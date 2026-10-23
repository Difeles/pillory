import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/report.dart';
import '../../l10n/app_localizations.dart';

/// The report as a PDF. Onest is embedded: the PDF base fonts have no Cyrillic.
Future<Uint8List> reportPdf(
  ReportData r,
  DateTime generatedAt,
  AppLocalizations l,
) async {
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/onest/Onest-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/onest/Onest-Bold.ttf'),
  );
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      footer: (_) => pw.Text(
        l.pdfFooter(reportStamp(generatedAt)),
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
      ),
      build: (_) => [
        pw.Text(l.pdfTitle, style: pw.TextStyle(font: bold, fontSize: 20)),
        pw.SizedBox(height: 4),
        pw.Text([if (r.name.isNotEmpty) r.name, reportPeriod(r)].join(' · ')),
        pw.SizedBox(height: 16),
        pw.Text(l.pdfMedicines, style: pw.TextStyle(font: bold, fontSize: 14)),
        pw.SizedBox(height: 6),
        if (r.medicines.isEmpty)
          pw.Text(l.pdfNoIntakes)
        else
          pw.TableHelper.fromTextArray(
            headers: [
              l.csvMedicine,
              l.pdfPlanned,
              l.csvTaken,
              l.csvSkipped,
              l.csvMissed,
            ],
            data: [
              for (final m in r.medicines)
                [m.name, m.planned, m.taken, m.skipped, m.missed],
            ],
            headerStyle: pw.TextStyle(font: bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignments: {
              for (var i = 1; i < 5; i++) i: pw.Alignment.centerRight,
            },
          ),
        pw.SizedBox(height: 16),
        pw.Text(l.diaryTitle, style: pw.TextStyle(font: bold, fontSize: 14)),
        pw.SizedBox(height: 6),
        if (r.diary.isEmpty)
          pw.Text(l.pdfNoEntries)
        else
          pw.TableHelper.fromTextArray(
            headers: [l.pdfWhen, l.pdfValues],
            data: [
              for (final e in r.diary) [reportStamp(e.at), diaryLine(l, e)],
            ],
            headerStyle: pw.TextStyle(font: bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 10),
            columnWidths: {
              0: const pw.FixedColumnWidth(95),
              1: const pw.FlexColumnWidth(),
            },
          ),
      ],
    ),
  );
  return doc.save();
}
