import 'package:flutter/material.dart';

import '../tokens.dart';
import '../motion.dart';

/// Body padding for a scrolling form.
const formPadding = EdgeInsets.fromLTRB(
  AppSpacing.md,
  0,
  AppSpacing.md,
  AppSpacing.lg,
);

/// "Сохранить", pinned under a form: goes in [Scaffold.bottomNavigationBar],
/// so snack bars float above it instead of covering it, and lifts itself
/// over the keyboard, which that slot does not do on its own.
class FormSaveBar extends StatelessWidget {
  const FormSaveBar({
    super.key,
    required this.onSave,
    this.saving = false,
    this.label = 'Сохранить',
  });

  final String label;

  final VoidCallback onSave;

  /// Disables the button while a save is running.
  final bool saving;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: DecoratedBox(
      decoration: BoxDecoration(color: context.colors.background),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.ms,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Pressable(
              scale: .97,
              child: FilledButton.icon(
                onPressed: saving ? null : onSave,
                icon: const Icon(Icons.check),
                label: Text(label),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
