import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/motion.dart';
import '../../design_system/pickers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/date_field.dart';
import '../../design_system/widgets/form_save_bar.dart';
import '../../design_system/widgets/pill_widgets.dart';
import '../../domain/diary.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../today/today_screen.dart' show formatMinute;
import 'diary_screen.dart';

class AddDiaryScreen extends ConsumerStatefulWidget {
  /// [day] is the day to write the entry for (now, if null).
  const AddDiaryScreen({super.key, this.day});

  final DateTime? day;

  @override
  ConsumerState<AddDiaryScreen> createState() => _AddDiaryScreenState();
}

class _AddDiaryScreenState extends ConsumerState<AddDiaryScreen> {
  final _note = TextEditingController();
  int? _mood;
  final _symptoms = <String>{};
  late DateTime _at = () {
    final now = DateTime.now();
    final d = widget.day;
    return d == null
        ? now
        : DateTime(d.year, d.month, d.day, now.hour, now.minute);
  }();
  int _migraine = 0;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final entry = NewDiaryEntry(
      at: _at,
      mood: _mood,
      symptoms: _symptoms.toList(),
      // Only a headache can be a migraine.
      migraine: _migraine == 0 || !_symptoms.contains('headache')
          ? null
          : _migraine,
      note: _note.text,
    );
    final problem = validateDiaryEntry(entry);
    if (problem != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.problem(problem))));
      return;
    }
    await ref.read(diaryRepositoryProvider).add(entry);
    navigator.pop();
  }

  Future<void> _addOwn() async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _OwnSymptomDialog(),
    );
    if (text != null && text.isNotEmpty) setState(() => _symptoms.add(text));
  }

  Future<void> _pickTime() async {
    final t = await pickTime(
      context,
      initial: TimeOfDay(hour: _at.hour, minute: _at.minute),
    );
    if (t != null) {
      setState(
        () => _at = DateTime(_at.year, _at.month, _at.day, t.hour, t.minute),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.newEntry)),
    bottomNavigationBar: FormSaveBar(onSave: _save),
    body: ListView(
      padding: formPadding,
      children: [
        Text(context.l10n.howDoYouFeel, style: AppType.cardTitle),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < moodIcons.length; i++)
              Pressable(
                scale: .88,
                child: IconButton.filledTonal(
                  tooltip: moodName(context.l10n, i + 1),
                  isSelected: _mood == i + 1,
                  style: IconButton.styleFrom(
                    backgroundColor: _mood == i + 1
                        ? context.colors.primary
                        : context.colors.surfaceLow,
                    foregroundColor: _mood == i + 1
                        ? context.colors.onPrimary
                        : context.colors.textSecondary,
                  ),
                  iconSize: 30,
                  icon: Icon(moodIcons[i]),
                  onPressed: () =>
                      setState(() => _mood = _mood == i + 1 ? null : i + 1),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: DateField(
                label: context.l10n.date,
                value: _at,
                onChanged: (d) => setState(
                  () => d == null
                      ? null
                      : _at = DateTime(
                          d.year,
                          d.month,
                          d.day,
                          _at.hour,
                          _at.minute,
                        ),
                ),
              ),
            ),
            Pressable(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text(formatMinute(_at.hour * 60 + _at.minute)),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(context.l10n.symptomsTitle, style: AppType.cardTitle),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final key in [
              ...diarySymptoms,
              ..._symptoms.where((s) => !diarySymptoms.contains(s)),
            ])
              Pressable(
                scale: .93,
                child: FilterChip(
                  label: Text(context.l10n.symptom(key)),
                  selected: _symptoms.contains(key),
                  onSelected: (on) => setState(
                    () => on ? _symptoms.add(key) : _symptoms.remove(key),
                  ),
                ),
              ),
            Pressable(
              scale: .93,
              child: ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: Text(context.l10n.symptomOther),
                onPressed: _addOwn,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_symptoms.contains('headache')) ...[
          Text(context.l10n.migraineTitle, style: AppType.cardTitle),
          const SizedBox(height: AppSpacing.sm),
          SegmentedPills<int>(
            options: {
              0: context.l10n.migraineNone,
              for (var i = 1; i <= 3; i++) i: context.l10n.migraine(i),
            },
            selected: _migraine,
            onChanged: (v) => setState(() => _migraine = v),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextField(
          controller: _note,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: context.l10n.noteLabel),
        ),
      ],
    ),
  );
}

/// Owns its controller, so it is disposed with the dialog.
class _OwnSymptomDialog extends StatefulWidget {
  const _OwnSymptomDialog();

  @override
  State<_OwnSymptomDialog> createState() => _OwnSymptomDialogState();
}

class _OwnSymptomDialogState extends State<_OwnSymptomDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.symptomOwnTitle),
    content: TextField(
      controller: _c,
      autofocus: true,
      maxLength: 40,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: context.l10n.symptomOwnLabel),
    ),
    actions: [
      Pressable(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
      ),
      Pressable(
        child: FilledButton(
          onPressed: () => Navigator.pop(context, _c.text.trim()),
          child: Text(context.l10n.save),
        ),
      ),
    ],
  );
}
