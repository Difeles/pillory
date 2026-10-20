import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/theme.dart';
import '../domain/extras.dart';
import 'home_shell.dart';
import 'providers.dart';

class PilloryApp extends ConsumerWidget {
  const PilloryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: 'PillPal',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    darkTheme: buildAppTheme(Brightness.dark),
    themeMode: switch (ref.watch(prefsProvider).value?.appearance) {
      Appearance.light => ThemeMode.light,
      Appearance.dark => ThemeMode.dark,
      _ => ThemeMode.system,
    },
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
