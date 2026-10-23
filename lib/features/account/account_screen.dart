import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/cloud_sync.dart';
import '../../app/providers.dart';
import '../../cloud/cloud_service.dart';
import '../../design_system/motion.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/app_card.dart';
import '../../l10n/l10n.dart';

/// The account: sign in or create one, and what the cloud copy is doing.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _authMessage(CloudAuthProblem p) {
    final l = context.l10n;
    return switch (p) {
      CloudAuthProblem.invalidEmail => l.authInvalidEmail,
      CloudAuthProblem.wrongCredentials => l.authWrongCredentials,
      CloudAuthProblem.emailInUse => l.authEmailInUse,
      CloudAuthProblem.weakPassword => l.authWeakPassword,
      CloudAuthProblem.network => l.authNetwork,
      CloudAuthProblem.tooManyRequests => l.authTooMany,
      CloudAuthProblem.other => l.authOther,
    };
  }

  /// Runs an account call and shows its failure instead of throwing.
  Future<void> _run(Future<void> Function() call) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await call();
    } on CloudAuthException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_authMessage(e.problem))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _filled() {
    if (_email.text.trim().isNotEmpty && _password.text.isNotEmpty) return true;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.enterEmailPassword)));
    return false;
  }

  Future<void> _reset() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_email.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l.enterEmail)));
      return;
    }
    await _run(() async {
      await ref.read(cloudServiceProvider).sendPasswordReset(_email.text);
      messenger.showSnackBar(SnackBar(content: Text(l.resetSent)));
    });
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final sync = ref.read(cloudSyncProvider);
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _PasswordDialog(),
    );
    if (password == null) return;
    await _run(() async {
      await sync.deleteAccount(password);
      messenger.showSnackBar(SnackBar(content: Text(l.accountDeleted)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cloud = ref.watch(cloudServiceProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.accountTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (!cloud.available)
            AppCard(child: Text(l.accountNotAvailable))
          else
            Builder(
              builder: (context) {
                final sync = ref.watch(cloudSyncProvider);
                return ValueListenableBuilder(
                  valueListenable: sync.state,
                  builder: (context, state, _) => state.user == null
                      ? _signedOut(l)
                      : _signedIn(l, sync, state),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _signedOut(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        l.accountIntro,
        style: AppType.body.copyWith(color: context.colors.textSecondary),
      ),
      const SizedBox(height: AppSpacing.md),
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        decoration: InputDecoration(labelText: l.emailLabel),
      ),
      const SizedBox(height: AppSpacing.sm),
      TextField(
        controller: _password,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        decoration: InputDecoration(labelText: l.passwordLabel),
      ),
      const SizedBox(height: AppSpacing.md),
      Pressable(
        child: FilledButton(
          onPressed: _busy
              ? null
              : () {
                  if (!_filled()) return;
                  _run(
                    () => ref
                        .read(cloudServiceProvider)
                        .signIn(_email.text, _password.text),
                  );
                },
          child: Text(l.signIn),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Pressable(
        child: OutlinedButton(
          onPressed: _busy
              ? null
              : () {
                  if (!_filled()) return;
                  _run(
                    () => ref
                        .read(cloudServiceProvider)
                        .register(_email.text, _password.text),
                  );
                },
          child: Text(l.createAccount),
        ),
      ),
      Pressable(
        child: TextButton(
          onPressed: _busy ? null : _reset,
          child: Text(l.forgotPassword),
        ),
      ),
    ],
  );

  Widget _signedIn(AppLocalizations l, CloudSync sync, CloudSyncState s) {
    final status = switch (s.phase) {
      CloudPhase.syncing => l.syncing,
      CloudPhase.error => switch (s.problem) {
        CloudSyncProblem.tooLarge => l.syncProblemTooLarge,
        CloudSyncProblem.other => l.syncProblemOther,
        _ => l.syncProblemNetwork,
      },
      _ =>
        s.syncedAt == null
            ? l.syncedJustNow
            : l.syncedAt(
                MaterialLocalizations.of(context).formatTimeOfDay(
                  TimeOfDay.fromDateTime(s.syncedAt!),
                  alwaysUse24HourFormat: true,
                ),
              ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.signedInAs(s.user!.email), style: AppType.cardTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                status,
                style: AppType.caption.copyWith(
                  color: s.phase == CloudPhase.error
                      ? context.colors.danger
                      : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (s.phase == CloudPhase.conflict) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.conflictTitle, style: AppType.cardTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(l.conflictText),
                const SizedBox(height: AppSpacing.md),
                Pressable(
                  child: FilledButton(
                    onPressed: () => sync.resolve(useCloud: true),
                    child: Text(l.useCloudData),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Pressable(
                  child: OutlinedButton(
                    onPressed: () => sync.resolve(useCloud: false),
                    child: Text(l.useDeviceData),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Pressable(
          child: FilledButton.tonalIcon(
            onPressed: s.phase == CloudPhase.syncing ? null : sync.syncNow,
            icon: const Icon(Icons.sync),
            label: Text(l.syncNow),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Pressable(
          child: OutlinedButton(
            onPressed: _busy ? null : sync.signOut,
            child: Text(l.signOut),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(l.signOutNote, style: AppType.caption),
        ),
        const SizedBox(height: AppSpacing.md),
        Pressable(
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
            onPressed: _busy ? null : _delete,
            child: Text(l.deleteAccount),
          ),
        ),
      ],
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.deleteAccountTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.deleteAccountText),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _c,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(labelText: l.passwordLabel),
          ),
        ],
      ),
      actions: [
        Pressable(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
        ),
        Pressable(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.danger,
              foregroundColor: context.colors.onDanger,
            ),
            onPressed: () => Navigator.pop(context, _c.text),
            child: Text(l.deleteAccount),
          ),
        ),
      ],
    );
  }
}
