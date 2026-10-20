import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/confirm_dialog.dart';
import '../../design_system/widgets/states.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../design_system/widgets/app_top_bar.dart';
import '../../design_system/widgets/confetti.dart';
import '../../design_system/widgets/mascot_pill.dart';
import '../../design_system/widgets/progress_ring.dart';
import '../../design_system/widgets/streak_banner.dart';
import '../../design_system/widgets/week_strip.dart';
import '../../domain/errors.dart';
import '../../domain/extras.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/reminders.dart';
import '../../domain/schedule.dart';
import '../../domain/streak.dart';
import '../inventory/format.dart';
import '../inventory/medicine_card.dart';
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

const _monthsNominative = [
  'Январь',
  'Февраль',
  'Март',
  'Апрель',
  'Май',
  'Июнь',
  'Июль',
  'Август',
  'Сентябрь',
  'Октябрь',
  'Ноябрь',
  'Декабрь',
]; // prettier-ignore

const _tips = [
  'Не забудь выпить стакан воды: таблетки лучше усваиваются.',
  'Поставь аптечку на видное место: так проще не пропускать приём.',
  'Каждая отметка — маленькая победа. Серия растёт!',
  'Проверь сроки годности раз в месяц: я подскажу, что скоро истечёт.',
];

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

  /// Set by a reminder; the list scrolls to [_highlight] once it has loaded.
  bool _scrollPending = false;
  final _highlightKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // A reminder that launched the app was tapped before this screen existed.
    final request = ref.read(openIntakeProvider);
    if (request != null) {
      _day = request.day;
      _highlight = request;
      _scrollPending = true;
    }
  }

  /// Brings the highlighted intake into view after this frame, when its row
  /// exists. A stale reminder matches no row; then nothing scrolls.
  void _scrollToHighlight() {
    _scrollPending = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _highlightKey.currentContext;
      if (!mounted || target == null) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.3,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppMotion.base,
        curve: AppMotion.curve,
      );
    });
  }

  void _select(DateTime day) => setState(() {
    _day = dateOnly(day);
    _highlight = null;
  });

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) _select(picked);
  }

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
      return;
    }
    final prefs = ref.read(prefsProvider).value ?? const AppPrefs();
    if (prefs.haptics) unawaited(HapticFeedback.mediumImpact());
    if (prefs.confetti && mounted) showConfetti(context);
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
          _scrollPending = true;
        });
      }
    });
    final today = dateOnly(DateTime.now());
    final intakes = ref.watch(dayIntakesProvider(_day));
    final history = ref.watch(historyProvider).value;
    final streak = ref.watch(streakProvider);
    return Scaffold(
      appBar: AppTopBar(
        title: 'Приём',
        actions: [
          TopBarAddButton(
            tooltip: 'Добавить приём',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AddIntakeScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          96,
        ),
        children: [
          if (streak > 0) ...[
            StreakBanner(days: streak),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    '${_monthsNominative[_day.month - 1]}, ${_day.year}',
                    style: AppType.title,
                  ),
                ),
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
              IconButton(
                tooltip: 'Весь месяц',
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: _pickDay,
              ),
            ],
          ),
          WeekStrip(
            selected: _day,
            done: (d) => dayComplete(history?[d]),
            onSelected: _select,
          ),
          const SizedBox(height: AppSpacing.md),
          intakes.when(
            loading: () => const LoadingState(),
            error: (e, _) => ErrorState(
              message: 'Не удалось загрузить приёмы',
              onRetry: () => ref.invalidate(dayIntakesProvider(_day)),
            ),
            data: (list) {
              if (_scrollPending) _scrollToHighlight();
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.event_available,
                  title: 'На этот день приёмов нет',
                  message: 'Нажмите «+», чтобы добавить приём',
                );
              }
              return _dayBody(list, today);
            },
          ),
        ],
      ),
    );
  }

  Widget _dayBody(List<DayIntake> list, DateTime today) {
    final done = list.where((i) => i.taken).length;
    final groups = <_Period, List<DayIntake>>{};
    for (final i in list) {
      groups.putIfAbsent(_Period.of(i.minuteOfDay), () => []).add(i);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PlanCard(done: done, total: list.length),
        for (final p in _Period.values)
          if (groups[p] case final items?) ...[
            _PeriodHeader(period: p, intakes: items),
            for (final i in items) _card(i, today),
          ],
        const SizedBox(height: AppSpacing.md),
        _TipCard(
          tip: _tips[_day.difference(DateTime(2020)).inDays % _tips.length],
        ),
      ],
    );
  }

  Widget _card(DayIntake i, DateTime today) {
    final highlighted =
        _highlight?.scheduleId == i.schedule.id &&
        _highlight?.minuteOfDay == i.minuteOfDay;
    return Padding(
      key: highlighted ? _highlightKey : null,
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: _IntakeCard(
        intake: i,
        highlighted: highlighted,
        // Marking a future dose as taken makes no sense.
        canMark: !_day.isAfter(today),
        // Only the live version of a schedule can be changed; earlier ones
        // are history.
        manageable: isCurrent(i.schedule, today),
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AddIntakeScreen(editing: i.schedule),
          ),
        ),
        onEnd: () => confirmEndSchedule(context, ref, i.schedule),
        onTake: () => _take(i),
        onSkip: () => _skip(i),
        onReset: () => _reset(i),
      ),
    );
  }
}

