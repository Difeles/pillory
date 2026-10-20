import 'package:flutter/material.dart';

import 'motion.dart';
import 'tokens.dart';

const _months = [
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
];
const _monthsOf = [
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
];
const _weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// A date, in Pillory's own calendar sheet (the same on every platform).
Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initial,
  required DateTime first,
  required DateTime last,
  String title = 'Дата',
}) {
  final f = _day(first), l = _day(last);
  var i = _day(initial);
  if (i.isBefore(f)) i = f;
  if (i.isAfter(l)) i = l;
  return _show<DateTime>(
    context,
    title,
    (done) => _CalendarSheet(initial: i, first: f, last: l, onDone: done),
  );
}

/// A time of day, on two own wheels (the same on every platform).
Future<TimeOfDay?> pickTime(
  BuildContext context, {
  required TimeOfDay initial,
  String title = 'Время',
}) async {
  final r = await _show<DateTime>(
    context,
    title,
    (done) => _TimeSheet(initial: initial, onDone: done),
  );
  return r == null ? null : TimeOfDay(hour: r.hour, minute: r.minute);
}

Future<T?> _show<T>(
  BuildContext context,
  String title,
  Widget Function(ValueChanged<T?> done) build,
) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Закрыть',
    barrierColor: Colors.black38,
    transitionDuration: motionOf(context, AppMotion.tab),
    pageBuilder: (c, _, _) => Align(
      alignment: Alignment.bottomCenter,
      child: build((v) => Navigator.pop(c, v)),
    ),
    transitionBuilder: (c, a, _, child) => SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(
          parent: a,
          curve: AppMotion.smooth,
          reverseCurve: Curves.easeInCubic,
        ),
      ),
      child: child,
    ),
  );
}

/// The rounded sheet around a picker: handle, title, cancel and confirm.
class _Sheet extends StatefulWidget {
  const _Sheet({
    required this.title,
    required this.child,
    required this.onOk,
    required this.onCancel,
  });

  final String title;
  final Widget child;
  final VoidCallback onOk;
  final VoidCallback onCancel;

  @override
  State<_Sheet> createState() => _SheetState();
}

