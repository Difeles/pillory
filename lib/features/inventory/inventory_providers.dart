import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models.dart';

/// The cabinet list, live from the database.
final medicineStockProvider = StreamProvider<List<MedicineStock>>(
  (ref) => ref.watch(inventoryRepositoryProvider).watchStock(),
);
