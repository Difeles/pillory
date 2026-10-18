import 'package:flutter/material.dart';

import '../../features/inventory/format.dart';
import '../tokens.dart';

/// A read-only field that opens the date picker. [onChanged] gets the
/// picked date, or null when cleared; a null [onChanged] disables the field.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helpText,
    this.firstDate,
    this.initialDate,
    this.icon = Icons.calendar_today_outlined,
    this.emptyText = 'Не указан',
    this.clearTooltip,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;

  /// The picker's heading; defaults to [label].
  final String? helpText;

  /// Earliest pickable date. Past dates stay pickable by default: people
  /// also record medicines that have already expired.
  final DateTime? firstDate;

  /// Where the picker opens when there is no [value].
  final DateTime? initialDate;
  final IconData icon;
  final String emptyText;

  /// When set, a filled field offers a clear button with this tooltip.
  final String? clearTooltip;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: DateTime(2100),
      helpText: helpText ?? label,
    );
    if (picked != null) onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: enabled ? () => _pick(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            enabled: enabled,
            suffixIcon: value != null && clearTooltip != null && enabled
                ? IconButton(
                    tooltip: clearTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: () => onChanged!(null),
                  )
                : Icon(icon),
          ),
          child: Text(value == null ? emptyText : formatDate(value!)),
        ),
      ),
    );
  }
}
