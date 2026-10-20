import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/app_top_bar.dart';
import '../../design_system/widgets/section_header.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../domain/extras.dart';
import '../../domain/models.dart';
import '../../domain/stock_status.dart';
import '../inventory/inventory_providers.dart';
import '../../design_system/motion.dart';

/// A basic home first-aid kit: group title and the items to have.
const basicKit = <(String, List<String>)>[
  ('Жаропонижающие и обезболивающие', ['Парацетамол', 'Ибупрофен']),
  ('Антисептики для ран', ['Хлоргексидин', 'Мирамистин']),
  ('Перевязочные материалы', ['Пластырь', 'Бинт']),
  ('Желудок и кишечник', ['Активированный уголь', 'Смекта']),
  ('Аллергия', ['Супрастин', 'Цетиризин']),
];

/// Whether some cabinet medicine is [item] (a name match, ignoring case).
bool inCabinet(String item, List<MedicineStock> stock) {
  final k = item.toLowerCase();
  return stock.any((s) => s.medicine.name.toLowerCase().contains(k));
}

String? _reason(StockAssessment a) => switch (a.problem) {
  StockProblem.expired => 'Просрочено',
  StockProblem.expiringSoon => 'Скоро срок',
  StockProblem.out => 'Закончилось',
  StockProblem.low => 'Мало',
  null => null,
};

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _add(String name, {String? medicineId}) => ref
      .read(extrasRepositoryProvider)
      .addShopping(name, medicineId: medicineId);

  Future<void> _submit() async {
    final text = _input.text;
    _input.clear();
    await _add(text);
  }

  Future<void> _copy(List<ShoppingItem> items) async {
    final messenger = ScaffoldMessenger.of(context);
    final todo = [
      for (final i in items)
        if (!i.checked) '• ${i.name}',
    ];
    await Clipboard.setData(ClipboardData(text: todo.join('\n')));
    messenger.showSnackBar(const SnackBar(content: Text('Список скопирован')));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingProvider).value ?? const <ShoppingItem>[];
    final stock = ref.watch(medicineStockProvider).value ?? const [];
    final now = DateTime.now();
    final listed = {for (final i in items) i.name.toLowerCase()};
    final urgent = [
      for (final s in stock)
        if (assess(s, now) case final a when a.problem != null) a,
    ];
    final extras = ref.read(extrasRepositoryProvider);
    return Scaffold(
      appBar: const AppTopBar(title: 'Покупки'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl + AppSpacing.xl,
        ),
        children: [
          const SectionHeader(title: 'Срочно докупить'),
          if (urgent.isEmpty)
            const AppCard(
              variant: AppCardVariant.done,
              child: Text(
                'Всё в порядке: ничего не заканчивается и не истекает.',
              ),
            )
          else
            for (final a in urgent)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.stock.medicine.name,
                              style: AppType.cardTitle,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            StatusBadge(
                              label: _reason(a)!,
                              icon: Icons.warning_amber_rounded,
                              tone: StatusTone.warning,
                            ),
                          ],
                        ),
                      ),
                      listed.contains(a.stock.medicine.name.toLowerCase())
                          ? Icon(
                              Icons.check_circle,
                              color: context.colors.success,
                            )
                          : Pressable(
                              child: FilledButton.icon(
                                onPressed: () => _add(
                                  a.stock.medicine.name,
                                  medicineId: a.stock.medicine.id,
                                ),
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('В список'),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
          const SectionHeader(title: 'Мой список'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    hintText: 'Что купить?',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Pressable(
                scale: .88,
                child: IconButton.filled(
                  tooltip: 'Добавить в список',
                  onPressed: _submit,
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('Список пуст', style: AppType.caption),
            )
          else ...[
            for (final i in items)
              Pressable(
                scale: .98,
                child: CheckboxListTile(
                  value: i.checked,
                  onChanged: (v) => extras.setChecked(i.id, v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    i.name,
                    style: TextStyle(
                      decoration: i.checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  secondary: IconButton(
                    tooltip: 'Убрать из списка',
                    icon: const Icon(Icons.close),
                    onPressed: () => extras.removeShopping(i.id),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Pressable(
                child: TextButton.icon(
                  onPressed: () => _copy(items),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Скопировать список'),
                ),
              ),
            ),
          ],
          const SectionHeader(title: 'Собери идеальную аптечку'),
          for (final (title, kit) in basicKit)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: AppType.cardTitle),
                    for (final item in kit)
                      Row(
                        children: [
                          Expanded(child: Text(item)),
                          if (inCabinet(item, stock))
                            const StatusBadge(
                              label: 'В наличии',
                              icon: Icons.check_circle,
                              tone: StatusTone.success,
                            )
                          else if (listed.contains(item.toLowerCase()))
                            const StatusBadge(
                              label: 'В списке',
                              icon: Icons.shopping_bag_outlined,
                              tone: StatusTone.accent,
                            )
                          else
                            Pressable(
                              child: TextButton.icon(
                                onPressed: () => _add(item),
                                icon: const Icon(Icons.add),
                                label: const Text('Добавить'),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
