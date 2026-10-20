import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/design_system/theme.dart';
import 'package:pillory/design_system/tokens.dart';
import 'package:pillory/design_system/widgets/app_card.dart';
import 'package:pillory/design_system/widgets/confirm_dialog.dart';
import 'package:pillory/design_system/widgets/date_field.dart';
import 'package:pillory/design_system/widgets/quantity_stepper.dart';
import 'package:pillory/design_system/widgets/section_header.dart';
import 'package:pillory/design_system/widgets/states.dart';
import 'package:pillory/design_system/widgets/status_badge.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: child),
  ),
);

Color? _cardColor(WidgetTester tester) => tester
    .widget<Material>(
      find.descendant(
        of: find.byType(AppCard),
        matching: find.byType(Material),
      ),
    )
    .color;

void main() {
  testWidgets('AppCard: tappable card is a button; variants change surface', (
    tester,
  ) async {
    var taps = 0;
    await _pump(tester, AppCard(onTap: () => taps++, child: const Text('A')));
    await tester.tap(find.text('A'));
    expect(taps, 1);
    expect(
      tester.getSemantics(find.byType(AppCard)),
      matchesSemantics(
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
        label: 'A',
      ),
    );
    expect(_cardColor(tester), AppColors.surface);

    await _pump(
      tester,
      const AppCard(variant: AppCardVariant.muted, child: Text('A')),
    );
    expect(_cardColor(tester), AppColors.surfaceLow);

    await _pump(
      tester,
      const AppCard(variant: AppCardVariant.highlighted, child: Text('A')),
    );
    final shape =
        tester
                .widget<Material>(
                  find.descendant(
                    of: find.byType(AppCard),
                    matching: find.byType(Material),
                  ),
                )
                .shape!
            as RoundedSuperellipseBorder;
    expect(shape.side.color, AppColors.primary);
  });

  testWidgets('AppCard keeps inner buttons separately reachable', (
    tester,
  ) async {
    var inner = 0;
    var card = 0;
    await _pump(
      tester,
      AppCard(
        onTap: () => card++,
        child: Row(
          children: [
            const Expanded(child: Text('Аспирин')),
            FilledButton(
              onPressed: () => inner++,
              child: const Text('Принято'),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Принято'));
    expect((inner, card), (1, 0));
  });

  testWidgets('StatusBadge shows icon and text in the tone colour', (
    tester,
  ) async {
    await _pump(
      tester,
      const StatusBadge(
        label: 'Просрочено',
        icon: Icons.error_outline,
        tone: StatusTone.danger,
      ),
    );
    expect(find.text('Просрочено'), findsOneWidget);
    expect(tester.widget<Icon>(find.byType(Icon)).color, AppColors.danger);
    expect(
      tester.widget<Text>(find.text('Просрочено')).style?.color,
      AppColors.danger,
    );
  });

  testWidgets('EmptyState shows its action; ErrorState retries', (
    tester,
  ) async {
    await _pump(
      tester,
      EmptyState(
        icon: Icons.medication_outlined,
        title: 'В аптечке пока пусто',
        message: 'Добавьте первое лекарство',
        action: FilledButton(onPressed: () {}, child: const Text('Добавить')),
      ),
    );
    expect(find.text('В аптечке пока пусто'), findsOneWidget);
    expect(find.text('Добавьте первое лекарство'), findsOneWidget);
    expect(find.text('Добавить'), findsOneWidget);

    var retries = 0;
    await _pump(
      tester,
      ErrorState(message: 'Не удалось загрузить', onRetry: () => retries++),
    );
    await tester.tap(find.text('Повторить'));
    expect(retries, 1);
  });

  testWidgets('EmptyState also works inside a list', (tester) async {
    await _pump(
      tester,
      ListView(
        children: const [EmptyState(icon: Icons.add, title: 'Пусто')],
      ),
    );
    expect(find.text('Пусто'), findsOneWidget);
  });

  testWidgets('LoadingState is announced and still under reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: LoadingState()),
        ),
      ),
    );
    // Settles only if the pulse is not running.
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Загрузка'), findsOneWidget);
  });

  testWidgets('DateField picks, clears and can be disabled', (tester) async {
    DateTime? value;
    late StateSetter set;
    await _pump(
      tester,
      StatefulBuilder(
        builder: (_, s) {
          set = s;
          return DateField(
            label: 'Срок годности',
            value: value,
            initialDate: DateTime(2030, 5, 10),
            clearTooltip: 'Убрать срок годности',
            onChanged: (d) => set(() => value = d),
          );
        },
      ),
    );
    expect(find.text('Не указан'), findsOneWidget);

    await tester.tap(find.byType(DateField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(value, DateTime(2030, 5, 15));
    expect(find.text('15.05.2030'), findsOneWidget);

    await tester.tap(find.byTooltip('Убрать срок годности'));
    await tester.pump();
    expect(value, isNull);

    await _pump(
      tester,
      const DateField(label: 'Начало', value: null, onChanged: null),
    );
    await tester.tap(find.byType(DateField));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('showConfirmDialog returns the choice; danger is red', (
    tester,
  ) async {
    late BuildContext ctx;
    await _pump(
      tester,
      Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      ),
    );
    Future<bool> ask() => showConfirmDialog(
      ctx,
      title: 'Убрать в архив?',
      message: 'Прошлые приёмы сохранятся.',
      confirmLabel: 'В архив',
      danger: true,
    );

    var answer = ask();
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'В архив'),
    );
    expect(button.style?.backgroundColor?.resolve(const {}), AppColors.danger);
    await tester.tap(find.text('В архив'));
    await tester.pumpAndSettle();
    expect(await answer, isTrue);

    answer = ask();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(await answer, isFalse);

    // Dismissed by tapping outside counts as "no".
    answer = ask();
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(await answer, isFalse);
  });

  testWidgets('SectionHeader is a heading', (tester) async {
    await _pump(tester, const SectionHeader(title: 'Упаковки'));
    expect(
      tester.getSemantics(find.text('Упаковки')),
      matchesSemantics(label: 'Упаковки', isHeader: true),
    );
  });

  testWidgets('QuantityStepper calls back; null disables a button', (
    tester,
  ) async {
    var delta = 0;
    await _pump(
      tester,
      QuantityStepper(
        value: '0 шт.',
        onDecrement: null,
        onIncrement: () => delta++,
      ),
    );
    await tester.tap(find.byTooltip('Уменьшить остаток'));
    await tester.tap(find.byTooltip('Увеличить остаток'));
    expect(delta, 1);
    expect(find.text('0 шт.'), findsOneWidget);
  });

  testWidgets('components fit 320 dp at text scale 2', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pump(
      tester,
      ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SectionHeader(title: 'Упаковки и сроки годности'),
          const AppCard(child: Text('Очень длинное название лекарства')),
          const StatusBadge(
            label: 'Скоро истекает: до 25.10.2026 (через 7 дн.)',
            icon: Icons.schedule,
            tone: StatusTone.warning,
          ),
          QuantityStepper(
            value: '1000 шт.',
            onDecrement: () {},
            onIncrement: () {},
          ),
          DateField(
            label: 'Окончание (необязательно)',
            value: DateTime(2030),
            clearTooltip: 'Очистить',
            onChanged: (_) {},
          ),
        ],
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
