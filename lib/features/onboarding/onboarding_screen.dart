import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/motion.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/mascot_pill.dart';
import '../../domain/extras.dart';
import '../../l10n/l10n.dart';

/// Shown once on an empty first launch: what the app does, and the reminder
/// permission asked in context instead of out of the blue.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool askForReminders}) async {
    setState(() => _busy = true);
    final extras = ref.read(extrasRepositoryProvider);
    if (_name.text.trim().isNotEmpty) {
      await extras.setPref(PrefKey.name, _name.text.trim());
    }
    if (askForReminders) {
      await ref.read(reminderSchedulerProvider).requestPermission();
    }
    await extras.setPref(PrefKey.onboarded, 'true');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.lg),
          const Center(child: MascotPill(size: 96)),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text(
              context.l10n.welcomeTitle,
              textAlign: TextAlign.center,
              style: AppType.title,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.welcomeText,
            textAlign: TextAlign.center,
            style: AppType.body.copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Point(Icons.alarm, context.l10n.welcomeP1, context.l10n.welcomeP1t),
          _Point(
            Icons.medical_services_outlined,
            context.l10n.welcomeP2,
            context.l10n.welcomeP2t,
          ),
          _Point(
            Icons.lock_outline,
            context.l10n.welcomeP3,
            context.l10n.welcomeP3t,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _name,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: context.l10n.nameOptional),
          ),
          const SizedBox(height: AppSpacing.md),
          Pressable(
            child: FilledButton(
              onPressed: _busy ? null : () => _finish(askForReminders: true),
              child: Text(context.l10n.enableReminders),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Pressable(
            child: TextButton(
              onPressed: _busy ? null : () => _finish(askForReminders: false),
              child: Text(context.l10n.skipReminders),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Point extends StatelessWidget {
  const _Point(this.icon, this.title, this.text);

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.ms),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.colors.primary),
        const SizedBox(width: AppSpacing.ms),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppType.cardTitle),
              Text(
                text,
                style: AppType.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
