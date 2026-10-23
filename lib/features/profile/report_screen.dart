import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/motion.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/pill_widgets.dart';
import '../../domain/inventory_rules.dart';
import '../../l10n/l10n.dart';

import '../../domain/report.dart';
import 'backup_files.dart';
import 'report_pdf.dart';

/// A report for the doctor: what was taken and skipped, and the diary.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int _days = 30;
  ReportData? _report;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<ReportData> _build() async {
    final today = dateOnly(DateTime.now());
    final from = DateTime(today.year, today.month, today.day - _days + 1);
    final history = await ref
        .read(scheduleRepositoryProvider)
        .watchHistory(from, today)
        .first;
    final diary = await ref.read(diaryRepositoryProvider).watchEntries().first;
    final prefs = await ref.read(extrasRepositoryProvider).watchPrefs().first;
    return buildReport(
      name: prefs.name,
      from: from,
      to: today,
      history: history,
      diary: diary,
      today: DateTime.now(),
    );
  }

  Future<void> _load() async {
    final r = await _build();
    if (mounted) setState(() => _report = r);
  }

  Future<void> _save(String ext) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final savedText = l10n.reportSaved;
    final files = ref.read(backupFilesProvider);
    final r = _report;
    if (r == null || _busy) return;
    setState(() => _busy = true);
    try {
      final Uint8List bytes = ext == 'pdf'
          ? await reportPdf(r, DateTime.now(), l10n)
          // The BOM makes Excel read the Cyrillic as UTF-8.
          : Uint8List.fromList([
              0xEF,
              0xBB,
              0xBF,
              ...utf8.encode(reportCsv(r, l10n)),
            ]);
      final saved = await files.save(
        'pillpal-report-${r.to.year}-${r.to.month.toString().padLeft(2, '0')}-${r.to.day.toString().padLeft(2, '0')}.$ext',
        bytes,
        mimeType: ext == 'pdf' ? 'application/pdf' : 'text/csv',
      );
      if (saved) {
        messenger.showSnackBar(SnackBar(content: Text(savedText)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _report;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SegmentedPills<int>(
            options: {
              7: context.l10n.days7,
              30: context.l10n.days30,
              90: context.l10n.days90,
            },
            selected: _days,
            onChanged: (v) {
              setState(() {
                _days = v;
                _report = null;
              });
              _load();
            },
          ),
          const SizedBox(height: AppSpacing.md),
          if (r == null)
            const Center(child: CircularProgressIndicator())
          else ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reportPeriod(r), style: AppType.cardTitle),
                  const SizedBox(height: AppSpacing.sm),
                  if (r.medicines.isEmpty)
                    Text(context.l10n.noIntakesInPeriod)
                  else
                    for (final m in r.medicines)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          context.l10n.medicineTakenOf(
                                m.name,
                                m.taken,
                                m.planned,
                              ) +
                              (m.missed > 0
                                  ? context.l10n.notMarkedPart(m.missed)
                                  : ''),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.diaryCount(r.diary.length),
                    style: AppType.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Pressable(
              child: FilledButton.icon(
                onPressed: _busy ? null : () => _save('pdf'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(context.l10n.savePdf),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Pressable(
              child: OutlinedButton.icon(
                onPressed: _busy ? null : () => _save('csv'),
                icon: const Icon(Icons.table_chart_outlined),
                label: Text(context.l10n.saveCsv),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
