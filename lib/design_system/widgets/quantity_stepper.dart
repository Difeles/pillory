import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../tokens.dart';
import '../motion.dart';

/// − value +. A null callback disables its button (e.g. − at zero).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  /// Already formatted, with the unit: "12 шт.".
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Pressable(
        scale: .88,
        child: IconButton.filledTonal(
          tooltip: context.l10n.decreaseStock,
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
          tooltip: context.l10n.increaseStock,
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
        ),
      ),
    ],
  );
}
