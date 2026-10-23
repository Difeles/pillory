import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/app/providers.dart';
import 'package:pillory/features/cycle/cycle_screen.dart';
import 'package:pillory/l10n/l10n.dart';

import '../support/fake_cycle_repository.dart';

void main() {
  testWidgets('days are logged and the cycle is worked out', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FakeCycleRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cycleRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: supportedAppLocales,
          localizationsDelegates: appLocalizationsDelegates,
          home: const CycleScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Отметьте дни месячных'), findsOneWidget);

    await tester.tap(find.text('Месячные идут сегодня'));
    await tester.pumpAndSettle();
    expect(find.text('День цикла 1'), findsOneWidget);
    expect(find.textContaining('Следующие месячные'), findsOneWidget);
    expect(find.text('Снять отметку с сегодняшнего дня'), findsOneWidget);

    await tester.tap(find.text('Снять отметку с сегодняшнего дня'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Отметьте дни месячных'), findsOneWidget);
  });
}
