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
import 'format.dart';
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
  final _quantity = TextEditingController(text: '1');
  final _threshold = TextEditingController();
  MedicineForm? _form;
  MedicineCategory? _category;
  StorageSpot? _storage;
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
  }

  @override
  void dispose() {
    _name.dispose();
    _strength.dispose();
    _quantity.dispose();
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
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
              initialQuantity: parseQuantity(_quantity.text)!,
              unit: _unit,
              expiresOn: _expiresOn,
            ),
          );
      // The id lets a caller (the intake form) select the new medicine.
      navigator.pop(id);
    } on InvalidMedicineException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.md);
    final creating = widget.editing == null;
    return Scaffold(
      appBar: AppBar(title: Text(creating ? 'Новое лекарство' : 'Лекарство')),
      bottomNavigationBar: FormSaveBar(
        saving: _saving,
        onSave: _save,
        label: creating ? 'Добавить в аптечку' : 'Сохранить',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            if (creating) ...[const _ScannerCard(), gap],
            const SectionHeader(title: 'Основное'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Название *',
                hintText: 'Например, Ибупрофен Форте',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите название' : null,
            ),
            const SectionHeader(title: 'Категория действия'),
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
                              label: c.label,
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
            const SectionHeader(title: 'Форма выпуска'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final f in MedicineForm.values)
                  Pressable(
                    scale: .93,
                    child: ChoiceChip(
                      avatar: Icon(medicineFormIcon(f), size: 18),
                      label: Text(f.label),
                      selected: _form == f,
                      onSelected: (_) =>
                          setState(() => _form = _form == f ? null : f),
                    ),
                  ),
              ],
            ),
            gap,
            TextFormField(
              controller: _strength,
              decoration: const InputDecoration(
                labelText: 'Дозировка или концентрация',
                hintText: 'Например, 500 мг',
              ),
            ),
            const SectionHeader(title: 'Где хранить?'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final st in StorageSpot.values)
                  Pressable(
                    scale: .93,
                    child: ChoiceChip(
                      avatar: Icon(_storageIcon(st), size: 18),
                      label: Text(st.label),
                      selected: _storage == st,
                      onSelected: (_) =>
                          setState(() => _storage = _storage == st ? null : st),
                    ),
                  ),
              ],
            ),
            const SectionHeader(title: 'Запас'),
            if (creating) ...[
              TextFormField(
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Начальное количество',
                  suffixText: _unit,
                ),
                validator: (v) {
                  final q = parseQuantity(v ?? '');
                  return (q == null || !q.isFinite || q < 0)
                      ? 'Введите число 0 или больше'
                      : null;
                },
              ),
              gap,
              // Its own line: next to the quantity it overflows at large text.
              Text(
                'Единица',
                style: AppType.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              SegmentedPills<String>(
                options: {for (final u in quantityUnits) u: u},
                selected: _unit,
                onChanged: (v) => setState(() => _unit = v),
              ),
              gap,
              DateField(
                label: 'Срок годности',
                value: _expiresOn,
                clearTooltip: 'Убрать срок годности',
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
                labelText: 'Порог низкого остатка (необязательно)',
                helperText: 'По умолчанию: 20% от самой большой упаковки',
                suffixText: widget.editing?.unit ?? _unit,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final q = parseQuantity(v);
                return (q == null || !q.isFinite || q < 0)
                    ? 'Введите число 0 или больше'
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

/// Barcode scanning is not built yet.
class _ScannerCard extends StatelessWidget {
  const _ScannerCard();

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.tint,
    shape: RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(AppRadii.lg),
    ),
    child: Pressable(
      scale: .98,
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        title: const Text('Сканировать пачку', style: AppType.cardTitle),
        subtitle: const Text('Название и срок годности по штрихкоду — скоро'),
        trailing: const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.qr_code_scanner, color: Colors.white),
        ),
        onTap: () => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Сканер — скоро'))),
      ),
    ),
  );
}
