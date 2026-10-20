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

/// What a medicine is for. Stored by enum name.
enum MedicineCategory {
  painkiller('Обезболивающие'),
  antipyretic('Жаропонижающие'),
  digestive('ЖКТ'),
  allergy('Аллергия'),
  vitamins('Витамины'),
  cold('Простуда'),
  other('Другое');

  const MedicineCategory(this.label);
  final String label;
}

/// Where a medicine is kept. Stored by enum name.
enum StorageSpot {
  home('Домашняя аптечка'),
  fridge('Холодильник'),
  bag('С собой');

  const StorageSpot(this.label);
  final String label;
}

/// How an intake relates to a meal; null on a schedule means "any time".
enum MealRelation {
  before('До еды'),
  during('Во время'),
  after('После еды');

  const MealRelation(this.label);
  final String label;
}
