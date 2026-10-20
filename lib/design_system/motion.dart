import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'tokens.dart';

/// Shrinks its child while a finger is down on it, then springs back. It
/// only listens to the pointer, so the button inside keeps its own tap.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.scale = .95});

  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  Offset _start = Offset.zero;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Listener(
      onPointerDown: (e) {
        _start = e.localPosition;
        _set(true);
      },
      // A scroll or drag is not a press.
      onPointerMove: (e) {
        if ((e.localPosition - _start).distance > 12) _set(false);
      },
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !still ? widget.scale : 1,
        duration: _down ? AppMotion.press : AppMotion.release,
        curve: _down ? Curves.easeOut : AppMotion.spring,
        child: widget.child,
      ),
    );
  }
}

/// Keeps every tab alive (like IndexedStack) and glides between them: the
/// new tab slides in from the side it lies on while the old one fades out.
class TabStack extends StatefulWidget {
  const TabStack({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<TabStack> createState() => _TabStackState();
}

class _TabStackState extends State<TabStack>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: AppMotion.tab);
  late int _from = widget.index;
  late int _to = widget.index;
  // The panes switch between a Stack (mid-glide) and an IndexedStack (idle);
  // global keys carry their state across.
  late final _keys = List.generate(widget.children.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(TabStack old) {
    super.didUpdateWidget(old);
    if (widget.index == _to) return;
    _from = _to;
    _to = widget.index;
    if (MediaQuery.disableAnimationsOf(context)) {
      _from = _to;
      _c.value = 1;
    } else {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dir = _to >= _from ? 1.0 : -1.0;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = AppMotion.smooth.transform(_c.value);
        // Idle: a plain IndexedStack, so only the current tab is on stage.
        if (!_c.isAnimating) {
          return IndexedStack(
            index: _to,
            children: [
              for (var i = 0; i < widget.children.length; i++)
                KeyedSubtree(key: _keys[i], child: widget.children[i]),
            ],
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < widget.children.length; i++) _pane(i, t, dir),
          ],
        );
      },
    );
  }

  Widget _pane(int i, double t, double dir) {
    final entering = i == _to;
    final leaving = i == _from;
    final visible = entering || leaving;
    final p = entering ? t : (leaving ? 1 - t : 0.0);
    // Enters from 28px away on its side; the old tab drifts 28px the other way.
    final dx = entering ? (1 - t) * 28 * dir : (leaving ? -t * 28 * dir : 0.0);
    return TickerMode(
      enabled: visible,
      child: ExcludeSemantics(
        excluding: !visible,
        // Only the tab you are going to takes touches.
        child: IgnorePointer(
          ignoring: !entering,
          child: Opacity(
            opacity: p.clamp(0.0, 1.0),
            child: Transform(
              transform: Matrix4.identity()
                ..translateByDouble(dx, 0, 0, 1)
                ..scaleByDouble(.98 + .02 * p, .98 + .02 * p, 1, 1),
              alignment: Alignment.center,
              child: KeyedSubtree(key: _keys[i], child: widget.children[i]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pages slide in from the right with a soft fade while the page below
/// drifts left and dims. iOS keeps its native route (it has swipe-back).
class _SlideFadeTransitions extends PageTransitionsBuilder {
  const _SlideFadeTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(
      parent: animation,
      curve: AppMotion.smooth,
      reverseCurve: Curves.easeInCubic,
    );
    final cover = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.smooth,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween(
        begin: Offset.zero,
        end: const Offset(-.12, 0),
      ).animate(cover),
      child: FadeTransition(
        opacity: Tween(begin: 1.0, end: .6).animate(cover),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(.22, 0),
            end: Offset.zero,
          ).animate(enter),
          child: FadeTransition(opacity: enter, child: child),
        ),
      ),
    );
  }
}

const appPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _SlideFadeTransitions(),
    TargetPlatform.fuchsia: _SlideFadeTransitions(),
    TargetPlatform.linux: _SlideFadeTransitions(),
    TargetPlatform.windows: _SlideFadeTransitions(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  },
);
