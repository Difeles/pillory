import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/quantity_stepper.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../domain/errors.dart';
import '../../domain/medicine_form.dart';
import '../../domain/models.dart';
import '../../domain/stock_status.dart';
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
    // Archived medicines are left out of the stock checks.
    final today = DateTime.now();
    final assessment = archived ? null : assess(stock, today);
    final status = _status(assessment, today);
    final quantity = '${formatQuantity(stock.totalQuantity)} ${stock.unit}';

    // +/- act on one package, so they are offered only when there is one.
    final quick = !archived && stock.packages.length == 1;
    return AppCard(
      variant: archived ? AppCardVariant.muted : AppCardVariant.normal,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => MedicineScreen(medicineId: medicine.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    Text(medicine.name, style: text.titleMedium),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (status != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      status,
                    ],
                    if (assessment?.problem == StockProblem.expired) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Проверьте инструкцию и местные правила утилизации',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.ms),
          // Wraps instead of overflowing: with large text the stepper moves
          // under the label.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                'Остаток',
                style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              if (quick)
                QuantityStepper(
                  value: quantity,
                  onDecrement: package.quantity > 0
                      ? () => _change(context, ref, -1)
                      : null,
                  onIncrement: () => _change(context, ref, 1),
                )
              else
                Text(quantity, style: AppType.numeric),
            ],
          ),
        ],
      ),
    );
  }
}

/// The form's icon on its pastel square; shared by the card and the
/// medicine screen.
class MedicineAvatar extends StatelessWidget {
  const MedicineAvatar({super.key, required this.form});

  final MedicineForm? form;

  @override
  Widget build(BuildContext context) {
    final (icon, fill) = _formLook(form);
    return Container(
      width: AppSizes.avatar,
      height: AppSizes.avatar,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Icon(
        icon,
        size: AppSizes.avatarIcon,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// Icon and pastel fill for a form; pastels are only ever backgrounds.
(IconData, Color) _formLook(MedicineForm? form) => switch (form) {
  MedicineForm.tablet ||
  MedicineForm.capsule ||
  MedicineForm.suppository => (Icons.medication_outlined, AppColors.pink),
  MedicineForm.syrup ||
  MedicineForm.solution => (Icons.medication_liquid_outlined, AppColors.blue),
  MedicineForm.drops => (Icons.water_drop_outlined, AppColors.blue),
  MedicineForm.ointment ||
  MedicineForm.cream => (Icons.healing_outlined, AppColors.mint),
  MedicineForm.spray => (Icons.sanitizer_outlined, AppColors.mint),
  MedicineForm.powder => (Icons.grain, AppColors.orange),
  MedicineForm.other ||
  null => (Icons.medical_services_outlined, AppColors.tint),
};

/// The single status of a card: the most important problem, else the
/// nearest expiry date.
StatusBadge? _status(StockAssessment? a, DateTime today) {
  if (a == null) return null;
  switch (a.problem) {
    case StockProblem.expired:
      return StatusBadge(
        label: 'Просрочено с ${formatDate(a.earliestExpired!)}',
        icon: Icons.error_outline,
        tone: StatusTone.danger,
      );
    case StockProblem.expiringSoon:
      final days = daysUntil(a.nearestExpiring!, today);
      final when = days == 0 ? 'сегодня' : 'через $days дн.';
      return StatusBadge(
        label: 'Скоро истекает: до ${formatDate(a.nearestExpiring!)} ($when)',
        icon: Icons.schedule,
        tone: StatusTone.warning,
      );
    case StockProblem.out:
      return const StatusBadge(
        label: 'Закончилось',
        icon: Icons.remove_circle_outline,
        tone: StatusTone.danger,
      );
    case StockProblem.low:
      return StatusBadge(
        label: 'Мало: осталось ${formatQuantity(a.usable)} ${a.stock.unit}',
        icon: Icons.trending_down,
        tone: StatusTone.warning,
      );
    case null:
      final expiry = a.stock.nearestExpiry;
      return expiry == null
          ? null
          : StatusBadge(
              label: 'Годен до ${formatDate(expiry)}',
              icon: Icons.event_outlined,
            );
  }
}
