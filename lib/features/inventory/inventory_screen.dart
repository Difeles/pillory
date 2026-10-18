import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/tokens.dart';
import '../../domain/models.dart';
import '../../domain/stock_status.dart';
import 'add_medicine_screen.dart';
import 'inventory_providers.dart';
import 'medicine_card.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key, this.active = true});

  /// Changes when the tab is switched, so the statuses are worked out again.
  final bool active;

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with WidgetsBindingObserver {
  bool _archive = false;
  StockFilter _filter = StockFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A new day may have started while the app was away.
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  void _add(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const AddMedicineScreen()));

  Widget _list(List<MedicineStock> items) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      96,
    ),
    itemCount: items.length,
    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
    itemBuilder: (_, i) => MedicineCard(stock: items[i], archived: _archive),
  );

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(
      _archive ? archivedStockProvider : medicineStockProvider,
    );
    final isEmpty = stock.maybeWhen(
      data: (l) => l.isEmpty,
      orElse: () => false,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(_archive ? 'Архив' : 'Аптечка'),
        actions: [
          IconButton(
            tooltip: _archive ? 'Вернуться в аптечку' : 'Архив',
            icon: Icon(
              _archive ? Icons.medication_outlined : Icons.inventory_2_outlined,
            ),
            onPressed: () => setState(() => _archive = !_archive),
          ),
        ],
      ),
      body: stock.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            const Center(child: Text('Не удалось загрузить аптечку')),
        data: (items) {
          if (items.isEmpty) {
            return _archive
                ? const Center(child: Text('Архив пуст'))
                : _EmptyState(onAdd: () => _add(context));
          }
          if (_archive) return _list(items);
          final shown = [
            for (final a in filterStock(items, _filter, DateTime.now()))
              a.stock,
          ];
          return Column(
            children: [
              _FilterBar(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
              Expanded(
                child: shown.isEmpty
                    ? const Center(child: Text('Нет лекарств с таким статусом'))
                    : _list(shown),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isEmpty || _archive
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add),
              label: const Text('Добавить лекарство'),
            ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final StockFilter selected;
  final ValueChanged<StockFilter> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: Row(
      children: [
        for (final f in StockFilter.values)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(f.label),
              selected: f == selected,
              onSelected: (_) => onSelected(f),
            ),
          ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.tint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'В аптечке пока пусто',
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Добавьте первое лекарство, чтобы следить за остатком '
              'и сроком годности.',
              style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Добавить лекарство'),
            ),
          ],
        ),
      ),
    );
  }
}
