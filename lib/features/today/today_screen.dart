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
import '../inventory/take_now.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/reminders.dart';
import '../../domain/schedule.dart';
import '../../domain/streak.dart';
import '../../domain/supply.dart' show EndingCourse;
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../inventory/medicine_card.dart';
import 'add_intake_screen.dart';
import 'history_screen.dart';
import 'today_providers.dart';
import '../../design_system/motion.dart';
import '../../design_system/pickers.dart';

/// "20 октября" / "October 20".
String formatDay(BuildContext context, DateTime d) => context.dayMonth(d);

List<String> _tips(AppLocalizations l) => [l.tip1, l.tip2, l.tip3, l.tip4];

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
        duration: reduceMotion(context) ? Duration.zero : AppMotion.base,
        curve: AppMotion.curve,
      );
    });
  }

  void _select(DateTime day) => setState(() {
    _day = dateOnly(day);
    _highlight = null;
  });

  Future<void> _pickDay() async {
    final picked = await pickDate(
      context,
      initial: _day,
      first: DateTime(2020),
      last: DateTime(2100),
    );
    if (picked != null) _select(picked);
  }

  Future<void> _take(DayIntake i) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l10n;
    try {
      await ref
          .read(scheduleRepositoryProvider)
          .markTaken(
            scheduleId: i.schedule.id,
            day: _day,
            minuteOfDay: i.minuteOfDay,
          );
    } on InsufficientStockException {
      messenger.showSnackBar(SnackBar(content: Text(l.notEnoughStock)));
      return;
    }
    final prefs = ref.read(prefsProvider).value ?? const AppPrefs();
    if (prefs.haptics) unawaited(HapticFeedback.mediumImpact());
    if (prefs.confetti && mounted) showConfetti(context);
  }

  /// Asks for how long, then continues the course: the running schedule is
  /// closed and carried on to the new end date.
  Future<void> _extend(EndingCourse c) async {
    final l = context.l10n;
    final days = await showDialog<int>(
      context: context,
      builder: (d) => SimpleDialog(
        title: Text(l.extendCourseTitle(c.medicineName)),
        children: [
          for (final n in const [7, 14, 30])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(d, n),
              child: Text(l.extendDays(n)),
            ),
        ],
      ),
    );
    if (days == null) return;
    final s = c.schedule;
    final end = dateOnly(s.endDate!);
    await ref
        .read(scheduleRepositoryProvider)
        .updateSchedule(
          s.id,
          ScheduleEdit(
            kind: s.kind,
            dose: s.dose,
            times: s.times,
            weekdays: s.weekdays,
            dates: s.dates,
            startDate: s.startDate,
            endDate: DateTime(end.year, end.month, end.day + days),
            mealRelation: s.mealRelation,
          ),
        );
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
        title: context.l10n.tabToday,
        actions: [
          TopBarAddButton(
            tooltip: context.l10n.addIntake,
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
                    '${context.monthName(_day)}, ${_day.year}',
                    style: AppType.title,
                  ),
                ),
              ),
              Pressable(
                scale: .88,
                child: IconButton(
                  tooltip: context.l10n.historyTooltip,
                  icon: const Icon(Icons.history),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HistoryScreen(),
                    ),
                  ),
                ),
              ),
              Pressable(
                scale: .88,
                child: IconButton(
                  tooltip: context.l10n.wholeMonth,
                  icon: const Icon(Icons.calendar_month_outlined),
                  onPressed: _pickDay,
                ),
              ),
            ],
          ),
          WeekStrip(
            selected: _day,
            done: (d) => dayComplete(history?[d]),
            onSelected: _select,
          ),
          const SizedBox(height: AppSpacing.md),
          Pressable(
            child: OutlinedButton.icon(
              onPressed: () => pickAndTakeNow(context, ref),
              icon: const Icon(Icons.add_task),
              label: Text(context.l10n.takeOutsideSchedule),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          intakes.when(
            loading: () => const LoadingState(),
            error: (e, _) => ErrorState(
              message: context.l10n.loadIntakesFailed,
              onRetry: () => ref.invalidate(dayIntakesProvider(_day)),
            ),
            data: (list) {
              if (_scrollPending) _scrollToHighlight();
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.event_available,
                  title: context.l10n.noIntakesTitle,
                  message: context.l10n.noIntakesText,
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
    // One prominent action per view: only the next dose is a filled button.
    final next = list
        .where((i) => i.status == IntakeStatus.pending)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in ref.watch(endingCoursesProvider).value ?? const [])
          if (_day == dateOnly(DateTime.now()))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Row(
                  children: [
                    Icon(Icons.event_available, color: context.colors.warning),
                    const SizedBox(width: AppSpacing.ms),
                    Expanded(
                      child: Text(
                        c.endsOn == dateOnly(DateTime.now())
                            ? context.l10n.courseLastDay(c.medicineName)
                            : context.l10n.courseEnds(
                                c.medicineName,
                                formatDay(context, c.endsOn),
                              ),
                      ),
                    ),
                    Pressable(
                      child: TextButton(
                        onPressed: () => _extend(c),
                        child: Text(context.l10n.extendCourse),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        _PlanCard(done: done, total: list.length),
        for (final p in _Period.values)
          if (groups[p] case final items?) ...[
            _PeriodHeader(period: p, intakes: items),
            for (final i in items)
              _card(i, today, prominent: identical(i, next)),
          ],
        const SizedBox(height: AppSpacing.md),
        _TipCard(
          tip: _tips(context.l10n)[_day.difference(DateTime(2020)).inDays % 4],
        ),
      ],
    );
  }

  Widget _card(DayIntake i, DateTime today, {required bool prominent}) {
    final highlighted =
        _highlight?.scheduleId == i.schedule.id &&
        _highlight?.minuteOfDay == i.minuteOfDay;
    return Padding(
      key: highlighted ? _highlightKey : null,
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: _IntakeCard(
        intake: i,
        highlighted: highlighted,
        prominent: prominent || highlighted,
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
        onDelete: () => confirmDeleteSchedule(context, ref, i.schedule),
        onTake: () => _take(i),
        onSkip: () => _skip(i),
        onReset: () => _reset(i),
      ),
    );
  }
}

enum _Period {
  morning(Icons.wb_sunny_outlined),
  day(Icons.restaurant_outlined),
  evening(Icons.nightlight_outlined),
  anytime(Icons.schedule);

  const _Period(this.icon);
  final IconData icon;

  String label(AppLocalizations l) => switch (this) {
    morning => l.periodMorning,
    day => l.periodDay,
    evening => l.periodEvening,
    anytime => l.periodAnytime,
  };

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
                  ? period.label(context.l10n)
                  : '${period.label(context.l10n)}  ${formatMinute(first)}',
              style: AppType.cardTitle,
            ),
          );
          final badge = StatusBadge(
            label: all ? context.l10n.periodDone : context.l10n.periodWaiting,
            icon: all ? Icons.check_circle : Icons.schedule,
            tone: all ? StatusTone.success : StatusTone.accent,
          );
          final large = MediaQuery.textScalerOf(context).scale(1) > 1.5;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  period.icon,
                  size: 20,
                  color: context.colors.warning,
                ),
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
                  context.l10n.planOverline,
                  style: AppType.overline.copyWith(
                    color: context.colors.primary,
                  ),
                ),
                Text(
                  context.l10n.takenOfTotal(done, total),
                  style: AppType.title,
                ),
                Text(
                  left == 0
                      ? context.l10n.allTaken
                      : context.l10n.leftToTake(left),
                  style: AppType.caption.copyWith(
                    color: context.colors.textSecondary,
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
        CircleAvatar(
          radius: 28,
          backgroundColor: context.colors.tint,
          child: MascotPill(size: 36),
        ),
        const SizedBox(width: AppSpacing.ms),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.whisper, style: AppType.label),
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
    required this.prominent,
    required this.canMark,
    required this.manageable,
    required this.onEdit,
    required this.onEnd,
    required this.onDelete,
    required this.onTake,
    required this.onSkip,
    required this.onReset,
  });

  final DayIntake intake;
  final bool highlighted;
  final bool prominent;
  final bool canMark;
  final bool manageable;
  final VoidCallback onEdit;
  final VoidCallback onEnd;
  final VoidCallback onDelete;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  String _subtitle(AppLocalizations l) => [
    l.quantity(intake.schedule.dose, intake.schedule.doseUnit),
    if (intake.medicineForm != null) l.form(intake.medicineForm!),
    if (intake.medicineStrength != null) intake.medicineStrength!,
  ].join(' · ');

  Widget _menu(BuildContext context) => Pressable(
    scale: .88,
    child: PopupMenuButton<VoidCallback>(
      tooltip: context.l10n.manageSchedule,
      onSelected: (action) => action(),
      itemBuilder: (_) => manageable
          ? [
              PopupMenuItem(
                value: onEdit,
                child: Text(context.l10n.editSchedule),
              ),
              PopupMenuItem(
                value: onEnd,
                child: Text(context.l10n.endScheduleItem),
              ),
              PopupMenuItem(
                value: onDelete,
                child: Text(
                  context.l10n.deleteScheduleItem,
                  style: TextStyle(color: context.colors.danger),
                ),
              ),
            ]
          : [
              PopupMenuItem(
                enabled: false,
                child: Text(context.l10n.scheduleAlreadyChanged),
              ),
            ],
    ),
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
              MedicineAvatar(
                form: intake.medicineForm,
                look: intake.medicineLook,
              ),
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
                      _subtitle(context.l10n),
                      style: AppType.caption.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    if (intake.skipped) ...[
                      const SizedBox(height: AppSpacing.xs),
                      _statusBadge(context, intake.status),
                    ],
                  ],
                ),
              ),
              if (taken)
                Pressable(
                  scale: .88,
                  child: IconButton.filled(
                    tooltip: intake.canReset
                        ? context.l10n.cancelMark
                        : context.l10n.statusTaken,
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.success,
                      foregroundColor: context.colors.onSuccess,
                      disabledBackgroundColor: context.colors.success,
                      disabledForegroundColor: context.colors.onSuccess,
                    ),
                    icon: const Icon(Icons.check),
                    onPressed: intake.canReset ? onReset : null,
                  ),
                )
              else if (intake.skipped && intake.canReset)
                Pressable(
                  scale: .88,
                  child: IconButton(
                    tooltip: context.l10n.cancelMark,
                    icon: const Icon(Icons.undo),
                    onPressed: onReset,
                  ),
                ),
              _menu(context),
            ],
          ),
          if (pending) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                Pressable(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.textSecondary,
                    ),
                    onPressed: canMark ? onSkip : null,
                    child: Text(context.l10n.skip),
                  ),
                ),
                Pressable(
                  child: prominent
                      ? FilledButton.icon(
                          onPressed: canMark ? onTake : null,
                          icon: const Icon(Icons.check),
                          label: Text(context.l10n.take),
                        )
                      : FilledButton.tonalIcon(
                          onPressed: canMark ? onTake : null,
                          icon: const Icon(Icons.check),
                          label: Text(context.l10n.take),
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

Widget _statusBadge(BuildContext context, IntakeStatus status) =>
    switch (status) {
      IntakeStatus.taken => StatusBadge(
        label: context.l10n.statusTaken,
        icon: Icons.check_circle,
        tone: StatusTone.success,
      ),
      IntakeStatus.skipped => StatusBadge(
        label: context.l10n.statusSkipped,
        icon: Icons.remove_circle_outline,
      ),
      IntakeStatus.pending => StatusBadge(
        label: context.l10n.statusUnmarked,
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
  final ends = context.l10n.endsTomorrow;
  final ok = await showConfirmDialog(
    context,
    title: context.l10n.endAskTitle,
    message: context.l10n.endAskText,
    confirmLabel: context.l10n.endConfirm,
    danger: true,
  );
  if (!ok) return false;
  final from = await ref.read(scheduleRepositoryProvider).endSchedule(s.id);
  if (from.isAfter(dateOnly(DateTime.now()))) {
    messenger.showSnackBar(SnackBar(content: Text(ends)));
  }
  return true;
}

/// Asks, then deletes [s] with its marks; returns whether it was deleted.
Future<bool> confirmDeleteSchedule(
  BuildContext context,
  WidgetRef ref,
  Schedule s,
) async {
  final l = context.l10n;
  final ok = await showConfirmDialog(
    context,
    title: l.deleteScheduleAskTitle,
    message: l.deleteScheduleAskText,
    confirmLabel: l.deleteConfirm,
    danger: true,
  );
  if (!ok) return false;
  await ref.read(scheduleRepositoryProvider).deleteSchedule(s.id);
  return true;
}

/// Icon and name of a mark; shared by the day and history screens.
Widget intakeStatusLabel(IntakeStatus status) => Builder(
  builder: (context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      switch (status) {
        IntakeStatus.taken => Icon(
          Icons.check_circle,
          color: context.colors.success,
        ),
        IntakeStatus.skipped => Icon(
          Icons.remove_circle_outline,
          color: context.colors.textSecondary,
        ),
        IntakeStatus.pending => Icon(
          Icons.radio_button_unchecked,
          color: context.colors.textSecondary,
        ),
      },
      const SizedBox(width: AppSpacing.xs),
      Text(switch (status) {
        IntakeStatus.taken => context.l10n.statusTaken,
        IntakeStatus.skipped => context.l10n.statusSkipped,
        IntakeStatus.pending => context.l10n.statusUnmarked,
      }),
    ],
  ),
);
