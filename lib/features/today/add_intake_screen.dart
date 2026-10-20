import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/date_field.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/form_save_bar.dart';
import '../../design_system/widgets/mascot_pill.dart';
import '../../design_system/widgets/pill_widgets.dart';
import '../../design_system/widgets/section_header.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/medicine_form.dart';
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
  MealRelation? _meal;
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
    _meal = e.mealRelation;
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
      mealRelation: _meal,
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
                mealRelation: _meal,
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

  /// A summary of what is being set up, in the app's friendly voice.
  Widget _preview(List<MedicineStock> stock) {
    final name = stock
        .where((s) => s.medicine.id == _medicineId)
        .map((s) => s.medicine.name)
        .firstOrNull;
    final perDay = _times.isEmpty ? 1 : _times.length;
    final end = _end;
    final days = _kind == ScheduleKind.dates
        ? _dates.length
        : end == null
        ? null
        : end.difference(_start).inDays.abs() + 1;
    final parts = [
      '$perDay ${perDay == 1 ? 'раз' : 'раза'} в день',
      if (_meal != null) _meal!.label.toLowerCase(),
      if (days != null) '$days дн.',
    ];
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ПРЕДПРОСМОТР КУРСА', style: AppType.caption),
                Text(name ?? 'Выберите лекарство', style: AppType.title),
                Text(parts.join(' • '), style: AppType.caption),
              ],
            ),
          ),
          const MascotPill(size: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(medicineStockProvider).value ?? const [];
    const gap = SizedBox(height: AppSpacing.md);
    const chipGap = AppSpacing.sm;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'Новый приём' : 'Расписание'),
      ),
      bottomNavigationBar: FormSaveBar(
        saving: _saving,
        onSave: () => _save(stock),
        label: 'Сохранить приём',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            const SectionHeader(title: 'Лекарство и дозировка'),
            if (stock.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text('В аптечке пока нет лекарств. Создайте первое.'),
              )
            else
              FormField<String>(
                initialValue: _medicineId,
                validator: (_) =>
                    _medicineId == null ? 'Выберите лекарство' : null,
                builder: (f) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: chipGap,
                      runSpacing: chipGap,
                      children: [
                        for (final s in stock)
                          ChoiceChip(
                            label: Text(s.medicine.name),
                            selected: s.medicine.id == _medicineId,
                            // Changing the medicine would move its history to
                            // another one.
                            onSelected: _editing == null
                                ? (_) => setState(
                                    () => _medicineId = s.medicine.id,
                                  )
                                : null,
                          ),
                      ],
                    ),
                    if (f.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          f.errorText!,
                          style: AppType.caption.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
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
            const SectionHeader(title: 'Повторение'),
            SegmentedPills<ScheduleKind>(
              options: const {
                ScheduleKind.daily: 'Каждый день',
                ScheduleKind.weekdays: 'По дням',
                ScheduleKind.dates: 'По датам',
              },
              selected: _kind,
              onChanged: (v) => setState(() => _kind = v),
            ),
            if (_kind == ScheduleKind.weekdays) ...[
              const SectionHeader(title: 'Дни недели'),
              Wrap(
                spacing: chipGap,
                runSpacing: chipGap,
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
            ],
            if (_kind == ScheduleKind.dates) ...[
              const SectionHeader(title: 'Даты'),
              Wrap(
                spacing: chipGap,
                runSpacing: chipGap,
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
            ],
            const SectionHeader(title: 'Время приёма'),
            Wrap(
              spacing: chipGap,
              runSpacing: chipGap,
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
            const SectionHeader(title: 'Связь с приёмом пищи'),
            SegmentedPills<MealRelation?>(
              options: {
                for (final m in MealRelation.values) m: m.label,
                null: 'Не важно',
              },
              selected: _meal,
              onChanged: (v) => setState(() => _meal = v),
            ),
            if (_kind != ScheduleKind.dates) ...[
              const SectionHeader(title: 'Период'),
              DateField(
                label: 'Начало',
                helpText: 'Дата начала',
                value: _start,
                // A started schedule keeps its start.
                onChanged: _started
                    ? null
                    : (d) => setState(() => _start = dateOnly(d ?? _start)),
              ),
              gap,
              DateField(
                label: 'Окончание (необязательно)',
                helpText: 'Дата окончания',
                value: _end,
                initialDate: _started ? _today : _start,
                firstDate: _started ? _today : null,
                icon: Icons.event_busy_outlined,
                emptyText: 'Не указано',
                clearTooltip: 'Очистить',
                onChanged: (d) =>
                    setState(() => _end = d == null ? null : dateOnly(d)),
              ),
              if (!_started) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: chipGap,
                  children: [
                    for (final n in const [7, 14, 30])
                      ActionChip(
                        label: Text('$n дн.'),
                        onPressed: () => setState(
                          () => _end = DateTime(
                            _start.year,
                            _start.month,
                            _start.day + n - 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
            gap,
            _preview(stock),
            if (_editing != null) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
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
