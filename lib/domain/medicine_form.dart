/// Dosage form of a medicine. Stored by enum name, so adding a value later
/// needs no migration.
enum MedicineForm {
  tablet('Таблетки'),
  capsule('Капсулы'),
  syrup('Сироп'),
  solution('Раствор'),
  ointment('Мазь'),
  cream('Крем'),
  spray('Спрей'),
  drops('Капли'),
  powder('Порошок'),
  suppository('Суппозитории'),
  other('Другая');

  const MedicineForm(this.label);
  final String label;
}

/// Units offered in the add form. The column is free text, so this list can
/// grow without a migration.
const quantityUnits = <String>['шт.', 'мл', 'г', 'доз'];
