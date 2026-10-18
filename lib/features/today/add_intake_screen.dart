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

/// Creates a schedule, or changes [editing] (a live schedule: its medicine
/// stays, and so does everything before the change).
class AddIntakeScreen extends ConsumerStatefulWidget {
  const AddIntakeScreen({super.key, this.editing});

  final Schedule? editing;

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

  Schedule? get _editing => widget.editing;

  /// A started schedule keeps its start and its past: changes begin later.
  bool get _started => _editing != null && _editing!.startDate.isBefore(_today);
  DateTime get _today => dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    final e = _editing;
    if (e == null) return;
    _dose.text = formatQuantity(e.dose);
    _medicineId = e.medicineId;
    _kind = e.kind;
    _weekdays.addAll(e.weekdays);
    _dates.addAll([
      for (final d in e.dates)
        if (!_started || !dateOnly(d).isBefore(_today)) dateOnly(d),
    ]);
    _times.addAll(e.times);
    _start = dateOnly(e.startDate);
    _end = e.endDate == null ? null : dateOnly(e.endDate!);
  }

  @override
  void dispose() {
    _dose.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(
    DateTime initial,
    String help, {
    bool fromToday = false,
  }) => showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: fromToday ? _today : DateTime(2000),
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
    final dose = parseQuantity(_dose.text)!;
    NewSchedule draft(String medicineId) => NewSchedule(
      medicineId: medicineId,
      kind: _kind,
      dose: dose,
      doseUnit: stock.firstWhere((s) => s.medicine.id == _medicineId).unit,
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
      if (_editing == null) validateNewSchedule(draft(_medicineId!));
      // Asked before saving, so the schedule is planned with the answer.
      var muted = false;
      if (_times.isNotEmpty) {
        final reminders = ref.read(reminderSchedulerProvider);
        muted =
            !await reminders.notificationsAllowed() &&
            !await reminders.requestPermission();
      }
      var from = _today;
      if (_editing == null) {
        await ref
            .read(scheduleRepositoryProvider)
            .createSchedule(draft(_medicineId!));
      } else {
        from = await ref
            .read(scheduleRepositoryProvider)
            .updateSchedule(
              _editing!.id,
              ScheduleEdit(
                kind: _kind,
                dose: dose,
                times: _times.toList(),
                weekdays: _weekdays,
                dates: _dates,
                startDate: _start,
                endDate: _end,
              ),
            );
      }
      navigator.pop();
      if (from.isAfter(_today)) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Изменения вступят в силу с завтрашнего дня: сегодня уже есть отметка',
            ),
          ),
        );
      }
      if (muted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Уведомления выключены. Включите их в настройках, чтобы '
              'получать напоминания',
            ),
          ),
        );
      }
    } on InvalidScheduleException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _saving = false);
    } on ScheduleEndedException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Расписание уже изменено или завершено')),
      );
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(medicineStockProvider).value ?? const [];
    final gap = const SizedBox(height: AppSpacing.md);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'Новый приём' : 'Расписание'),
      ),
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
                // Changing the medicine would move its history to another one.
                onChanged: _editing == null
                    ? (v) => setState(() => _medicineId = v)
                    : null,
              ),
            if (_editing == null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _newMedicine,
                  icon: const Icon(Icons.add),
                  label: const Text('Новое лекарство'),
                ),
              )
            else
              gap,
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
                      final p = await _pickDate(
                        DateTime.now(),
                        'Дата приёма',
                        fromToday: _started,
                      );
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
                onTap: _started
                    ? null
                    : () async {
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
                  final p = await _pickDate(
                    _end ?? (_started ? _today : _start),
                    'Дата окончания',
                    fromToday: _started,
                  );
                  if (p != null) setState(() => _end = dateOnly(p));
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : () => _save(stock),
              child: const Text('Сохранить'),
            ),
            if (_editing != null) ...[
              gap,
              OutlinedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        if (await confirmEndSchedule(context, ref, _editing!)) {
                          navigator.pop();
                        }
                      },
                child: const Text('Завершить расписание'),
              ),
            ],
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
  final VoidCallback? onTap;
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
