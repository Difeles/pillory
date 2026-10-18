import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/tokens.dart';
import '../../design_system/widgets/states.dart';
import '../../domain/models.dart';
import '../../domain/stock_status.dart';
import 'add_medicine_screen.dart';
import 'inventory_providers.dart';
import 'medicine_card.dart';

/// Room under the content for the floating add button.
const _fabClearance = 96.0;

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
      _fabClearance,
    ),
    itemCount: items.length,
    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.ms),
    itemBuilder: (_, i) => MedicineCard(stock: items[i], archived: _archive),
  );

  @override
  Widget build(BuildContext context) {
    final provider = _archive ? archivedStockProvider : medicineStockProvider;
    final stock = ref.watch(provider);
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
        loading: () => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [LoadingState()],
        ),
        error: (e, _) => ErrorState(
          message: 'Не удалось загрузить аптечку',
          onRetry: () => ref.invalidate(provider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _archive
                ? const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Архив пуст',
                    message: 'Сюда попадают лекарства, убранные из аптечки.',
                  )
                : EmptyState(
                    icon: Icons.medication_outlined,
                    title: 'В аптечке пока пусто',
                    message:
                        'Добавьте первое лекарство, чтобы следить за остатком '
                        'и сроком годности.',
                    action: FilledButton.icon(
                      onPressed: () => _add(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Добавить лекарство'),
                    ),
                  );
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
                    // Kept clear of the button, which is wide at large text.
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: _fabClearance),
                        child: EmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'Нет лекарств с таким статусом',
                          action: FilledButton.tonal(
                            onPressed: () =>
                                setState(() => _filter = StockFilter.all),
                            child: const Text('Показать все'),
                          ),
                        ),
                      )
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
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.xs,
      AppSpacing.md,
      AppSpacing.sm,
    ),
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
