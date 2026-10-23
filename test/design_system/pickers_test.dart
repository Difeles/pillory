import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/l10n/l10n.dart';
import 'package:pillory/design_system/pickers.dart';

void main() {
  Future<void> open(WidgetTester tester, TargetPlatform p, bool time) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: supportedAppLocales,
        localizationsDelegates: appLocalizationsDelegates,
        theme: ThemeData(platform: p),
        home: Builder(
          builder: (c) => TextButton(
            onPressed: () => time
                ? pickTime(c, initial: const TimeOfDay(hour: 9, minute: 0))
                : pickDate(
                    c,
                    initial: DateTime(2030, 5, 10),
                    first: DateTime(2000),
                    last: DateTime(2100),
                  ),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  testWidgets('iOS gets the same own pickers', (tester) async {
    await open(tester, TargetPlatform.iOS, false);
    expect(find.byType(CupertinoDatePicker), findsNothing);
    expect(find.text('Май 2030'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    await open(tester, TargetPlatform.iOS, true);
    expect(find.text('Выберите время'), findsOneWidget);
  });

  testWidgets('Android gets the own calendar and time wheels', (tester) async {
    await open(tester, TargetPlatform.android, false);
    expect(find.byType(CupertinoDatePicker), findsNothing);
    expect(find.text('Май 2030'), findsOneWidget);
    await tester.tap(find.byTooltip('Следующий месяц'));
    await tester.pumpAndSettle();
    expect(find.text('Июнь 2030'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    await open(tester, TargetPlatform.android, true);
    expect(find.text('Выберите время'), findsOneWidget);
    expect(find.text('09'), findsWidgets);
  });

  testWidgets('time wheels are adjustable for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester, TargetPlatform.android, true);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Часы')),
      matchesSemantics(
        label: 'Часы',
        value: '09',
        increasedValue: '10',
        decreasedValue: '08',
        hasIncreaseAction: true,
        hasDecreaseAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('calendar days read as full dates', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester, TargetPlatform.android, false);
    expect(find.bySemanticsLabel('10 мая 2030'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the sheet can be swiped away', (tester) async {
    await open(tester, TargetPlatform.android, false);
    await tester.drag(find.text('Выберите дату'), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('Выберите дату'), findsNothing);
  });
}
