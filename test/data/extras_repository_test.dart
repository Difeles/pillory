import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/data/app_database.dart';
import 'package:pillory/data/drift_extras_repository.dart';
import 'package:pillory/data/drift_inventory_repository.dart';
import 'package:pillory/domain/extras.dart';
import 'package:pillory/domain/medicine_form.dart';
import 'package:pillory/domain/models.dart';

void main() {
  late AppDatabase db;
  late DriftExtrasRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftExtrasRepository(db);
  });
  tearDown(() => db.close());

  test('shopping: add, no duplicates, check, remove', () async {
    await repo.addShopping('Бинт');
    await repo.addShopping(' бинт ');
    await repo.addShopping('  ');
    var items = await repo.watchShopping().first;
    expect(items.map((i) => i.name), ['Бинт']);

    await repo.setChecked(items.single.id, true);
    items = await repo.watchShopping().first;
    expect(items.single.checked, isTrue);

    await repo.removeShopping(items.single.id);
    expect(await repo.watchShopping().first, isEmpty);
  });

  test('settings default to on and persist', () async {
    expect((await repo.watchPrefs().first).haptics, isTrue);
    await repo.setPref(PrefKey.haptics, 'false');
    await repo.setPref(PrefKey.name, 'Аня');
    await repo.setPref(PrefKey.name, 'Аня М');
    final p = await repo.watchPrefs().first;
    expect((p.haptics, p.confetti, p.name), (false, true, 'Аня М'));
  });

  test('a medicine keeps its category and storage', () async {
    final inventory = DriftInventoryRepository(db);
    await inventory.createMedicine(
      const NewMedicine(
        name: 'Нурофен',
        initialQuantity: 5,
        unit: 'шт.',
        category: MedicineCategory.painkiller,
        storage: StorageSpot.fridge,
      ),
    );
    final m = (await inventory.watchStock().first).single.medicine;
    expect(
      (m.category, m.storage),
      (MedicineCategory.painkiller, StorageSpot.fridge),
    );
    await inventory.updateMedicine(m.id, const MedicineEdit(name: 'Нурофен'));
    final cleared = (await inventory.watchStock().first).single.medicine;
    expect(cleared.category, isNull);
  });
}
