import 'package:flutter/material.dart';

import '../tokens.dart';

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
  const FormSaveBar({super.key, required this.onSave, this.saving = false});

  final VoidCallback onSave;

  /// Disables the button while a save is running.
  final bool saving;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.ms,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: saving ? null : onSave,
              child: const Text('Сохранить'),
            ),
          ),
        ),
      ),
    ),
  );
}
