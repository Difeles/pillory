import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../design_system/theme.dart';
import 'home_shell.dart';

class PilloryApp extends StatelessWidget {
  const PilloryApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pillory',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    // iPhone-style scrolling on every platform: rubber-band edges, no glow.
    scrollBehavior: const _BounceScroll(),
    // A tap on empty space puts the keyboard away and drops the focus.
    builder: (context, child) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    ),
    // Russian UI; the delegates are also what makes the date picker work.
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const HomeShell(),
  );
}

class _BounceScroll extends MaterialScrollBehavior {
  const _BounceScroll();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
