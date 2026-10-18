import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/reminders.dart';
import '../../domain/schedule.dart';
import '../inventory/format.dart';
import 'add_intake_screen.dart';
import 'history_screen.dart';
import 'today_providers.dart';

const _months = [
  'января',
  'февраля',
  'марта',
  'апреля',
  'мая',
  'июня',
  'июля',
  'августа',
  'сентября',
  'октября',
  'ноября',
  'декабря',
]; // prettier-ignore

String formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatMinute(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

/// Home screen: the intake tracker for one day (today by default).
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  DateTime _day = dateOnly(DateTime.now());

  /// The intake a tapped reminder pointed at, marked until the day changes.
  OpenIntakeRequest? _highlight;

  @override
  void initState() {
    super.initState();
    // A reminder that launched the app was tapped before this screen existed.
    final request = ref.read(openIntakeProvider);
    if (request != null) {
      _day = request.day;
      _highlight = request;
    }
  }

  void _shift(int days) => setState(() {
    _day = DateTime(_day.year, _day.month, _day.day + days);
    _highlight = null;
  });

  Future<void> _take(DayIntake i) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(scheduleRepositoryProvider)
          .markTaken(
            scheduleId: i.schedule.id,
            day: _day,
            minuteOfDay: i.minuteOfDay,
          );
    } on InsufficientStockException {
      messenger.showSnackBar(
        const SnackBar(content: Text('В аптечке не хватает лекарства')),
      );
    }
  }

  Future<void> _skip(DayIntake i) => ref
      .read(scheduleRepositoryProvider)
      .markSkipped(
        scheduleId: i.schedule.id,
        day: _day,
        minuteOfDay: i.minuteOfDay,
      );

  Future<void> _reset(DayIntake i) => ref
      .read(scheduleRepositoryProvider)
      .resetMark(
        scheduleId: i.schedule.id,
        day: _day,
        minuteOfDay: i.minuteOfDay,
      );

  @override
  Widget build(BuildContext context) {
    ref.listen(openIntakeProvider, (_, request) {
      if (request != null) {
        setState(() {
          _day = request.day;
          _highlight = request;
        });
      }
    });
    final text = Theme.of(context).textTheme;
    final today = dateOnly(DateTime.now());
    final isToday = _day == today;
    final intakes = ref.watch(dayIntakesProvider(_day));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Приём'),
        actions: [
          IconButton(
            tooltip: 'История',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            96,
          ),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Предыдущий день',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shift(-1),
                ),
                Expanded(
                  child: Text(
                    isToday ? 'Сегодня, ${formatDay(_day)}' : formatDay(_day),
                    textAlign: TextAlign.center,
                    style: text.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Следующий день',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shift(1),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            intakes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  const Center(child: Text('Не удалось загрузить приёмы')),
              data: (list) => list.isEmpty
                  ? const _Empty()
                  : Column(
                      children: [
                        for (final i in list)
                          _IntakeCard(
                            intake: i,
                            // Marking a future dose as taken makes no sense.
                            canMark: !_day.isAfter(today),
                            // Only the live version of a schedule can be
                            // changed; earlier ones are history.
                            manageable: isCurrent(i.schedule, today),
                            onEdit: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    AddIntakeScreen(editing: i.schedule),
                              ),
                            ),
                            onEnd: () =>
                                confirmEndSchedule(context, ref, i.schedule),
                            highlighted:
                                _highlight?.scheduleId == i.schedule.id &&
                                _highlight?.minuteOfDay == i.minuteOfDay,
                            onTake: () => _take(i),
                            onSkip: () => _skip(i),
                            onReset: () => _reset(i),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Tabs are kept alive side by side; two default hero tags would clash.
        heroTag: 'add-intake',
        tooltip: 'Добавить приём',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddIntakeScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _IntakeCard extends StatelessWidget {
  const _IntakeCard({
    required this.intake,
    required this.canMark,
    required this.highlighted,
    required this.manageable,
    required this.onEdit,
    required this.onEnd,
    required this.onTake,
    required this.onSkip,
    required this.onReset,
  });

  final DayIntake intake;
  final bool canMark;
  final bool highlighted;
  final bool manageable;
  final VoidCallback onEdit;
  final VoidCallback onEnd;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = intake.schedule;
    final time = intake.minuteOfDay == null
        ? ''
        : '${formatMinute(intake.minuteOfDay!)} · ';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: kMinTapSize),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: intake.status != IntakeStatus.pending
              ? AppColors.primaryLight
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: highlighted
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
          boxShadow: intake.status != IntakeStatus.pending
              ? null
              : AppShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(intake.medicineName, style: text.titleMedium),
                  Text(
                    '$time${formatQuantity(s.dose)} ${s.doseUnit}',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (intake.status == IntakeStatus.pending) ...[
              IconButton(
                tooltip: 'Пропустить',
                icon: const Icon(Icons.skip_next),
                onPressed: canMark ? onSkip : null,
              ),
              FilledButton(
                onPressed: canMark ? onTake : null,
                child: const Text('Принято'),
              ),
            ] else ...[
              intakeStatusLabel(intake.status),
              if (intake.canReset)
                IconButton(
                  tooltip: 'Отменить отметку',
                  icon: const Icon(Icons.undo),
                  onPressed: onReset,
                ),
            ],
            PopupMenuButton<VoidCallback>(
              tooltip: 'Управление расписанием',
              onSelected: (action) => action(),
              itemBuilder: (_) => manageable
                  ? [
                      PopupMenuItem(
                        value: onEdit,
                        child: const Text('Изменить расписание'),
                      ),
                      PopupMenuItem(
                        value: onEnd,
                        child: const Text('Завершить расписание'),
                      ),
                    ]
                  : const [
                      PopupMenuItem(
                        enabled: false,
                        child: Text('Расписание уже изменено или завершено'),
                      ),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks, then ends [s] with effect from the next day it can; returns whether
/// it was ended.
Future<bool> confirmEndSchedule(
  BuildContext context,
  WidgetRef ref,
  Schedule s,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Завершить расписание?'),
      content: const Text('Прошлые приёмы сохранятся, будущие исчезнут.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Завершить'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  final from = await ref.read(scheduleRepositoryProvider).endSchedule(s.id);
  if (from.isAfter(dateOnly(DateTime.now()))) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Расписание завершится со следующего дня: сегодня уже есть отметка',
        ),
      ),
    );
  }
  return true;
}

/// Icon and name of a mark; shared by the day and history screens.
Widget intakeStatusLabel(IntakeStatus status) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    switch (status) {
      IntakeStatus.taken => const Icon(
        Icons.check_circle,
        color: AppColors.success,
      ),
      IntakeStatus.skipped => const Icon(
        Icons.remove_circle_outline,
        color: AppColors.textSecondary,
      ),
      IntakeStatus.pending => const Icon(
        Icons.radio_button_unchecked,
        color: AppColors.textSecondary,
      ),
    },
    const SizedBox(width: AppSpacing.xs),
    Text(switch (status) {
      IntakeStatus.taken => 'Принято',
      IntakeStatus.skipped => 'Пропущено',
      IntakeStatus.pending => 'Не отмечено',
    }),
  ],
);

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: AppSpacing.xl),
      Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.event_available,
          size: 48,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        'На этот день приёмов нет',
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.sm),
      const Text(
        'Нажмите «+», чтобы добавить приём',
        textAlign: TextAlign.center,
      ),
    ],
  );
}
