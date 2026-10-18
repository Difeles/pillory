import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/confirm_dialog.dart';
import '../../design_system/widgets/states.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../design_system/widgets/timeline.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/reminders.dart';
import '../../domain/schedule.dart';
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
          _scrollPending = true;
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
                    _dayCaption(_day, today).toUpperCase(),
                    style: _overline(text, AppColors.textSecondary),
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
              data: (list) {
                if (_scrollPending) _scrollToHighlight();
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_available,
                    title: 'На этот день приёмов нет',
                    message: 'Нажмите «+», чтобы добавить приём',
                  );
                }
                return _timeline(list, today);
              },
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

  Widget _timeline(List<DayIntake> list, DateTime today) {
    final now = DateTime.now();
    final nowMinute = now.hour * 60 + now.minute;
    // Only today has a "next", and a time already past is not next.
    final next = _day == today
        ? list
              .where(
                (i) =>
                    i.status == IntakeStatus.pending &&
                    i.minuteOfDay != null &&
                    i.minuteOfDay! >= nowMinute,
              )
              .firstOrNull
        : null;
    final timed = [
      for (final i in list)
        if (i.minuteOfDay != null) i,
    ];
    final untimed = [
      for (final i in list)
        if (i.minuteOfDay == null) i,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaler = MediaQuery.textScalerOf(context);
        final timeWidth = scaler.scale(AppSizes.timelineTime);
        // The time gets its own column only while the content keeps a
        // readable width; otherwise it moves above the name.
        final wide =
            constraints.maxWidth - timeWidth - AppSizes.timelineRail >=
            scaler.scale(220);
        Widget group(List<DayIntake> intakes) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (k, i) in intakes.indexed)
              _entry(
                i,
                today: today,
                isNext: identical(i, next),
                wide: wide,
                timeWidth: timeWidth,
                first: k == 0,
                last: k == intakes.length - 1,
              ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (timed.isNotEmpty) group(timed),
            if (untimed.isNotEmpty) ...[
              if (timed.isNotEmpty) const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.ms),
                child: Semantics(
                  header: true,
                  child: Text(
                    'В ТЕЧЕНИЕ ДНЯ',
                    style: _overline(
                      Theme.of(context).textTheme,
                      AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              group(untimed),
            ],
          ],
        );
      },
    );
  }

  Widget _entry(
    DayIntake i, {
    required DateTime today,
    required bool isNext,
    required bool wide,
    required double timeWidth,
    required bool first,
    required bool last,
  }) {
    final highlighted =
        _highlight?.scheduleId == i.schedule.id &&
        _highlight?.minuteOfDay == i.minuteOfDay;
    return _IntakeEntry(
      key: highlighted ? _highlightKey : null,
      intake: i,
      isNext: isNext,
      highlighted: highlighted,
      wide: wide,
      timeWidth: timeWidth,
      first: first,
      last: last,
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
    );
  }
}

TextStyle? _overline(TextTheme text, Color color) => text.labelMedium?.copyWith(
  color: color,
  fontWeight: FontWeight.w600,
  letterSpacing: 1,
);

/// One intake on the day's timeline: the next one as a card with full
/// actions, any other as a compact row.
class _IntakeEntry extends StatelessWidget {
  const _IntakeEntry({
    super.key,
    required this.intake,
    required this.isNext,
    required this.highlighted,
    required this.wide,
    required this.timeWidth,
    required this.first,
    required this.last,
    required this.canMark,
    required this.manageable,
    required this.onEdit,
    required this.onEnd,
    required this.onTake,
    required this.onSkip,
    required this.onReset,
  });

  final DayIntake intake;
  final bool isNext;
  final bool highlighted;

  /// Whether the time has a column of its own beside the rail.
  final bool wide;
  final double timeWidth;
  final bool first;
  final bool last;
  final bool canMark;
  final bool manageable;
  final VoidCallback onEdit;
  final VoidCallback onEnd;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  bool get _done => intake.status != IntakeStatus.pending;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    final minute = intake.minuteOfDay;
    final time = minute == null ? null : formatMinute(minute);
    final carded = isNext || highlighted;
    // The first line sits this far down: the card's padding, if any.
    final top = carded ? AppSpacing.md : 0.0;
    final content = isNext ? _nextCard(context, time) : _row(context, time);
    return TimelineEntry(
      dot: switch (intake.status) {
        IntakeStatus.taken => TimelineDotState.done,
        IntakeStatus.skipped => TimelineDotState.skipped,
        IntakeStatus.pending =>
          isNext ? TimelineDotState.next : TimelineDotState.pending,
      },
      first: first,
      last: last,
      // Centred on the first line of text, which grows with the text scale.
      dotTop: top + scaler.scale(AppSpacing.ms),
      leadingWidth: wide ? timeWidth : 0,
      leading: wide && time != null
          ? Padding(
              padding: EdgeInsets.only(top: top),
              child: Text(time, style: _timeStyle(text.titleMedium)),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: !isNext && highlighted
            ? AppCard(variant: AppCardVariant.highlighted, child: content)
            : content,
      ),
    );
  }

  TextStyle? _timeStyle(TextStyle? base) => base?.copyWith(
    fontFeatures: AppType.numeric.fontFeatures,
    color: isNext
        ? AppColors.primaryDeep
        : _done
        ? AppColors.textSecondary
        : AppColors.textPrimary,
  );

  String? get _details {
    final parts = [
      if (intake.medicineForm != null) intake.medicineForm!.label,
      if (intake.medicineStrength != null) intake.medicineStrength!,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String get _dose =>
      '${formatQuantity(intake.schedule.dose)} ${intake.schedule.doseUnit}';

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

  Widget _row(BuildContext context, String? time) {
    final text = Theme.of(context).textTheme;
    final details = _details;
    final actions = _done
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
            IconButton.filledTonal(
              tooltip: 'Пропустить',
              icon: const Icon(Icons.skip_next),
              onPressed: canMark ? onSkip : null,
            ),
            IconButton.filled(
              tooltip: 'Принято',
              icon: const Icon(Icons.check),
              onPressed: canMark ? onTake : null,
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!wide && time != null)
                    Text(time, style: _timeStyle(text.titleSmall)),
                  Text(
                    intake.medicineName,
                    style: text.titleMedium?.copyWith(
                      color: _done ? AppColors.textSecondary : null,
                      decoration: intake.skipped
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (details != null)
                    Text(
                      details,
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            _menu(),
          ],
        ),
        // Wraps instead of overflowing: with large text the actions move
        // under the dose.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: AppSpacing.xs,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Text(
                _dose,
                style: text.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions,
            ),
          ],
        ),
      ],
    );
  }

  Widget _nextCard(BuildContext context, String? time) {
    final text = Theme.of(context).textTheme;
    final details = _details;
    return AppCard(
      variant: highlighted ? AppCardVariant.highlighted : AppCardVariant.normal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // Narrow: the time has no column, so it leads the card.
                  wide || time == null ? 'СЛЕДУЮЩИЙ' : 'СЛЕДУЮЩИЙ · $time',
                  style: _overline(text, AppColors.primaryDeep),
                ),
              ),
              _menu(),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MedicineAvatar(form: intake.medicineForm),
              const SizedBox(width: AppSpacing.ms),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(intake.medicineName, style: text.titleLarge),
                    if (details != null)
                      Text(
                        details,
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    Text(_dose, style: text.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.ms),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.tonal(
                onPressed: canMark ? onSkip : null,
                child: const Text('Пропустить'),
              ),
              FilledButton(
                onPressed: canMark ? onTake : null,
                child: const Text('Принято'),
              ),
            ],
          ),
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
