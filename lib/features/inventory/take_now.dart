import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/motion.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/models.dart';
import '../../domain/schedule.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import 'format.dart';
import 'inventory_providers.dart';
import 'medicine_card.dart';

/// Asks which medicine, then records an intake of it outside any schedule.
Future<void> pickAndTakeNow(BuildContext context, WidgetRef ref) async {
  final l = context.l10n;
  final stock = [
    for (final s
        in ref.read(medicineStockProvider).value ?? const <MedicineStock>[])
      if (s.totalQuantity > 0) s,
  ];
  if (stock.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.nothingToTake)));
    return;
  }
  final picked = await showModalBottomSheet<MedicineStock>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (c) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final s in stock)
            ListTile(
              leading: MedicineAvatar(
                form: s.medicine.form,
                look: s.medicine.look,
              ),
              title: Text(s.medicine.name),
              subtitle: Text(l.quantity(s.totalQuantity, s.unit)),
              onTap: () => Navigator.pop(c, s),
            ),
        ],
      ),
    ),
  );
  if (picked != null && context.mounted) await takeNow(context, ref, picked);
}

/// An intake outside any schedule: a one-day schedule at the current
/// minute, marked taken, so stock, history and streak work as for any other.
Future<void> takeNow(
  BuildContext context,
  WidgetRef ref,
  MedicineStock stock,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l = context.l10n;
  final negative = l.negativeStock;
  final dose = await showDialog<double>(
    context: context,
    builder: (_) => _TakeNowDialog(unit: stock.unit),
  );
  if (dose == null) return;
  // Checked first: a refused intake must not leave an open schedule behind.
  if (dose > stock.totalQuantity) {
    messenger.showSnackBar(SnackBar(content: Text(negative)));
    return;
  }
  final now = DateTime.now();
  final day = dateOnly(now);
  final minute = now.hour * 60 + now.minute;
  final repo = ref.read(scheduleRepositoryProvider);
  try {
    final id = await repo.createSchedule(
      NewSchedule(
        medicineId: stock.medicine.id,
        kind: ScheduleKind.dates,
        dose: dose,
        doseUnit: stock.unit,
        startDate: day,
        dates: [day],
        times: [minute],
      ),
    );
    await repo.markTaken(scheduleId: id, day: day, minuteOfDay: minute);
    messenger.showSnackBar(
      SnackBar(content: Text(l.takenRecorded(l.quantity(dose, stock.unit)))),
    );
  } on InsufficientStockException {
    messenger.showSnackBar(SnackBar(content: Text(negative)));
  }
}

class _TakeNowDialog extends StatefulWidget {
  const _TakeNowDialog({required this.unit});

  final String unit;

  @override
  State<_TakeNowDialog> createState() => _TakeNowDialogState();
}

class _TakeNowDialogState extends State<_TakeNowDialog> {
  final _dose = TextEditingController(text: '1');
  String? _error;

  @override
  void dispose() {
    _dose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(context.l10n.takeNow),
    content: TextField(
      controller: _dose,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: context.l10n.howManyTaken,
        suffixText: context.l10n.unit(widget.unit),
        errorText: _error,
      ),
    ),
    actions: [
      Pressable(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
      ),
      Pressable(
        child: FilledButton(
          onPressed: () {
            final q = parseQuantity(_dose.text);
            if (q == null || !q.isFinite || q <= 0) {
              setState(() => _error = context.l10n.enterPositive);
              return;
            }
            Navigator.pop(context, q);
          },
          child: Text(context.l10n.record),
        ),
      ),
    ],
  );
}