enum _Period {
  morning('Утро', Icons.wb_sunny_outlined),
  day('День', Icons.restaurant_outlined),
  evening('Вечер', Icons.nightlight_outlined),
  anytime('В течение дня', Icons.schedule);

  const _Period(this.label, this.icon);
  final String label;
  final IconData icon;

  static _Period of(int? minute) => switch (minute) {
    null => anytime,
    < 12 * 60 => morning,
    < 18 * 60 => day,
    _ => evening,
  };
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({required this.period, required this.intakes});

  final _Period period;
  final List<DayIntake> intakes;

  @override
  Widget build(BuildContext context) {
    final all = intakes.every((i) => i.status != IntakeStatus.pending);
    final first = intakes.first.minuteOfDay;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Builder(
        builder: (context) {
          final title = Semantics(
            header: true,
            child: Text(
              first == null
                  ? period.label
                  : '${period.label}  ${formatMinute(first)}',
              style: AppType.cardTitle,
            ),
          );
          final badge = StatusBadge(
            label: all ? 'Выполнено' : 'Ожидает',
            icon: all ? Icons.check_circle : Icons.schedule,
            tone: all ? StatusTone.success : StatusTone.accent,
          );
          final large = MediaQuery.textScalerOf(context).scale(1) > 1.5;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(period.icon, size: 20, color: AppColors.warning),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                // Beside the title while it fits, under it at large text.
                child: large
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [title, badge],
                      )
                    : title,
              ),
              if (!large) badge,
            ],
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final left = total - done;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ПЛАН ДНЯ',
                  style: AppType.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Text('$done из $total принято', style: AppType.title),
                Text(
                  left == 0
                      ? 'Всё принято — отличный день!'
                      : 'Осталось принять: $left',
                  style: AppType.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ProgressRing(
            value: done / total,
            child: Text(
              '${(done * 100 / total).round()}%',
              style: AppType.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.tint,
          child: MascotPill(size: 36),
        ),
        const SizedBox(width: AppSpacing.ms),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Пилюлькин шепчет:', style: AppType.label),
              Text(tip, style: AppType.caption),
            ],
          ),
        ),
      ],
    ),
  );
}

/// One intake: a card tinted by its state, with the actions it still allows.
class _IntakeCard extends StatelessWidget {
  const _IntakeCard({
    required this.intake,
    required this.highlighted,
    required this.canMark,
    required this.manageable,
    required this.onEdit,
    required this.onEnd,
    required this.onTake,
    required this.onSkip,
    required this.onReset,
  });

  final DayIntake intake;
  final bool highlighted;
  final bool canMark;
  final bool manageable;
  final VoidCallback onEdit;
  final VoidCallback onEnd;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  String get _subtitle => [
    '${formatQuantity(intake.schedule.dose)} ${intake.schedule.doseUnit}',
    if (intake.medicineForm != null) intake.medicineForm!.label,
    if (intake.medicineStrength != null) intake.medicineStrength!,
  ].join(' · ');

  Widget _menu() => PopupMenuButton<VoidCallback>(
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
  );

  @override
  Widget build(BuildContext context) {
    final taken = intake.taken;
    final pending = intake.status == IntakeStatus.pending;
    return AppCard(
      variant: highlighted
          ? AppCardVariant.highlighted
          : taken
          ? AppCardVariant.done
          : pending
          ? AppCardVariant.normal
          : AppCardVariant.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicineAvatar(form: intake.medicineForm),
              const SizedBox(width: AppSpacing.ms),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intake.medicineName,
                      style: AppType.cardTitle.copyWith(
                        decoration: intake.skipped
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      _subtitle,
                      style: AppType.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (intake.skipped) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _statusBadge(intake.status),
                    ],
                  ],
                ),
              ),
              if (taken)
                IconButton.filled(
                  tooltip: intake.canReset ? 'Отменить отметку' : 'Принято',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.success,
                    disabledForegroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check),
                  onPressed: intake.canReset ? onReset : null,
                )
              else if (intake.skipped && intake.canReset)
                IconButton(
                  tooltip: 'Отменить отметку',
                  icon: const Icon(Icons.undo),
                  onPressed: onReset,
                ),
              _menu(),
            ],
          ),
          if (pending) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  onPressed: canMark ? onSkip : null,
                  child: const Text('Пропустить'),
                ),
                FilledButton.icon(
                  onPressed: canMark ? onTake : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Принять'),
                ),
              ],
            ),
          ],
        ],
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
