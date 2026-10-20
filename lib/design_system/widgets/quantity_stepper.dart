import 'package:flutter/material.dart';

import '../tokens.dart';
import '../motion.dart';

/// − value +. A null callback disables its button (e.g. − at zero).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.decrementTooltip = 'Уменьшить остаток',
    this.incrementTooltip = 'Увеличить остаток',
  });

  /// Already formatted, with the unit: "12 шт.".
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String decrementTooltip;
  final String incrementTooltip;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Pressable(
        scale: .88,
        child: IconButton.filledTonal(
          tooltip: decrementTooltip,
          onPressed: onDecrement,
          icon: const Icon(Icons.remove),
        ),
      ),
      Flexible(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            value,
            style: AppType.numeric,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      Pressable(
        scale: .88,
        child: IconButton.filledTonal(
          tooltip: incrementTooltip,
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
        ),
      ),
    ],
  );
}
