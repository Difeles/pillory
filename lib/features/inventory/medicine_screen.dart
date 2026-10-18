import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/models.dart';
import 'add_medicine_screen.dart';
import 'format.dart';
import 'inventory_providers.dart';

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
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final medicine = stock.medicine;
    final archived = medicine.archivedAt != null;
    final text = Theme.of(context).textTheme;
    final details = [
      if (medicine.form != null) medicine.form!.label,
      if (medicine.strength != null) medicine.strength!,
    ].join(' · ');
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        actions: [
          PopupMenuButton<VoidCallback>(
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
                value: () =>
                    archived ? _restore(context, ref) : _archive(context, ref),
                child: Text(archived ? 'Вернуть из архива' : 'В архив'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (archived)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'В архиве',
                style: text.titleMedium?.copyWith(color: AppColors.danger),
              ),
            ),
          if (details.isNotEmpty) Text(details, style: text.bodyLarge),
          Text(
            'Остаток: ${formatQuantity(stock.totalQuantity)} ${stock.unit}',
            style: text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Упаковки', style: text.titleMedium),
          for (final p in stock.packages)
            _PackageTile(
              package: p,
              counted: p.unit == stock.unit,
              unit: stock.unit,
            ),
          if (!archived) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonalIcon(
              onPressed: () => _addPackage(context, ref, stock),
              icon: const Icon(Icons.add),
              label: const Text('Добавить упаковку'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Убрать в архив?'),
        content: const Text(
          'Действующие расписания этого лекарства будут завершены, '
          'напоминания отключены. Прошлые приёмы и история остатков '
          'сохранятся.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('В архив'),
          ),
        ],
      ),
    );
    if (ok == true) {
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
    final expired = isExpired(expiry, DateTime.now());
    final lines = [
      if (expiry != null)
        expired
            ? 'Срок годности истёк ${formatDate(expiry)}'
            : 'Годен до ${formatDate(expiry)}',
      if (!counted)
        'Другая единица: не входит в остаток и не расходуется приёмами',
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${formatQuantity(package.quantity)} ${package.unit}'),
      subtitle: lines.isEmpty ? null : Text(lines.join('\n')),
      trailing: PopupMenuButton<VoidCallback>(
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
    );
  }

  Future<void> _pickExpiry(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: package.expiresOn ?? DateTime.now(),
      // Past dates stay selectable: people also record expired medicines.
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Срок годности',
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
                    ListTile(
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
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Закрыть'),
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
        InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: () async {
            final p = await showDatePicker(
              context: context,
              initialDate: _expiresOn ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              helpText: 'Срок годности',
            );
            if (p != null) setState(() => _expiresOn = p);
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Срок годности'),
            child: Text(
              _expiresOn == null ? 'Не указан' : formatDate(_expiresOn!),
            ),
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(
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
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(
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
    ],
  );
}
