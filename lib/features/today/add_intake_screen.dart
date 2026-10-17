import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/models.dart';
import '../../domain/schedule.dart';
import '../inventory/add_medicine_screen.dart';
import '../inventory/format.dart';
import '../inventory/inventory_providers.dart';
import 'today_screen.dart';

const _weekdayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

class AddIntakeScreen extends ConsumerStatefulWidget {
  const AddIntakeScreen({super.key});

  @override
  ConsumerState<AddIntakeScreen> createState() => _AddIntakeScreenState();
}

class _AddIntakeScreenState extends ConsumerState<AddIntakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dose = TextEditingController(text: '1');
  String? _medicineId;
  ScheduleKind _kind = ScheduleKind.daily;
  final _weekdays = <int>{};
  final _dates = <DateTime>[];
  final _times = <int>{};
  DateTime _start = dateOnly(DateTime.now());
  DateTime? _end;
  bool _saving = false;

  @override
  void dispose() {
    _dose.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime initial, String help) => showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    helpText: help,
  );

  Future<void> _newMedicine() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
    // Null when cancelled; everything typed here is still in this State.
    if (id != null && mounted) setState(() => _medicineId = id);
  }

  Future<void> _save(List<MedicineStock> stock) async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final doseUnit = stock.firstWhere((s) => s.medicine.id == _medicineId).unit;
    final dose = parseQuantity(_dose.text)!;
    NewSchedule draft(String medicineId) => NewSchedule(
      medicineId: medicineId,
      kind: _kind,
      dose: dose,
      doseUnit: doseUnit,
      weekdays: _weekdays,
      dates: _dates,
      // A date list starts at its earliest date.
      startDate: _kind == ScheduleKind.dates
          ? (_dates.isEmpty ? _start : ([..._dates]..sort()).first)
          : _start,
      endDate: _kind == ScheduleKind.dates ? null : _end,
      times: _times.toList(),
    );
    setState(() => _saving = true);
    try {
      validateNewSchedule(draft(_medicineId!));
      await ref
          .read(scheduleRepositoryProvider)
          .createSchedule(draft(_medicineId!));
      navigator.pop();
    } on InvalidScheduleException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(medicineStockProvider).value ?? const [];
    final gap = const SizedBox(height: AppSpacing.md);
    return Scaffold(
      appBar: AppBar(title: const Text('Новый приём')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (stock.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text('В аптечке пока нет лекарств. Создайте первое.'),
              )
            else
              DropdownButtonFormField<String>(
                // Re-created when the selection is set from outside.
                key: ValueKey(_medicineId),
                initialValue: stock.any((s) => s.medicine.id == _medicineId)
                    ? _medicineId
                    : null,
                decoration: const InputDecoration(labelText: 'Лекарство *'),
                items: [
                  for (final s in stock)
                    DropdownMenuItem(
                      value: s.medicine.id,
                      child: Text(s.medicine.name),
                    ),
                ],
                validator: (v) => v == null ? 'Выберите лекарство' : null,
                onChanged: (v) => setState(() => _medicineId = v),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _newMedicine,
                icon: const Icon(Icons.add),
                label: const Text('Новое лекарство'),
              ),
            ),
            gap,
            TextFormField(
              controller: _dose,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Дозировка за один приём',
                suffixText: stock
                    .where((s) => s.medicine.id == _medicineId)
                    .map((s) => s.unit)
                    .firstOrNull,
              ),
              validator: (v) {
                final q = parseQuantity(v ?? '');
                return (q == null || !q.isFinite || q <= 0)
                    ? 'Введите число больше нуля'
                    : null;
              },
            ),
            gap,
            SegmentedButton<ScheduleKind>(
              segments: const [
                ButtonSegment(
                  value: ScheduleKind.daily,
                  label: Text('Каждый день'),
                ),
                ButtonSegment(
                  value: ScheduleKind.weekdays,
                  label: Text('По дням'),
                ),
                ButtonSegment(
                  value: ScheduleKind.dates,
                  label: Text('По датам'),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (v) => setState(() => _kind = v.first),
            ),
            gap,
            if (_kind == ScheduleKind.weekdays)
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (var i = 0; i < 7; i++)
                    FilterChip(
                      label: Text(_weekdayLabels[i]),
                      selected: _weekdays.contains(i + 1),
                      onSelected: (on) => setState(
                        () =>
                            on ? _weekdays.add(i + 1) : _weekdays.remove(i + 1),
                      ),
                    ),
                ],
              ),
            if (_kind == ScheduleKind.dates)
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final d in _dates)
                    InputChip(
                      label: Text(formatDate(d)),
                      onDeleted: () => setState(() => _dates.remove(d)),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.add),
                    label: const Text('Добавить дату'),
                    onPressed: () async {
                      final p = await _pickDate(DateTime.now(), 'Дата приёма');
                      if (p != null && !_dates.contains(dateOnly(p))) {
                        setState(() => _dates.add(dateOnly(p)));
                      }
                    },
                  ),
                ],
              ),
            gap,
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final t in ([..._times]..sort()))
                  InputChip(
                    label: Text(formatMinute(t)),
                    onDeleted: () => setState(() => _times.remove(t)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.schedule),
                  label: Text(
                    _times.isEmpty
                        ? 'Добавить время (необязательно)'
                        : 'Добавить время',
                  ),
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (t != null) {
                      setState(() => _times.add(t.hour * 60 + t.minute));
                    }
                  },
                ),
              ],
            ),
            if (_kind != ScheduleKind.dates) ...[
              gap,
              _PickerTile(
                label: 'Начало',
                value: formatDate(_start),
                icon: Icons.calendar_today_outlined,
                onTap: () async {
                  final p = await _pickDate(_start, 'Дата начала');
                  if (p != null) setState(() => _start = dateOnly(p));
                },
              ),
              gap,
              _PickerTile(
                label: 'Окончание (необязательно)',
                value: _end == null ? null : formatDate(_end!),
                icon: Icons.event_busy_outlined,
                onClear: () => setState(() => _end = null),
                onTap: () async {
                  final p = await _pickDate(_end ?? _start, 'Дата окончания');
                  if (p != null) setState(() => _end = dateOnly(p));
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : () => _save(stock),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(AppRadii.md),
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: value != null && onClear != null
            ? IconButton(
                tooltip: 'Очистить',
                icon: const Icon(Icons.close),
                onPressed: onClear,
              )
            : Icon(icon),
      ),
      child: Text(value ?? 'Не указано'),
    ),
  );
}
