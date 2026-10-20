import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/app_top_bar.dart';
import '../../design_system/widgets/progress_ring.dart';
import '../../design_system/widgets/states.dart';
import '../../domain/medicine_form.dart';
import '../../domain/models.dart';
import '../../domain/stock_status.dart';
import 'add_medicine_screen.dart';
import 'inventory_providers.dart';
import 'medicine_card.dart';
import '../../design_system/motion.dart';

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
  String _query = '';
  MedicineCategory? _category;

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

  bool _matchesQuery(MedicineStock s) =>
      s.medicine.name.toLowerCase().contains(_query.trim().toLowerCase());

  Widget _searchBar(int count) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.xs,
      AppSpacing.md,
      AppSpacing.sm,
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Поиск по $count лекарствам',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Pressable(
                scale: .88,
                child: IconButton(
                  tooltip: 'Сканер штрихкода — скоро',
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Сканер штрихкода — скоро')),
                    ),
                ),
              ),
              border: _pillBorder,
              enabledBorder: _pillBorder,
              focusedBorder: _pillBorder.copyWith(
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Pressable(
          scale: .88,
          child: IconButton.filledTonal(
            tooltip: _archive ? 'Вернуться в аптечку' : 'Архив',
            style: IconButton.styleFrom(
              backgroundColor: _archive ? AppColors.tint : AppColors.surface,
              foregroundColor: AppColors.primaryDeep,
              minimumSize: const Size.square(kMinTapSize),
            ),
            icon: Icon(
              _archive ? Icons.medication_outlined : Icons.inventory_2_outlined,
            ),
            onPressed: () => setState(() => _archive = !_archive),
          ),
        ),
      ],
    ),
  );

  /// One scrolling list: the header scrolls away too, so large text on a
  /// small screen still leaves room for the cards.
  Widget _list(
    List<MedicineStock> items, {
    List<Widget> header = const [],
    Widget? empty,
  }) => ListView(
    padding: const EdgeInsets.only(bottom: _fabClearance),
    children: [
      ...header,
      if (items.isEmpty && empty != null) empty,
      for (final s in items)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.ms,
          ),
          child: MedicineCard(stock: s, archived: _archive),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final provider = _archive ? archivedStockProvider : medicineStockProvider;
    final stock = ref.watch(provider);
    return Scaffold(
      appBar: AppTopBar(
        title: _archive ? 'Архив' : 'Аптечка',
        actions: [
          if (!_archive)
            TopBarAddButton(
              tooltip: 'Добавить лекарство',
              onPressed: () => _add(context),
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
            // The archive switch stays reachable when the cabinet is empty.
            return _list(
              const [],
              header: [_searchBar(0)],
              empty: _archive
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
                      action: Pressable(
                        child: FilledButton.icon(
                          onPressed: () => _add(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить лекарство'),
                        ),
                      ),
                    ),
            );
          }
          if (_archive) {
            return _list(items, header: [_searchBar(items.length)]);
          }
          final now = DateTime.now();
          final shown = [
            for (final a in filterStock(items, _filter, now))
              if (_matchesQuery(a.stock) &&
                  (_category == null || a.stock.medicine.category == _category))
                a.stock,
          ];
          return _list(
            shown,
            header: [
              _searchBar(items.length),
              _Summary(
                items: items,
                today: now,
                hint: ref.watch(prefsProvider).value?.hints ?? true,
              ),
              _CategoryBar(
                present: {
                  for (final s in items)
                    if (s.medicine.category != null) s.medicine.category!,
                },
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
              _FilterBar(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
            ],
            empty: EmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: 'Нет лекарств с таким статусом',
              action: Pressable(
                child: FilledButton.tonal(
                  onPressed: () => setState(() {
                    _filter = StockFilter.all;
                    _category = null;
                    _query = '';
                  }),
                  child: const Text('Показать все'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

final _pillBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppRadii.lg),
  borderSide: BorderSide.none,
);

/// Readiness of the cabinet: the share of medicines with no problem.
class _Summary extends StatelessWidget {
  const _Summary({
    required this.items,
    required this.today,
    required this.hint,
  });

  /// Whether to nudge about what needs buying (a profile setting).
  final bool hint;

  final List<MedicineStock> items;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final all = [for (final s in items) assess(s, today)];
    final expiring = all.where((a) => a.hasExpired || a.hasExpiringSoon).length;
    final low = all.where((a) => a.isOut || a.isLow).length;
    final ok = all.where((a) => a.problem == null).length;
    final share = all.isEmpty ? 0.0 : ok / all.length;
    Widget tile(String label, int n, Color bg, Color fg) => Expanded(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: bg,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.ms,
            horizontal: AppSpacing.xs,
          ),
          child: Column(
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.caption.copyWith(color: fg),
              ),
              Text('$n', style: AppType.numeric.copyWith(color: fg)),
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ГОТОВНОСТЬ АПТЕЧКИ',
                        style: AppType.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'В порядке: ${(share * 100).round()}%',
                        style: AppType.title,
                      ),
                    ],
                  ),
                ),
                ProgressRing(
                  value: share,
                  size: 48,
                  child: const Icon(
                    Icons.medical_services,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.ms),
            Row(
              spacing: AppSpacing.sm,
              children: [
                tile(
                  'Всего',
                  all.length,
                  AppColors.surfaceLow,
                  AppColors.textPrimary,
                ),
                tile(
                  'Истекают',
                  expiring,
                  AppColors.warningTint,
                  AppColors.warning,
                ),
                tile('Мало', low, AppColors.dangerTint, AppColors.danger),
              ],
            ),
            if (hint && expiring + low > 0) ...[
              const SizedBox(height: AppSpacing.ms),
              Text(
                'Пора докупить: ${expiring + low} — загляните во вкладку «Покупки»',
                style: AppType.caption.copyWith(color: AppColors.primaryDeep),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Category chips; shown only when some medicine has a category.
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.present,
    required this.selected,
    required this.onSelected,
  });

  final Set<MedicineCategory> present;
  final MedicineCategory? selected;
  final ValueChanged<MedicineCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (present.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Pressable(
            scale: .93,
            child: ChoiceChip(
              label: const Text('Все категории'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final c in MedicineCategory.values)
            if (present.contains(c))
              Pressable(
                scale: .93,
                child: ChoiceChip(
                  label: Text(c.label),
                  selected: selected == c,
                  onSelected: (_) => onSelected(selected == c ? null : c),
                ),
              ),
        ],
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
            child: Pressable(
              scale: .93,
              child: ChoiceChip(
                label: Text(f.label),
                selected: f == selected,
                onSelected: (_) => onSelected(f),
              ),
            ),
          ),
      ],
    ),
  );
}
