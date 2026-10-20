import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/confirm_dialog.dart';
import '../../design_system/widgets/date_field.dart';
import '../../design_system/widgets/section_header.dart';
import '../../design_system/widgets/states.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/models.dart';
import '../../domain/stock_status.dart';
import 'add_medicine_screen.dart';
import 'format.dart';
import 'inventory_providers.dart';
import 'medicine_card.dart';
import '../../design_system/pickers.dart';
import '../../design_system/motion.dart';

/// One medicine: its details, its packages and what can be done with them.
class MedicineScreen extends ConsumerWidget {
  const MedicineScreen({super.key, required this.medicineId});

  final String medicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = [
      ...?ref.watch(medicineStockProvider).value,
      ...?ref.watch(archivedStockProvider).value,
    ];
    final stock = all.where((s) => s.medicine.id == medicineId).firstOrNull;
    if (stock == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: const [LoadingState(cards: 2)],
        ),
      );
    }
    final medicine = stock.medicine;
    final archived = medicine.archivedAt != null;
    final details = [
      if (medicine.form != null) medicine.form!.label,
      if (medicine.strength != null) medicine.strength!,
    ].join(' · ');
    final quantity = '${formatQuantity(stock.totalQuantity)} ${stock.unit}';
    return Scaffold(
      // The name is the header below, so it is not repeated here.
      appBar: AppBar(
        actions: [
          Pressable(
            scale: .88,
            child: PopupMenuButton<VoidCallback>(
              tooltip: 'Лекарство',
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddMedicineScreen(editing: medicine),
                    ),
                  ),
                  child: const Text('Изменить'),
                ),
                PopupMenuItem(
                  value: () => archived
                      ? _restore(context, ref)
                      : _archive(context, ref),
                  child: Text(archived ? 'Вернуть из архива' : 'В архив'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          AppCard(
            variant: archived ? AppCardVariant.muted : AppCardVariant.normal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MedicineAvatar(form: medicine.form),
                    const SizedBox(width: AppSpacing.ms),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(medicine.name, style: AppType.title),
                          ),
                          if (details.isNotEmpty)
                            Text(
                              details,
                              style: AppType.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          if (archived) ...[
                            const SizedBox(height: AppSpacing.sm),
                            const StatusBadge(
                              label: 'В архиве',
                              icon: Icons.inventory_2_outlined,
                              tone: StatusTone.accent,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (medicine.category != null || medicine.storage != null) ...[
                  const SizedBox(height: AppSpacing.ms),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (medicine.category != null)
                        StatusBadge(
                          label: medicine.category!.label,
                          icon: Icons.label_outline,
                          tone: StatusTone.warning,
                        ),
                      if (medicine.storage != null)
                        StatusBadge(
                          label: medicine.storage!.label,
                          icon: Icons.place_outlined,
                          tone: StatusTone.accent,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                // One announcement for the caption and the number.
                MergeSemantics(
                  child: Semantics(
                    label: 'Остаток: $quantity',
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Общий остаток',
                          style: AppType.caption.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        Text(quantity, style: AppType.numeric),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!archived && stock.primaryPackage.initialQuantity <= 30) ...[
            const SectionHeader(title: 'Остаток в упаковке'),
            AppCard(child: _PillGrid(package: stock.primaryPackage)),
          ],
          const SectionHeader(title: 'Упаковки'),
          for (final p in stock.packages)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.ms),
              child: _PackageTile(
                package: p,
                counted: p.unit == stock.unit,
                unit: stock.unit,
              ),
            ),
          if (!archived) ...[
            Pressable(
              child: FilledButton.tonalIcon(
                onPressed: () => _addPackage(context, ref, stock),
                icon: const Icon(Icons.add),
                label: const Text('Добавить упаковку'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Pressable(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(extrasRepositoryProvider)
                      .addShopping(medicine.name, medicineId: medicine.id);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Добавлено в список покупок')),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('В список покупок'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Убрать в архив?',
      message:
          'Действующие расписания этого лекарства будут завершены, '
          'напоминания отключены. Прошлые приёмы и история остатков '
          'сохранятся.',
      confirmLabel: 'В архив',
    );
    if (ok) {
      await ref.read(inventoryRepositoryProvider).archiveMedicine(medicineId);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(inventoryRepositoryProvider).restoreMedicine(medicineId);
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Лекарство возвращено. Завершённые расписания нужно создать заново',
        ),
      ),
    );
  }

  Future<void> _addPackage(
    BuildContext context,
    WidgetRef ref,
    MedicineStock stock,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<(double, DateTime?)>(
      context: context,
      builder: (_) => _AddPackageDialog(unit: stock.unit),
    );
    if (result == null) return;
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .addPackage(
            medicineId: medicineId,
            quantity: result.$1,
            unit: stock.unit,
            expiresOn: result.$2,
          );
    } on InvalidMedicineException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _PackageTile extends ConsumerWidget {
  const _PackageTile({
    required this.package,
    required this.counted,
    required this.unit,
  });

  final MedicinePackage package;
  final bool counted;
  final String unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiry = package.expiresOn;
    final today = DateTime.now();
    final badges = [
      if (expiry != null)
        isExpired(expiry, today)
            ? StatusBadge(
                label: 'Срок годности истёк ${formatDate(expiry)}',
                icon: Icons.error_outline,
                tone: StatusTone.danger,
              )
            : StatusBadge(
                label: 'Годен до ${formatDate(expiry)}',
                icon: Icons.event_outlined,
              ),
      if (counted && package.quantity <= 0)
        const StatusBadge(
          label: 'Закончилась',
          icon: Icons.remove_circle_outline,
          tone: StatusTone.danger,
        ),
      if (counted &&
          packageStatus(package, today) == PackageStatus.expiringSoon)
        const StatusBadge(
          label: 'Скоро истекает',
          icon: Icons.schedule,
          tone: StatusTone.warning,
        ),
      if (!counted)
        const StatusBadge(
          label:
              'Другая единица: не входит в остаток и не расходуется приёмами',
          icon: Icons.info_outline,
          tone: StatusTone.warning,
        ),
    ];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.ms,
        AppSpacing.xs,
        AppSpacing.ms,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatQuantity(package.quantity)} ${package.unit}',
                  style: AppType.cardTitle.copyWith(
                    fontFeatures: AppType.numeric.fontFeatures,
                  ),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: badges,
                  ),
                ],
              ],
            ),
          ),
          Pressable(
            scale: .88,
            child: PopupMenuButton<VoidCallback>(
              tooltip: 'Упаковка',
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: () => _correct(context, ref),
                  child: const Text('Скорректировать остаток'),
                ),
                PopupMenuItem(
                  value: () => _pickExpiry(context, ref),
                  child: const Text('Срок годности'),
                ),
                if (expiry != null)
                  PopupMenuItem(
                    value: () => ref
                        .read(inventoryRepositoryProvider)
                        .updatePackageExpiry(package.id, null),
                    child: const Text('Убрать срок годности'),
                  ),
                PopupMenuItem(
                  value: () => _history(context, ref),
                  child: const Text('История движения'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickExpiry(BuildContext context, WidgetRef ref) async {
    final picked = await pickDate(
      context,
      initial: package.expiresOn ?? DateTime.now(),
      // Past dates stay selectable: people also record expired medicines.
      first: DateTime(2000),
      last: DateTime(2100),
      title: 'Срок годности',
    );
    if (picked != null) {
      await ref
          .read(inventoryRepositoryProvider)
          .updatePackageExpiry(package.id, picked);
    }
  }

  Future<void> _correct(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final to = await showDialog<double>(
      context: context,
      builder: (_) => _CorrectDialog(package: package),
    );
    if (to == null) return;
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .correctQuantity(
            packageId: package.id,
            from: package.quantity,
            to: to,
          );
    } on StaleQuantityException {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Остаток изменился. Откройте корректировку заново'),
        ),
      );
    } on InvalidMedicineException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _history(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(inventoryRepositoryProvider);
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('История движения'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<InventoryTransaction>>(
            future: repo.history(package.id),
            builder: (_, snap) {
              final list = snap.data;
              if (list == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) return const Text('Движений нет');
              return ListView(
                shrinkWrap: true,
                children: [
                  for (final t in list)
                    Pressable(
                      scale: .98,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${_kind(t.kind)}: ${_signed(t.delta)} ${package.unit}',
                        ),
                        subtitle: Text(
                          'Остаток ${formatQuantity(t.quantityAfter)} '
                          '${package.unit} · ${_when(t.createdAt)}',
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        actions: [
          Pressable(
            child: TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }

  static String _kind(TransactionKind k) => switch (k) {
    TransactionKind.initial => 'Начальный остаток',
    TransactionKind.increase => 'Приход',
    TransactionKind.decrease => 'Расход',
    TransactionKind.correction => 'Коррекция',
  };

  static String _signed(double d) =>
      '${d > 0 ? '+' : '−'}${formatQuantity(d.abs())}';

  static String _when(DateTime d) =>
      '${formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}

class _AddPackageDialog extends StatefulWidget {
  const _AddPackageDialog({required this.unit});

  final String unit;

  @override
  State<_AddPackageDialog> createState() => _AddPackageDialogState();
}

class _AddPackageDialogState extends State<_AddPackageDialog> {
  final _quantity = TextEditingController(text: '1');
  DateTime? _expiresOn;
  String? _error;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    // Scrolls rather than overflows at large text or with the keyboard up.
    scrollable: true,
    title: const Text('Новая упаковка'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Количество',
            suffixText: widget.unit,
            errorText: _error,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DateField(
          label: 'Срок годности',
          value: _expiresOn,
          clearTooltip: 'Убрать срок годности',
          onChanged: (d) => setState(() => _expiresOn = d),
        ),
      ],
    ),
    actions: [
      Pressable(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
      ),
      Pressable(
        child: FilledButton(
          onPressed: () {
            final q = parseQuantity(_quantity.text);
            if (q == null || !q.isFinite || q < 0) {
              setState(() => _error = 'Введите число 0 или больше');
              return;
            }
            Navigator.pop(context, (q, _expiresOn));
          },
          child: const Text('Добавить'),
        ),
      ),
    ],
  );
}

class _CorrectDialog extends StatefulWidget {
  const _CorrectDialog({required this.package});

  final MedicinePackage package;

  @override
  State<_CorrectDialog> createState() => _CorrectDialogState();
}

class _CorrectDialogState extends State<_CorrectDialog> {
  late final _quantity = TextEditingController(
    text: formatQuantity(widget.package.quantity),
  );
  String? _error;

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const Text('Скорректировать остаток'),
    content: TextField(
      controller: _quantity,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Фактический остаток',
        suffixText: widget.package.unit,
        errorText: _error,
      ),
    ),
    actions: [
      Pressable(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
      ),
      Pressable(
        child: FilledButton(
          onPressed: () {
            final q = parseQuantity(_quantity.text);
            if (q == null || !q.isFinite || q < 0) {
              setState(() => _error = 'Введите число 0 или больше');
              return;
            }
            Navigator.pop(context, q);
          },
          child: const Text('Сохранить'),
        ),
      ),
    ],
  );
}

/// One icon per unit of the package: full ones left, used ones greyed.
class _PillGrid extends StatelessWidget {
  const _PillGrid({required this.package});

  final MedicinePackage package;

  @override
  Widget build(BuildContext context) {
    final total = package.initialQuantity.ceil();
    final left = package.quantity.ceil().clamp(0, total);
    return Semantics(
      label: 'Осталось $left из $total',
      excludeSemantics: true,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (var i = 0; i < total; i++)
            CircleAvatar(
              radius: 18,
              backgroundColor: i < left
                  ? AppColors.peach
                  : context.colors.surfaceMid,
              child: Icon(
                i < left ? Icons.medication : Icons.check,
                size: 18,
                color: i < left
                    ? AppColors.primaryDeep
                    : context.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
