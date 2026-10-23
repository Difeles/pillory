import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/date_field.dart';
import '../../design_system/widgets/form_save_bar.dart';
import '../../design_system/widgets/pill_widgets.dart';
import '../../design_system/widgets/section_header.dart';
import '../../domain/errors.dart';
import '../../domain/medicine_form.dart';
import '../../domain/models.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../domain/pill_look.dart';
import 'format.dart';
import 'pill_look_editor.dart';
import 'medicine_card.dart';
import '../../design_system/motion.dart';

/// Creates a medicine, or edits the name, form and strength of [editing].
/// Packages and quantities are managed on the medicine's own screen.
class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key, this.editing});

  final Medicine? editing;

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _strength = TextEditingController();
  final _size = TextEditingController(text: '1');
  final _quantity = TextEditingController(text: '1');

  // Until the amount left is typed, it follows the size: usually it is full.
  bool _quantityTouched = false;
  final _threshold = TextEditingController();
  MedicineForm? _form;
  MedicineCategory? _category;
  StorageSpot? _storage;
  PillLook? _look;
  String _unit = quantityUnits.first;
  DateTime? _expiresOn;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e == null) return;
    _name.text = e.name;
    _strength.text = e.strength ?? '';
    _threshold.text = e.lowStockThreshold == null
        ? ''
        : formatQuantity(e.lowStockThreshold!);
    _form = e.form;
    _category = e.category;
    _storage = e.storage;
    _look = e.look ?? defaultLookFor(e.form);
  }

  @override
  void dispose() {
    _name.dispose();
    _strength.dispose();
    _size.dispose();
    _quantity.dispose();
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final problem = context.l10n.problem;
    try {
      final editing = widget.editing;
      if (editing != null) {
        await ref
            .read(inventoryRepositoryProvider)
            .updateMedicine(
              editing.id,
              MedicineEdit(
                name: _name.text,
                form: _form,
                strength: _strength.text,
                lowStockThreshold: parseQuantity(_threshold.text),
                category: _category,
                storage: _storage,
                look: _look,
              ),
            );
        navigator.pop();
        return;
      }
      final id = await ref
          .read(inventoryRepositoryProvider)
          .createMedicine(
            NewMedicine(
              name: _name.text,
              form: _form,
              strength: _strength.text,
              lowStockThreshold: parseQuantity(_threshold.text),
              category: _category,
              storage: _storage,
              look: _look,
              initialQuantity: parseQuantity(_quantity.text)!,
              packSize: parseQuantity(_size.text),
              unit: _unit,
              expiresOn: _expiresOn,
            ),
          );
      // The id lets a caller (the intake form) select the new medicine.
      navigator.pop(id);
    } on InvalidMedicineException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(problem(e.message))));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.md);
    final creating = widget.editing == null;
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(creating ? l.newMedicine : l.medicineTitle)),
      bottomNavigationBar: FormSaveBar(
        saving: _saving,
        onSave: _save,
        label: creating ? l.addToCabinet : l.save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            SectionHeader(title: l.secBasic),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.nameLabel,
                hintText: l.nameHint,
                prefixIcon: const Icon(Icons.medication_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.enterName : null,
            ),
            SectionHeader(title: l.secCategory),
            // Two columns, so words wrap at spaces; the tiles of a row share
            // one height and grow with the text.
            for (var i = 0; i < MedicineCategory.pickable.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final c in MedicineCategory.pickable.skip(i).take(2))
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: c == MedicineCategory.pickable[i]
                                  ? AppSpacing.sm
                                  : 0,
                            ),
                            child: ChoiceTile(
                              icon: _categoryIcon(c),
                              label: l.category(c),
                              selected: _category == c,
                              onTap: () => setState(
                                () => _category = _category == c ? null : c,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            SectionHeader(title: l.secForm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final f in MedicineForm.values)
                  Pressable(
                    scale: .93,
                    child: ChoiceChip(
                      avatar: Icon(medicineFormIcon(f), size: 18),
                      label: Text(l.form(f)),
                      selected: _form == f,
                      onSelected: (_) => setState(() {
                        _form = _form == f ? null : f;
                        // Tablets and capsules are drawn; a capsule is never
                        // a tablet's shape, so a switch starts over.
                        final start = defaultLookFor(_form);
                        if (start == null ||
                            _look?.isCapsule != start.isCapsule) {
                          _look = start;
                        }
                      }),
                    ),
                  ),
              ],
            ),
            if (_look != null) ...[
              gap,
              PillLookEditor(
                look: _look!,
                onChanged: (v) => setState(() => _look = v),
              ),
            ],
            gap,
            TextFormField(
              controller: _strength,
              decoration: InputDecoration(
                labelText: l.strengthLabel,
                hintText: l.strengthHint,
              ),
            ),
            SectionHeader(title: l.secStorage),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final st in StorageSpot.values)
                  Pressable(
                    scale: .93,
                    child: ChoiceChip(
                      avatar: Icon(_storageIcon(st), size: 18),
                      label: Text(l.storage(st)),
                      selected: _storage == st,
                      onSelected: (_) =>
                          setState(() => _storage = _storage == st ? null : st),
                    ),
                  ),
              ],
            ),
            SectionHeader(title: l.secStock),
            if (creating) ...[
              TextFormField(
                controller: _size,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l.packSizeLabel,
                  suffixText: l.unit(_unit),
                ),
                onChanged: (v) {
                  if (!_quantityTouched) _quantity.text = v;
                },
                validator: (v) {
                  final q = parseQuantity(v ?? '');
                  return (q == null || !q.isFinite || q < 0)
                      ? l.enterNumberZero
                      : null;
                },
              ),
              gap,
              TextFormField(
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l.packLeftLabel,
                  suffixText: l.unit(_unit),
                ),
                onChanged: (_) => _quantityTouched = true,
                validator: (v) {
                  final q = parseQuantity(v ?? '');
                  if (q == null || !q.isFinite || q < 0) {
                    return l.enterNumberZero;
                  }
                  final size = parseQuantity(_size.text);
                  return size != null && q > size ? l.pPackSmaller : null;
                },
              ),
              gap,
              // Its own line: next to the quantity it overflows at large text.
              Text(
                l.unitLabel,
                style: AppType.caption.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SegmentedPills<String>(
                options: {for (final u in quantityUnits) u: l.unit(u)},
                selected: _unit,
                onChanged: (v) => setState(() => _unit = v),
              ),
              gap,
              DateField(
                label: l.expiryLabel,
                value: _expiresOn,
                clearTooltip: l.clearExpiry,
                onChanged: (d) => setState(() => _expiresOn = d),
              ),
              gap,
            ],
            TextFormField(
              controller: _threshold,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l.thresholdLabel,
                helperText: l.thresholdHelper,
                suffixText: l.unit(widget.editing?.unit ?? _unit),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final q = parseQuantity(v);
                return (q == null || !q.isFinite || q < 0)
                    ? l.enterNumberZero
                    : null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

IconData _categoryIcon(MedicineCategory c) => switch (c) {
  MedicineCategory.painkiller => Icons.bolt,
  MedicineCategory.antipyretic => Icons.thermostat,
  MedicineCategory.digestive => Icons.lunch_dining_outlined,
  MedicineCategory.allergy => Icons.local_florist_outlined,
  MedicineCategory.wounds => Icons.healing_outlined,
  MedicineCategory.cold => Icons.ac_unit,
  MedicineCategory.sedative => Icons.spa_outlined,
  MedicineCategory.cardio => Icons.favorite_border,
  MedicineCategory.other => Icons.more_horiz,
  MedicineCategory.antidepressant => Icons.mood_outlined,
  MedicineCategory.hormonal => Icons.female,
  MedicineCategory.antibiotic => Icons.coronavirus_outlined,
  MedicineCategory.vitamins => Icons.eco_outlined,
};

IconData _storageIcon(StorageSpot s) => switch (s) {
  StorageSpot.home => Icons.home_outlined,
  StorageSpot.fridge => Icons.kitchen_outlined,
  StorageSpot.bag => Icons.backpack_outlined,
};
