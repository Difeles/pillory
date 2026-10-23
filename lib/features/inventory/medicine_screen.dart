import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/confirm_dialog.dart';
import '../../design_system/widgets/date_field.dart';
import '../../design_system/widgets/pill_view.dart';
import '../../design_system/widgets/section_header.dart';
import '../../design_system/widgets/states.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/models.dart';
import '../../domain/pill_look.dart';
import '../../domain/stock_status.dart';
import '../../domain/supply.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import 'add_medicine_screen.dart';
import 'format.dart';
import 'inventory_providers.dart';
import 'medicine_card.dart';
import 'take_now.dart';
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
      if (medicine.form != null) context.l10n.form(medicine.form!),
      if (medicine.strength != null) medicine.strength!,
    ].join(' · ');
    final quantity = context.l10n.quantity(stock.totalQuantity, stock.unit);
    final supply = archived
        ? null
        : forecastSupply(
            stock,
            ref.watch(activeSchedulesProvider).value ?? const [],
            DateTime.now(),
          );
    final supplyLine = supply == null
        ? null
        : supplyText(context, supply, DateTime.now());
    return Scaffold(
      // The name is the header below, so it is not repeated here.
      appBar: AppBar(
        actions: [
          Pressable(
            scale: .88,
            child: PopupMenuButton<VoidCallback>(
              tooltip: context.l10n.medicineTitle,
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddMedicineScreen(editing: medicine),
                    ),
                  ),
                  child: Text(context.l10n.edit),
                ),
                PopupMenuItem(
                  value: () => archived
                      ? _restore(context, ref)
                      : _archive(context, ref),
                  child: Text(
                    archived
                        ? context.l10n.restoreFromArchive
                        : context.l10n.toArchive,
                  ),
                ),
                PopupMenuItem(
                  value: () => _delete(context, ref),
                  child: Text(
                    context.l10n.deleteForever,
                    style: TextStyle(color: context.colors.danger),
                  ),
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
                    MedicineAvatar(form: medicine.form, look: medicine.look),
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
                            StatusBadge(
                              label: context.l10n.inArchiveBadge,
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
                          label: context.l10n.category(medicine.category!),
                          icon: Icons.label_outline,
                          tone: StatusTone.warning,
                        ),
                      if (medicine.storage != null)
                        StatusBadge(
                          label: context.l10n.storage(medicine.storage!),
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
                    label:
                        '${context.l10n.stockSemantics(quantity)}${supplyLine == null ? '' : '. $supplyLine'}',
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.totalStock,
                          style: AppType.caption.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        Text(quantity, style: AppType.numeric),
                        if (supplyLine != null)
                          Text(
                            supplyLine,
                            style: AppType.caption.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!archived) ...[
            // Each package that still has something, in the order it is used.
            for (final (i, p) in inUseOrder(
              stock.counted,
              DateTime.now(),
            ).where((p) => p.initialQuantity <= 30).indexed) ...[
              if (i == 0) SectionHeader(title: context.l10n.stockInPackage),
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stock.counted.where((x) => x.quantity > 0).length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          i == 0
                              ? '${context.l10n.packageOrdinal(i + 1)} · ${context.l10n.packageInUse}'
                              : context.l10n.packageOrdinal(i + 1),
                          style: AppType.label,
                        ),
                      ),
                    _PillGrid(package: p, look: medicine.look),
                  ],
                ),
              ),
            ],
          ],
          SectionHeader(title: context.l10n.secPackages),
          for (final p in stock.packages)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.ms),
              child: _PackageTile(
                package: p,
                counted: p.unit == stock.unit,
                unit: stock.unit,
                canDelete: stock.packages.length > 1,
              ),
            ),
          if (!archived) ...[
            Pressable(
              child: FilledButton.icon(
                onPressed: stock.totalQuantity > 0
                    ? () => takeNow(context, ref, stock)
                    : null,
                icon: const Icon(Icons.check),
                label: Text(context.l10n.takeNow),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Pressable(
              child: FilledButton.tonalIcon(
                onPressed: () => _addPackage(context, ref, stock),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addPackage),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Pressable(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final added = context.l10n.addedToShopping;
                  await ref
                      .read(extrasRepositoryProvider)
                      .addShopping(medicine.name, medicineId: medicine.id);
                  messenger.showSnackBar(SnackBar(content: Text(added)));
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(context.l10n.toShoppingList),
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
      title: context.l10n.archiveAskTitle,
      message: context.l10n.archiveAskText,
      confirmLabel: context.l10n.toArchive,
    );
    if (ok) {
      await ref.read(inventoryRepositoryProvider).archiveMedicine(medicineId);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final name = ref
        .read(medicineStockProvider)
        .value
        ?.followedBy(ref.read(archivedStockProvider).value ?? const [])
        .where((s) => s.medicine.id == medicineId)
        .map((s) => s.medicine.name)
        .firstOrNull;
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.deleteMedicineAskTitle,
      message: context.l10n.deleteMedicineAskText(name ?? ''),
      confirmLabel: context.l10n.deleteConfirm,
      danger: true,
    );
    if (!ok) return;
    await ref.read(inventoryRepositoryProvider).deleteMedicine(medicineId);
    navigator.pop();
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.medicineRestored;
    await ref.read(inventoryRepositoryProvider).restoreMedicine(medicineId);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addPackage(
    BuildContext context,
    WidgetRef ref,
    MedicineStock stock,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final problem = context.l10n.problem;
    final result = await showDialog<(double, double, DateTime?)>(
      context: context,
      builder: (_) => _AddPackageDialog(unit: stock.unit),
    );
    if (result == null) return;
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .addPackage(
            medicineId: medicineId,
            quantity: result.$2,
            packSize: result.$1,
            unit: stock.unit,
            expiresOn: result.$3,
          );
    } on InvalidMedicineException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(problem(e.message))));
    }
  }
}