class _SheetState extends State<_Sheet> {
  double _dy = 0;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) => Semantics(
    onDismiss: widget.onCancel,
    child: AnimatedContainer(
      duration: _dragging
          ? Duration.zero
          : motionOf(context, AppMotion.release),
      curve: AppMotion.spring,
      transform: Matrix4.translationValues(0, _dy, 0),
      child: _body(context),
    ),
  );

  Widget _body(BuildContext context) => Material(
    color: context.colors.surface,
    shape: const RoundedSuperellipseBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
    ),
    clipBehavior: Clip.antiAlias,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.ms,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Only the header drags the sheet away: the body scrolls.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => setState(() => _dragging = true),
              onVerticalDragUpdate: (d) => setState(
                () => _dy = (_dy + d.delta.dy).clamp(0, double.infinity),
              ),
              onVerticalDragEnd: (d) {
                if (_dy > 80 || (d.primaryVelocity ?? 0) > 700) {
                  widget.onCancel();
                } else {
                  setState(() {
                    _dragging = false;
                    _dy = 0;
                  });
                }
              },
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: ShapeDecoration(
                      shape: StadiumBorder(),
                      color: context.colors.divider,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(widget.title, style: AppType.title),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            widget.child,
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Pressable(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Отмена'),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Pressable(
                    child: FilledButton(
                      onPressed: widget.onOk,
                      child: const Text('Готово'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _CalendarSheet extends StatefulWidget {
  const _CalendarSheet({
    required this.initial,
    required this.first,
    required this.last,
    required this.onDone,
  });

  final DateTime initial;
  final DateTime first;
  final DateTime last;
  final ValueChanged<DateTime?> onDone;

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _month = DateTime(widget.initial.year, widget.initial.month);
  late DateTime _selected = widget.initial;
  double _dir = 1;

  bool _has(DateTime month) =>
      !DateTime(month.year, month.month + 1, 0).isBefore(widget.first) &&
      !month.isAfter(widget.last);

  void _go(int by) {
    final m = DateTime(_month.year, _month.month + by);
    if (!_has(m)) return;
    setState(() {
      _dir = by.toDouble();
      _month = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = '${_months[_month.month - 1]} ${_month.year}';
    return _Sheet(
      title: 'Выберите дату',
      onOk: () => widget.onDone(_selected),
      onCancel: () => widget.onDone(null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v.abs() > 200) _go(v < 0 ? 1 : -1);
        },
        child: Column(
          children: [
            Row(
              children: [
                _Arrow(
                  icon: Icons.chevron_left,
                  tooltip: 'Предыдущий месяц',
                  onTap: _has(DateTime(_month.year, _month.month - 1))
                      ? () => _go(-1)
                      : null,
                ),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppType.cardTitle,
                  ),
                ),
                _Arrow(
                  icon: Icons.chevron_right,
                  tooltip: 'Следующий месяц',
                  onTap: _has(DateTime(_month.year, _month.month + 1))
                      ? () => _go(1)
                      : null,
                ),
              ],
            ),
            Row(
              children: [
                for (final d in _weekdays)
                  Expanded(
                    child: Center(child: Text(d, style: AppType.captionStrong)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRect(
              child: AnimatedSwitcher(
                duration: motionOf(context, AppMotion.tab),
                switchInCurve: AppMotion.smooth,
                transitionBuilder: (child, a) => SlideTransition(
                  position: Tween(
                    begin: Offset(.3 * _dir, 0),
                    end: Offset.zero,
                  ).animate(a),
                  child: FadeTransition(opacity: a, child: child),
                ),
                child: _grid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid() {
    final lead = _month.weekday - 1;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final today = _day(DateTime.now());
    return Column(
      key: ValueKey(_month),
      children: [
        for (var r = 0; r < 6; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(child: _cell(r * 7 + c - lead + 1, days, today)),
            ],
          ),
      ],
    );
  }

  Widget _cell(int n, int days, DateTime today) {
    if (n < 1 || n > days) return const SizedBox(height: 44);
    final date = DateTime(_month.year, _month.month, n);
    final enabled = !date.isBefore(widget.first) && !date.isAfter(widget.last);
    final selected = date == _selected;
    final fg = selected
        ? context.colors.onPrimary
        : enabled
        ? context.colors.textPrimary
        : context.colors.inputBorder.withValues(alpha: .78);
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      // The full date, so a screen reader does not just say "20".
      label: '$n ${_monthsOf[_month.month - 1]} ${_month.year}',
      excludeSemantics: true,
      child: Pressable(
        scale: .85,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => setState(() => _selected = date) : null,
          child: SizedBox(
            height: 44,
            child: Center(
              child: AnimatedContainer(
                duration: motionOf(context, AppMotion.base),
                curve: AppMotion.smooth,
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  shape: CircleBorder(
                    side: date == today && !selected
                        ? BorderSide(color: context.colors.primary)
                        : BorderSide.none,
                  ),
                  color: selected ? context.colors.primary : Colors.transparent,
                ),
                child: Text('$n', style: AppType.label.copyWith(color: fg)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    scale: .85,
    child: IconButton(tooltip: tooltip, onPressed: onTap, icon: Icon(icon)),
  );
}

class _TimeSheet extends StatefulWidget {
  const _TimeSheet({required this.initial, required this.onDone});

  final TimeOfDay initial;
  final ValueChanged<DateTime?> onDone;

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  late int _h = widget.initial.hour;
  late int _m = widget.initial.minute;

  @override
  Widget build(BuildContext context) => _Sheet(
    title: 'Выберите время',
    onOk: () => widget.onDone(DateTime(2000, 1, 1, _h, _m)),
    onCancel: () => widget.onDone(null),
    child: SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The band behind the selected row.
          Container(
            height: 48,
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: context.colors.tint.withValues(alpha: .7),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _Wheel(
                  label: 'Часы',
                  count: 24,
                  initial: _h,
                  onChanged: (v) => _h = v,
                ),
              ),
              Text(':', style: AppType.wheel),
              Expanded(
                child: _Wheel(
                  label: 'Минуты',
                  count: 60,
                  initial: _m,
                  onChanged: (v) => _m = v,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Wheel extends StatefulWidget {
  const _Wheel({
    required this.label,
    required this.count,
    required this.initial,
    required this.onChanged,
  });

  final String label;
  final int count;
  final int initial;
  final ValueChanged<int> onChanged;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final _c = FixedExtentScrollController(initialItem: widget.initial);
  late int _v = widget.initial;

  String _text(int v) => (v % widget.count).toString().padLeft(2, '0');

  void _step(int by) {
    final to = _c.selectedItem + by;
    reduceMotion(context)
        ? _c.jumpToItem(to)
        : _c.animateToItem(
            to,
            duration: AppMotion.base,
            curve: AppMotion.smooth,
          );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    // One adjustable node (swipe up / down), instead of 24 loose numbers.
    label: widget.label,
    value: _text(_v),
    increasedValue: _text(_v + 1),
    decreasedValue: _text(_v - 1 + widget.count),
    onIncrease: () => _step(1),
    onDecrease: () => _step(-1),
    child: ExcludeSemantics(
      child: ListWheelScrollView.useDelegate(
        controller: _c,
        itemExtent: 48,
        diameterRatio: 1.6,
        perspective: .003,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (i) {
          final v = i % widget.count;
          setState(() => _v = v);
          widget.onChanged(v);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: [
            for (var i = 0; i < widget.count; i++)
              Center(child: Text(_text(i), style: AppType.wheel)),
          ],
        ),
      ),
    ),
  );
}
