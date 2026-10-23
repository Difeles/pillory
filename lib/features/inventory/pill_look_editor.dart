import 'package:flutter/material.dart';

import '../../design_system/motion.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/pill_view.dart';
import '../../domain/medicine_form.dart';
import '../../domain/pill_look.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';

/// The pill a tablet or capsule starts with; null for other forms, which
/// keep their icon.
PillLook? defaultLookFor(MedicineForm? form) => switch (form) {
  MedicineForm.tablet => const PillLook(),
  MedicineForm.capsule => const PillLook(shape: PillShape.capsule),
  _ => null,
};

/// Draws a medicine's pill: shape, colours and score, with a live preview.
/// Shown for tablets and capsules; a capsule's shape is fixed.
class PillLookEditor extends StatelessWidget {
  const PillLookEditor({
    super.key,
    required this.look,
    required this.onChanged,
  });

  final PillLook look;
  final ValueChanged<PillLook> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.drawPill, style: AppType.cardTitle),
        ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.tint,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: PillView(look: look, size: 72),
            ),
          ),
          if (!look.isCapsule) ...[
            const SizedBox(height: AppSpacing.md),
            Text(l.pillShape, style: AppType.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final s in PillShape.values.where(
                  (s) => s != PillShape.capsule,
                ))
                  Pressable(
                    scale: .93,
                    child: ChoiceChip(
                      avatar: PillView(look: look.copyWith(shape: s), size: 22),
                      label: Text(l.shape(s)),
                      selected: look.shape == s,
                      onSelected: (_) => onChanged(look.copyWith(shape: s)),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(l.pillColor, style: AppType.label),
          const SizedBox(height: AppSpacing.sm),
          _Swatches(
            selected: look.color,
            onSelected: (c) => onChanged(look.copyWith(color: c)),
          ),
          if (look.isCapsule) ...[
            const SizedBox(height: AppSpacing.md),
            Text(l.pillColor2, style: AppType.label),
            const SizedBox(height: AppSpacing.sm),
            _Swatches(
              selected: look.color2 ?? look.color,
              onSelected: (c) => onChanged(look.copyWith(color2: () => c)),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            Text(l.pillScore, style: AppType.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final s in PillScore.values)
                  Pressable(
                    scale: .93,
                    child: ChoiceChip(
                      avatar: PillView(look: look.copyWith(score: s), size: 22),
                      label: Text(l.score(s)),
                      selected: look.score == s,
                      onSelected: (_) => onChanged(look.copyWith(score: s)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final (i, c) in pillColors.indexed)
        Semantics(
          button: true,
          selected: c == selected,
          label: context.l10n.colorSwatch(i + 1),
          child: Pressable(
            scale: .88,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(c),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c == selected
                          ? context.colors.primary
                          : context.colors.inputBorder,
                      width: c == selected ? 3 : 1,
                    ),
                  ),
                  child: c == selected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color:
                              ThemeData.estimateBrightnessForColor(Color(c)) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
