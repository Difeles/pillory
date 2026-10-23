import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/pill_view.dart';
import '../../design_system/widgets/quantity_stepper.dart';
import '../../design_system/widgets/status_badge.dart';
import '../../domain/errors.dart';
import '../../domain/medicine_form.dart';
import '../../domain/models.dart';
import '../../domain/pill_look.dart';
import '../../domain/stock_status.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
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
    final message = context.l10n.negativeStock;
    try {
      await ref
          .read(inventoryRepositoryProvider)
          .adjustQuantity(packageId: stock.primaryPackage.id, delta: delta);
    } on InsufficientStockException {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = stock.medicine;
    final package = stock.primaryPackage;
    final details = [
      if (medicine.form != null) context.l10n.form(medicine.form!),
      if (medicine.strength != null) medicine.strength!,
    ].join(' · ');
    // Archived medicines are left out of the stock checks.
    final today = DateTime.now();
    final assessment = archived ? null : assess(stock, today);
    final status = _status(context, assessment, today);
    final quantity = context.l10n.quantity(stock.totalQuantity, stock.unit);

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
              MedicineAvatar(form: medicine.form, look: medicine.look),
              const SizedBox(width: AppSpacing.ms),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medicine.name, style: AppType.cardTitle),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        style: AppType.body.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    if (status != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      status,
                    ],
                    if (assessment?.problem == StockProblem.expired) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.disposalHint,
                        style: AppType.caption.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!archived && assessment != null) ...[
            const SizedBox(height: AppSpacing.ms),
            _StockBar(stock: stock, problem: assessment.problem),
          ],
          const SizedBox(height: AppSpacing.ms),
          // Wraps instead of overflowing: with large text the stepper moves
          // under the label.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: AppSpacing.xs,
            children: [
              Text(
                context.l10n.stockLabel,
                style: AppType.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
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

/// Remaining share of the counted packages' initial quantity.
class _StockBar extends StatelessWidget {
  const _StockBar({required this.stock, required this.problem});

  final MedicineStock stock;
  final StockProblem? problem;

  @override
  Widget build(BuildContext context) {
    final initial = stock.counted.fold<double>(
      0,
      (sum, p) => sum + p.initialQuantity,
    );
    final share = initial <= 0
        ? 0.0
        : (stock.totalQuantity / initial).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: share,
        minHeight: 8,
        backgroundColor: context.colors.surfaceMid,
        color: switch (problem) {
          null => context.colors.primary,
          StockProblem.low ||
          StockProblem.expiringSoon => context.colors.warning,
          _ => context.colors.danger,
        },
      ),
    );
  }
}

/// The form's icon on its pastel square; shared by the card and the
/// medicine screen.
class MedicineAvatar extends StatelessWidget {
  const MedicineAvatar({super.key, required this.form, this.look});

  final MedicineForm? form;

  /// The pill the user drew; it replaces the form's icon.
  final PillLook? look;

  @override
  Widget build(BuildContext context) {
    final (icon, fill) = _formLook(form);
    final look = this.look;
    if (look != null) {
      return Container(
        width: AppSizes.avatar,
        height: AppSizes.avatar,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.colors.tint,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: PillView(look: look, size: AppSizes.avatarIcon + 14),
      );
    }
    return Container(
      width: AppSizes.avatar,
      height: AppSizes.avatar,
      decoration: BoxDecoration(
        color: fill ?? context.colors.tint,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Icon(
        icon,
        size: AppSizes.avatarIcon,
        // Dark on the light pastel in both appearances.
        color: form == null
            ? context.colors.primaryDeep
            : AppColors.textPrimary,
      ),
    );
  }
}

/// The icon of a form.
IconData medicineFormIcon(MedicineForm? form) => _formLook(form).$1;

/// Icon and pastel fill for a form; pastels are only ever backgrounds.
(IconData, Color?) _formLook(MedicineForm? form) => switch (form) {
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
  MedicineForm.other || null => (Icons.medical_services_outlined, null),
};

/// The single status of a card: the most important problem, else the
/// nearest expiry date.
StatusBadge? _status(BuildContext context, StockAssessment? a, DateTime today) {
  final l = context.l10n;
  if (a == null) return null;
  switch (a.problem) {
    case StockProblem.expired:
      return StatusBadge(
        label: l.expiredSince(formatDate(a.earliestExpired!)),
        icon: Icons.error_outline,
        tone: StatusTone.danger,
      );
    case StockProblem.expiringSoon:
      final days = daysUntil(a.nearestExpiring!, today);
      final when = days == 0 ? l.whenToday : l.whenInDays(days);
      return StatusBadge(
        label: l.expiringBadge(formatDate(a.nearestExpiring!), when),
        icon: Icons.schedule,
        tone: StatusTone.warning,
      );
    case StockProblem.out:
      return StatusBadge(
        label: l.outBadge,
        icon: Icons.remove_circle_outline,
        tone: StatusTone.danger,
      );
    case StockProblem.low:
      return StatusBadge(
        label: l.lowBadge(l.quantity(a.usable, a.stock.unit)),
        icon: Icons.trending_down,
        tone: StatusTone.warning,
      );
    case null:
      final expiry = a.stock.nearestExpiry;
      return expiry == null
          ? null
          : StatusBadge(
              label: l.goodUntil(formatDate(expiry)),
              icon: Icons.event_outlined,
            );
  }
}
