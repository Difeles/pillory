import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../domain/errors.dart';
import '../../domain/inventory_rules.dart';
import '../../domain/models.dart';
import 'format.dart';
import 'medicine_screen.dart';

class MedicineCard extends ConsumerWidget {
  const MedicineCard({super.key, required this.stock, this.archived = false});

  final MedicineStock stock;
  final bool archived;

  Future<void> _change(
    BuildContext context,
    WidgetRef ref,
    double delta,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .adjustQuantity(packageId: stock.primaryPackage.id, delta: delta);
    } on InsufficientStockException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Остаток не может быть отрицательным')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final medicine = stock.medicine;
    final package = stock.primaryPackage;
    final details = [
      if (medicine.form != null) medicine.form!.label,
      if (medicine.strength != null) medicine.strength!,
    ].join(' · ');
    final expiry = package.expiresOn;
    final expired = isExpired(expiry, DateTime.now());

    // +/- act on one package, so they are offered only when there is one.
    final quick = !archived && stock.packages.length == 1;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MedicineScreen(medicineId: medicine.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (details.isNotEmpty)
                    Text(
                      details,
                      style: text.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  if (expiry != null)
                    Text(
                      expired
                          ? 'Срок годности истёк ${formatDate(expiry)}'
                          : 'Годен до ${formatDate(expiry)}',
                      style: text.bodySmall?.copyWith(
                        color: expired
                            ? AppColors.danger
                            : AppColors.textSecondary,
                      ),
                    ),
                  if (expired)
                    Text(
                      'Проверьте инструкцию и местные правила утилизации',
                      style: text.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (quick)
              IconButton.filledTonal(
                tooltip: 'Уменьшить остаток',
                onPressed: package.quantity > 0
                    ? () => _change(context, ref, -1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                '${formatQuantity(stock.totalQuantity)} ${stock.unit}',
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (quick)
              IconButton.filledTonal(
                tooltip: 'Увеличить остаток',
                onPressed: () => _change(context, ref, 1),
                icon: const Icon(Icons.add),
              ),
          ],
        ),
      ),
    );
  }
}
