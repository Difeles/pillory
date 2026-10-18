import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../design_system/tokens.dart';
import '../../design_system/widgets/date_field.dart';
import '../../design_system/widgets/form_save_bar.dart';
import '../../design_system/widgets/section_header.dart';
import '../../domain/errors.dart';
import '../../domain/medicine_form.dart';
import '../../domain/models.dart';
import 'format.dart';

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
      bottomNavigationBar: FormSaveBar(saving: _saving, onSave: _save),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            const SectionHeader(title: 'Основное'),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Название *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите название' : null,
            ),
            gap,
            DropdownButtonFormField<MedicineForm?>(
              initialValue: _form,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Лекарственная форма',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Не указана')),
                for (final f in MedicineForm.values)
                  DropdownMenuItem(value: f, child: Text(f.label)),
              ],
              onChanged: (v) => setState(() => _form = v),
            ),
            gap,
            TextFormField(
              controller: _strength,
              decoration: const InputDecoration(
                labelText: 'Дозировка или концентрация',
                hintText: 'Например, 500 мг',
              ),
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
              DropdownButtonFormField<String>(
                initialValue: _unit,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Единица'),
                items: [
                  for (final u in quantityUnits)
                    DropdownMenuItem(value: u, child: Text(u)),
                ],
                onChanged: (v) => setState(() => _unit = v ?? _unit),
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
