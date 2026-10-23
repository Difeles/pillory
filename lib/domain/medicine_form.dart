/// Dosage form of a medicine. Stored by enum name, so adding a value later
/// needs no migration.
enum MedicineForm {
  tablet,
  capsule,
  syrup,
  solution,
  ointment,
  cream,
  spray,
  drops,
  powder,
  suppository,
  other,
}

/// Units offered in the add form. The column is free text, so this list can
/// grow without a migration.
const quantityUnits = <String>['шт.', 'мл', 'г', 'доз'];

/// What a medicine is for. Stored by enum name.
enum MedicineCategory {
  painkiller,

  /// Merged into [painkiller] in the picker; kept so stored values still read.
  antipyretic,
  digestive,
  allergy,
  wounds,
  cold,
  sedative,
  cardio,
  antidepressant,
  hormonal,
  antibiotic,
  vitamins,
  other;

  /// What the add form offers, in display order.
  static final pickable = [
    for (final c in values)
      if (c != antipyretic) c,
  ];
}

/// Where a medicine is kept. Stored by enum name.
enum StorageSpot { home, fridge, bag }

/// How an intake relates to a meal; null on a schedule means "any time".
enum MealRelation { before, during, after }
