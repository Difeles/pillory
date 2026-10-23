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
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../inventory/format.dart';
import '../inventory/inventory_providers.dart';
import 'today_screen.dart';
import '../../design_system/pickers.dart';
import '../../design_system/motion.dart';

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

  // How many more years the course is repeated.
  int _repeatYears = 0;

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
  }) => pickDate(
    context,
    initial: initial,
    first: fromToday ? _today : DateTime(2000),
    last: DateTime(2100),
    title: help,
  );

  Future<void> _newMedicine() async {
    final id = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
    // Null when cancelled; everything typed here is still in this State.
    if (id != null && mounted) setState(() => _medicineId = id);
  }

  Future<void> _save(List<MedicineStock> stock) async {
    final valid = _formKey.currentState!.validate();
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l10n;
    // With an empty cabinet there is no medicine field to validate.
    if (_medicineId == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              stock.isEmpty ? l.createMedicineFirst : l.chooseMedicine,
            ),
          ),
        );
      return;
    }
    if (!valid || _saving) return;
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
      final drafts = [draft(_medicineId!)];
      if (_editing == null) drafts.forEach(validateNewSchedule);
      // The same course again in the following years.
      if (_editing == null &&
          _repeatYears > 0 &&
          drafts.every((d) => d.endDate != null)) {
        final first = [...drafts];
        for (var y = 1; y <= _repeatYears; y++) {
          drafts.addAll([for (final d in first) shiftedByYears(d, y)]);
        }
      }
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
        for (final d in drafts) {
          await ref.read(scheduleRepositoryProvider).createSchedule(d);
        }
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
        messenger.showSnackBar(SnackBar(content: Text(l.changesFromTomorrow)));
      }
      if (muted) {
        messenger.showSnackBar(SnackBar(content: Text(l.notificationsOffHint)));
      }
    } on InvalidScheduleException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l.problem(e.message))));
      if (mounted) setState(() => _saving = false);
    } on ScheduleEndedException {
      messenger.showSnackBar(SnackBar(content: Text(l.scheduleAlreadyChanged)));
      navigator.pop();
    }
  }

  /// A summary of what is being set up, in the app's friendly voice.
  Widget _preview(List<MedicineStock> stock) {
    final name = stock
        .where((s) => s.medicine.id == _medicineId)
        .map((s) => s.medicine.name)
        .firstOrNull;
    final l = context.l10n;
    final perDay = _times.isEmpty ? 1 : _times.length;
    final end = _end;
    final days = _kind == ScheduleKind.dates
        ? _dates.length
        : end == null
        ? null
        : end.difference(_start).inDays.abs() + 1;
    final parts = [
      l.timesPerDay(perDay),
      if (_meal != null) l.meal(_meal!).toLowerCase(),
      if (days != null) l.daysShort(days),
    ];
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.coursePreview, style: AppType.caption),
                Text(name ?? l.chooseMedicine, style: AppType.title),
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
    final l = context.l10n;
    const gap = SizedBox(height: AppSpacing.md);
    const chipGap = AppSpacing.sm;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? l.newIntake : l.scheduleTitle),
      ),
      bottomNavigationBar: FormSaveBar(
        saving: _saving,
        onSave: () => _save(stock),
        label: l.saveIntake,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            SectionHeader(title: l.secMedicineDose),
            if (stock.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(l.cabinetEmptyCreate),
              )
            else
              FormField<String>(
                initialValue: _medicineId,
                validator: (_) => _medicineId == null ? l.chooseMedicine : null,
                builder: (f) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: chipGap,
                      runSpacing: chipGap,
                      children: [
                        for (final s in stock)
                          Pressable(
                            scale: .93,
                            child: ChoiceChip(
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
                          ),
                      ],
                    ),
                    if (f.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          f.errorText!,
                          style: AppType.caption.copyWith(
                            color: context.colors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (_editing == null)
              Align(
                alignment: Alignment.centerLeft,
                child: Pressable(
                  child: TextButton.icon(
                    onPressed: _newMedicine,
                    icon: const Icon(Icons.add),
                    label: Text(l.newMedicine),
                  ),
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
                labelText: l.doseLabel,
                suffixText: stock
                    .where((s) => s.medicine.id == _medicineId)
                    .map((s) => l.unit(s.unit))
                    .firstOrNull,
              ),
              validator: (v) {
                final q = parseQuantity(v ?? '');
                return (q == null || !q.isFinite || q <= 0)
                    ? l.enterPositive
                    : null;
              },
            ),
            SectionHeader(title: l.secRepeat),
            SegmentedPills<ScheduleKind>(
              options: {
                ScheduleKind.daily: l.repeatDaily,
                ScheduleKind.weekdays: l.repeatWeekdays,
                ScheduleKind.dates: l.repeatDates,
              },
              selected: _kind,
              onChanged: (v) => setState(() => _kind = v),
            ),
            if (_kind == ScheduleKind.weekdays) ...[
              SectionHeader(title: l.secWeekdays),
              Wrap(
                spacing: chipGap,
                runSpacing: chipGap,
                children: [
                  for (var i = 0; i < 7; i++)
                    Pressable(
                      scale: .93,
                      child: FilterChip(
                        label: Text(l.weekdayShort(i + 1)),
                        selected: _weekdays.contains(i + 1),
                        onSelected: (on) => setState(
                          () => on
                              ? _weekdays.add(i + 1)
                              : _weekdays.remove(i + 1),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            if (_kind == ScheduleKind.dates) ...[
              SectionHeader(title: l.secDates),
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
                    label: Text(l.addDate),
                    onPressed: () async {
                      final p = await _pickDate(
                        DateTime.now(),
                        l.intakeDate,
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
            SectionHeader(title: l.secTimes),
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
                  label: Text(_times.isEmpty ? l.addTimeOptional : l.addTime),
                  onPressed: () async {
                    final t = await pickTime(
                      context,
                      initial: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (t != null) {
                      setState(() => _times.add(t.hour * 60 + t.minute));
                    }
                  },
                ),
              ],
            ),
            SectionHeader(title: l.secMeal),
            SegmentedPills<MealRelation?>(
              options: {
                for (final m in MealRelation.values) m: l.meal(m),
                null: l.mealAny,
              },
              selected: _meal,
              onChanged: (v) => setState(() => _meal = v),
            ),
            if (_kind != ScheduleKind.dates) ...[
              SectionHeader(title: l.secPeriod),
              DateField(
                label: l.startLabel,
                helpText: l.startHelp,
                value: _start,
                // A started schedule keeps its start.
                onChanged: _started
                    ? null
                    : (d) => setState(() => _start = dateOnly(d ?? _start)),
              ),
              gap,
              DateField(
                label: l.endOptional,
                helpText: l.endHelp,
                value: _end,
                initialDate: _started ? _today : _start,
                firstDate: _started ? _today : null,
                icon: Icons.event_busy_outlined,
                emptyText: l.notSpecifiedN,
                clearTooltip: l.clear,
                onChanged: (d) =>
                    setState(() => _end = d == null ? null : dateOnly(d)),
              ),
              if (!_started) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: chipGap,
                  children: [
                    for (final n in const [7, 14, 30, 60, 90])
                      ActionChip(
                        label: Text(l.daysShort(n)),
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
            if (_editing == null &&
                _kind != ScheduleKind.dates &&
                _end != null) ...[
              SectionHeader(title: l.secRepeatYearly),
              SegmentedPills<int>(
                options: {
                  0: l.repeatNone,
                  for (final n in const [1, 2, 3]) n: l.repeatYears(n),
                },
                selected: _repeatYears,
                onChanged: (v) => setState(() => _repeatYears = v),
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(l.repeatYearlyHint, style: AppType.caption),
              ),
            ],
            gap,
            _preview(stock),
            if (_editing != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Pressable(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.danger,
                    side: BorderSide(color: context.colors.danger),
                  ),
                  onPressed: _saving
                      ? null
                      : () async {
                          final navigator = Navigator.of(context);
                          if (await confirmEndSchedule(
                            context,
                            ref,
                            _editing!,
                          )) {
                            navigator.pop();
                          }
                        },
                  child: Text(l.endScheduleItem),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
