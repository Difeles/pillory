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
import '../../domain/supply.dart';
import '../../l10n/l10n.dart';
import '../inventory/format.dart';
import '../inventory/medicine_screen.dart';
import '../inventory/inventory_providers.dart';
import '../../design_system/motion.dart';

/// A basic home first-aid kit: group title and the items to have.
List<(String, List<String>)> basicKit(AppLocalizations l) => [
  (l.kitFever, l.kitFeverItems.split('|')),
  (l.kitAntiseptic, l.kitAntisepticItems.split('|')),
  (l.kitDressings, l.kitDressingsItems.split('|')),
  (l.kitStomach, l.kitStomachItems.split('|')),
  (l.kitAllergy, l.kitAllergyItems.split('|')),
];

/// Whether some cabinet medicine is [item] (a name match, ignoring case).
bool inCabinet(String item, List<MedicineStock> stock) {
  final k = item.toLowerCase();
  return stock.any((s) => s.medicine.name.toLowerCase().contains(k));
}

String? _reason(AppLocalizations l, StockAssessment a) => switch (a.problem) {
  StockProblem.expired => l.reasonExpired,
  StockProblem.expiringSoon => l.reasonExpiringSoon,
  StockProblem.out => l.reasonOut,
  StockProblem.low => l.reasonLow,
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

  /// A bought medicine can be put straight into the cabinet.
  Future<void> _check(ShoppingItem item, bool checked) async {
    await ref.read(extrasRepositoryProvider).setChecked(item.id, checked);
    final medicineId = item.medicineId;
    if (!checked || medicineId == null || !mounted) return;
    final navigator = Navigator.of(context);
    final l = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.boughtAsk(item.name)),
        action: SnackBarAction(
          label: l.toCabinet,
          onPressed: () => navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => MedicineScreen(medicineId: medicineId),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copy(List<ShoppingItem> items) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = context.l10n.listCopied;
    final todo = [
      for (final i in items)
        if (!i.checked) '• ${i.name}',
    ];
    await Clipboard.setData(ClipboardData(text: todo.join('\n')));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingProvider).value ?? const <ShoppingItem>[];
    final stock = ref.watch(medicineStockProvider).value ?? const [];
    final now = DateTime.now();
    final listed = {for (final i in items) i.name.toLowerCase()};
    final schedules = ref.watch(activeSchedulesProvider).value ?? const [];
    // Medicines with a problem, and those that will run out within a week.
    final urgent = <(MedicineStock, String)>[];
    for (final s in stock) {
      final a = assess(s, now);
      final supply = forecastSupply(s, schedules, now);
      final reason =
          _reason(context.l10n, a) ??
          (supply != null &&
                  !supply.coversPlan &&
                  !supply.beyondHorizon &&
                  supply.days <= supplyWarnDays
              ? supplyText(context, supply, now)
              : null);
      if (reason != null) urgent.add((s, reason));
    }
    final extras = ref.read(extrasRepositoryProvider);
    return Scaffold(
      appBar: AppTopBar(title: context.l10n.titleShopping),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl + AppSpacing.xl,
        ),
        children: [
          SectionHeader(title: context.l10n.secUrgent),
          if (urgent.isEmpty)
            AppCard(
              variant: AppCardVariant.done,
              child: Text(context.l10n.allFine),
            )
          else
            for (final (item, reason) in urgent)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.medicine.name, style: AppType.cardTitle),
                            const SizedBox(height: AppSpacing.xs),
                            StatusBadge(
                              label: reason,
                              icon: Icons.warning_amber_rounded,
                              tone: StatusTone.warning,
                            ),
                          ],
                        ),
                      ),
                      listed.contains(item.medicine.name.toLowerCase())
                          ? Icon(
                              Icons.check_circle,
                              color: context.colors.success,
                            )
                          : Pressable(
                              child: FilledButton.icon(
                                onPressed: () => _add(
                                  item.medicine.name,
                                  medicineId: item.medicine.id,
                                ),
                                icon: const Icon(Icons.add_shopping_cart),
                                label: Text(context.l10n.toList),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
          SectionHeader(title: context.l10n.secMyList),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: context.l10n.whatToBuy,
                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Pressable(
                scale: .88,
                child: IconButton.filled(
                  tooltip: context.l10n.addToList,
                  onPressed: _submit,
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(context.l10n.listEmpty, style: AppType.caption),
            )
          else ...[
            for (final i in items)
              Pressable(
                scale: .98,
                child: CheckboxListTile(
                  value: i.checked,
                  onChanged: (v) => _check(i, v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    i.name,
                    style: TextStyle(
                      decoration: i.checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  secondary: IconButton(
                    tooltip: context.l10n.removeFromList,
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
                  label: Text(context.l10n.copyList),
                ),
              ),
            ),
          ],
          SectionHeader(title: context.l10n.secIdealKit),
          for (final (title, kit) in basicKit(context.l10n))
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
                            StatusBadge(
                              label: context.l10n.inStock,
                              icon: Icons.check_circle,
                              tone: StatusTone.success,
                            )
                          else if (listed.contains(item.toLowerCase()))
                            StatusBadge(
                              label: context.l10n.inList,
                              icon: Icons.shopping_bag_outlined,
                              tone: StatusTone.accent,
                            )
                          else
                            Pressable(
                              child: TextButton.icon(
                                onPressed: () => _add(item),
                                icon: const Icon(Icons.add),
                                label: Text(context.l10n.add),
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
