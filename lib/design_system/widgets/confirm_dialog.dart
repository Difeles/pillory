import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../tokens.dart';
import '../motion.dart';

/// Asks to confirm an action; true only when confirmed. [danger] colours
/// the confirm button for actions that delete or replace data.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool danger = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        Pressable(
          child: TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(cancelLabel ?? context.l10n.cancel),
          ),
        ),
        Pressable(
          child: FilledButton(
            style: danger
                ? FilledButton.styleFrom(
                    backgroundColor: context.colors.danger,
                    foregroundColor: context.colors.onDanger,
                  )
                : null,
            onPressed: () => Navigator.pop(c, true),
            child: Text(confirmLabel),
          ),
        ),
      ],
    ),
  );
  return ok == true;
}