class _PackageTile extends ConsumerWidget {
  const _PackageTile({
    required this.package,
    required this.counted,
    required this.unit,
    required this.canDelete,
  });

  final MedicinePackage package;
  final bool counted;
  final String unit;
  final bool canDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final expiry = package.expiresOn;
    final today = DateTime.now();
    final badges = [
      if (expiry != null)
        isExpired(expiry, today)
            ? StatusBadge(
                label: l.expiryPassed(formatDate(expiry)),
                icon: Icons.error_outline,
                tone: StatusTone.danger,
              )
            : StatusBadge(
                label: l.goodUntil(formatDate(expiry)),
                icon: Icons.event_outlined,
              ),
      if (counted && package.quantity <= 0)
        StatusBadge(
          label: l.packageOut,
          icon: Icons.remove_circle_outline,
          tone: StatusTone.danger,
        ),
      if (counted &&
          packageStatus(package, today) == PackageStatus.expiringSoon)
        StatusBadge(
          label: l.expiringSoonShort,
          icon: Icons.schedule,
          tone: StatusTone.warning,
        ),
      if (!counted)
        StatusBadge(
          label: l.otherUnitNote,
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
                  l.quantity(package.quantity, package.unit),
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
              tooltip: context.l10n.packageTooltip,
              onSelected: (action) => action(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: () => _correct(context, ref),
                  child: Text(context.l10n.correctStock),
                ),
                PopupMenuItem(
                  value: () => _pickExpiry(context, ref),
                  child: Text(context.l10n.expiryTitle),
                ),
                if (expiry != null)
                  PopupMenuItem(
                    value: () => ref
                        .read(inventoryRepositoryProvider)
                        .updatePackageExpiry(package.id, null),
                    child: Text(context.l10n.clearExpiry),
                  ),
                PopupMenuItem(
                  value: () => _history(context, ref),
                  child: Text(context.l10n.movementHistory),
                ),
                if (canDelete)
                  PopupMenuItem(
                    value: () => _delete(context, ref),
                    child: Text(
                      context.l10n.deletePackage,
                      style: TextStyle(color: context.colors.danger),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l.deletePackageAskTitle,
      message: l.deletePackageAskText(
        l.quantity(package.quantity, package.unit),
      ),
      confirmLabel: l.deleteConfirm,
      danger: true,
    );
    if (ok) {
      await ref.read(inventoryRepositoryProvider).deletePackage(package.id);
    }
  }

  Future<void> _pickExpiry(BuildContext context, WidgetRef ref) async {
    final picked = await pickDate(
      context,
      initial: package.expiresOn ?? DateTime.now(),
      // Past dates stay selectable: people also record expired medicines.
      first: DateTime(2000),
      last: DateTime(2100),
      title: context.l10n.expiryTitle,
    );
    if (picked != null) {
      await ref
          .read(inventoryRepositoryProvider)
          .updatePackageExpiry(package.id, picked);
    }
  }

  Future<void> _correct(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final stale = context.l10n.staleQuantity;
    final problem = context.l10n.problem;
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
      messenger.showSnackBar(SnackBar(content: Text(stale)));
    } on InvalidMedicineException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(problem(e.message))));
    }
  }

  Future<void> _history(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(inventoryRepositoryProvider);
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(c.l10n.movementHistory),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<InventoryTransaction>>(
            future: repo.history(package.id),
            builder: (_, snap) {
              final list = snap.data;
              if (list == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) return Text(c.l10n.noMovements);
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
                          '${_kind(c, t.kind)}: ${_signed(t.delta)} '
                          '${c.l10n.unit(package.unit)}',
                        ),
                        subtitle: Text(
                          c.l10n.stockAfter(
                            c.l10n.quantity(t.quantityAfter, package.unit),
                            _when(t.createdAt),
                          ),
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
              child: Text(c.l10n.close),
            ),
          ),
        ],
      ),
    );
  }

  static String _kind(BuildContext c, TransactionKind k) => switch (k) {
    TransactionKind.initial => c.l10n.txInitial,
    TransactionKind.increase => c.l10n.txIncrease,
    TransactionKind.decrease => c.l10n.txDecrease,
    TransactionKind.correction => c.l10n.txCorrection,
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
  final _size = TextEditingController(text: '1');
  final _quantity = TextEditingController(text: '1');
  bool _quantityTouched = false;
  DateTime? _expiresOn;
  String? _error;

  @override
  void dispose() {
    _size.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    // Scrolls rather than overflows at large text or with the keyboard up.
    scrollable: true,
    title: Text(context.l10n.newPackage),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _size,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.l10n.packSizeLabel,
            suffixText: context.l10n.unit(widget.unit),
          ),
          onChanged: (v) {
            if (!_quantityTouched) _quantity.text = v;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.l10n.packLeftLabel,
            suffixText: context.l10n.unit(widget.unit),
            errorText: _error,
          ),
          onChanged: (_) => _quantityTouched = true,
        ),
        const SizedBox(height: AppSpacing.md),
        DateField(
          label: context.l10n.expiryTitle,
          value: _expiresOn,
          clearTooltip: context.l10n.clearExpiry,
          onChanged: (d) => setState(() => _expiresOn = d),
        ),
      ],
    ),
    actions: [
      Pressable(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
      ),
      Pressable(
        child: FilledButton(
          onPressed: () {
            final q = parseQuantity(_quantity.text);
            final size = parseQuantity(_size.text);
            if (q == null || !q.isFinite || q < 0) {
              setState(() => _error = context.l10n.enterNumberZero);
              return;
            }
            if (size == null || !size.isFinite || size < q) {
              setState(() => _error = context.l10n.pPackSmaller);
              return;
            }
            Navigator.pop(context, (size, q, _expiresOn));
          },
          child: Text(context.l10n.add),
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
    title: Text(context.l10n.correctStock),
    content: TextField(
      controller: _quantity,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: context.l10n.actualStock,
        suffixText: context.l10n.unit(widget.package.unit),
        errorText: _error,
      ),
    ),
    actions: [
      Pressable(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
      ),
      Pressable(
        child: FilledButton(
          onPressed: () {
            final q = parseQuantity(_quantity.text);
            if (q == null || !q.isFinite || q < 0) {
              setState(() => _error = context.l10n.enterNumberZero);
              return;
            }
            Navigator.pop(context, q);
          },
          child: Text(context.l10n.save),
        ),
      ),
    ],
  );
}

/// One icon per unit of the package: full ones left, used ones greyed.
class _PillGrid extends StatelessWidget {
  const _PillGrid({required this.package, this.look});

  final MedicinePackage package;

  /// The user's pill drawing, used instead of the plain icons.
  final PillLook? look;

  @override
  Widget build(BuildContext context) {
    final total = package.initialQuantity.ceil();
    final left = package.quantity.ceil().clamp(0, total);
    return Semantics(
      label: context.l10n.leftOfTotal(left, total),
      excludeSemantics: true,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (var i = 0; i < total; i++)
            if (look != null)
              // Used ones fade out.
              Opacity(
                opacity: i < left ? 1 : .22,
                child: PillView(look: look!, size: 36),
              )
            else
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
