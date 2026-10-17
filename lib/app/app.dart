import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../design_system/theme.dart';
import '../features/inventory/inventory_screen.dart';

class PilloryApp extends StatelessWidget {
  const PilloryApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Pillory',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    // Russian UI; the delegates are also what makes the date picker work.
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const InventoryScreen(),
  );
}
