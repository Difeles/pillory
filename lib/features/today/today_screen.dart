import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/confirm_dialog.dart';
import '../../design_system/widgets/states.dart';
import '../../design_system/widgets/status_badge.dart';
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

const _weekdays = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
];

/// "Сегодня · суббота" next to today, else just the weekday.
String _dayCaption(DateTime day, DateTime today) {
  final weekday = _weekdays[day.weekday - 1];
  // Calendar days, not hours: a DST day is 23 or 25 hours long.
  DateTime shifted(int d) => DateTime(today.year, today.month, today.day + d);
  final relative = day == today
      ? 'Сегодня'
      : day == shifted(-1)
      ? 'Вчера'
      : day == shifted(1)
      ? 'Завтра'
      : null;
  return relative == null ? weekday : '$relative · ${weekday.toLowerCase()}';
}

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
    final intakes = ref.watch(dayIntakesProvider(_day));
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            96,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dayCaption(_day, today),
                    style: text.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Предыдущий день',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shift(-1),
                ),
                IconButton(
                  tooltip: 'Следующий день',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shift(1),
                ),
                IconButton(
                  tooltip: 'История',
                  icon: const Icon(Icons.history),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HistoryScreen(),
                    ),
                  ),
                ),
              ],
            ),
            Semantics(
              header: true,
              child: Text(formatDay(_day), style: text.displaySmall),
            ),
            const SizedBox(height: AppSpacing.lg),
            intakes.when(
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(
                message: 'Не удалось загрузить приёмы',
                onRetry: () => ref.invalidate(dayIntakesProvider(_day)),
              ),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.event_available,
                      title: 'На этот день приёмов нет',
                      message: 'Нажмите «+», чтобы добавить приём',
                    )
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
    final done = intake.status != IntakeStatus.pending;
    final minute = intake.minuteOfDay;
    final actions = done
        ? [
            _statusBadge(intake.status),
            if (intake.canReset)
              IconButton(
                tooltip: 'Отменить отметку',
                icon: const Icon(Icons.undo),
                onPressed: onReset,
              ),
          ]
        : [
            FilledButton.tonal(
              onPressed: canMark ? onSkip : null,
              child: const Text('Пропустить'),
            ),
            FilledButton(
              onPressed: canMark ? onTake : null,
              child: const Text('Принято'),
            ),
          ];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.ms),
      child: AppCard(
        variant: highlighted
            ? AppCardVariant.highlighted
            : done
            ? AppCardVariant.muted
            : AppCardVariant.normal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (minute != null)
                        Text(
                          formatMinute(minute),
                          style: text.titleSmall?.copyWith(
                            color: AppColors.primaryDeep,
                            fontFeatures: AppType.numeric.fontFeatures,
                          ),
                        ),
                      Text(
                        intake.medicineName,
                        style: text.titleMedium?.copyWith(
                          color: done ? AppColors.textSecondary : null,
                        ),
                      ),
                    ],
                  ),
                ),
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
                            child: Text(
                              'Расписание уже изменено или завершено',
                            ),
                          ),
                        ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Wraps instead of overflowing: on a narrow screen or with large
            // text the actions move under the dose.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: AppSpacing.sm,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Text(
                    '${formatQuantity(s.dose)} ${s.doseUnit}',
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: actions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _statusBadge(IntakeStatus status) => switch (status) {
  IntakeStatus.taken => const StatusBadge(
    label: 'Принято',
    icon: Icons.check_circle,
    tone: StatusTone.success,
  ),
  IntakeStatus.skipped => const StatusBadge(
    label: 'Пропущено',
    icon: Icons.remove_circle_outline,
  ),
  IntakeStatus.pending => const StatusBadge(
    label: 'Не отмечено',
    icon: Icons.radio_button_unchecked,
  ),
};

/// Asks, then ends [s] with effect from the next day it can; returns whether
/// it was ended.
Future<bool> confirmEndSchedule(
  BuildContext context,
  WidgetRef ref,
  Schedule s,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showConfirmDialog(
    context,
    title: 'Завершить расписание?',
    message: 'Прошлые приёмы сохранятся, будущие исчезнут.',
    confirmLabel: 'Завершить',
    danger: true,
  );
  if (!ok) return false;
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
