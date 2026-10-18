// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, MedicineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MedicineForm?, String> form =
      GeneratedColumn<String>(
        'form',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<MedicineForm?>($MedicinesTable.$converterformn);
  static const VerificationMeta _strengthMeta = const VerificationMeta(
    'strength',
  );
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
    'strength',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lowStockThresholdMeta = const VerificationMeta(
    'lowStockThreshold',
  );
  @override
  late final GeneratedColumn<double> lowStockThreshold =
      GeneratedColumn<double>(
        'low_stock_threshold',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    form,
    strength,
    unit,
    lowStockThreshold,
    archivedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('strength')) {
      context.handle(
        _strengthMeta,
        strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
        _lowStockThresholdMeta,
        lowStockThreshold.isAcceptableOrUnknown(
          data['low_stock_threshold']!,
          _lowStockThresholdMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      form: $MedicinesTable.$converterformn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}form'],
        ),
      ),
      strength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      lowStockThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}low_stock_threshold'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MedicineForm, String, String> $converterform =
      const EnumNameConverter<MedicineForm>(MedicineForm.values);
  static JsonTypeConverter2<MedicineForm?, String?, String?> $converterformn =
      JsonTypeConverter2.asNullable($converterform);
}

class MedicineRow extends DataClass implements Insertable<MedicineRow> {
  final String id;
  final String name;
  final MedicineForm? form;
  final String? strength;

  /// The one unit all packages of this medicine are counted in. Nullable only
  /// because older rows are filled in by the v5 migration.
  final String? unit;

  /// Own low-stock threshold, in the medicine's unit. Null: use the app rule
  /// (a share of the biggest package).
  final double? lowStockThreshold;

  /// Set when the medicine is archived: hidden from the cabinet, nothing is
  /// deleted.
  final DateTime? archivedAt;
  final DateTime createdAt;
  const MedicineRow({
    required this.id,
    required this.name,
    this.form,
    this.strength,
    this.unit,
    this.lowStockThreshold,
    this.archivedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || form != null) {
      map['form'] = Variable<String>(
        $MedicinesTable.$converterformn.toSql(form),
      );
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || lowStockThreshold != null) {
      map['low_stock_threshold'] = Variable<double>(lowStockThreshold);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      id: Value(id),
      name: Value(name),
      form: form == null && nullToAbsent ? const Value.absent() : Value(form),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      lowStockThreshold: lowStockThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(lowStockThreshold),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      createdAt: Value(createdAt),
    );
  }

  factory MedicineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicineRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      form: $MedicinesTable.$converterformn.fromJson(
        serializer.fromJson<String?>(json['form']),
      ),
      strength: serializer.fromJson<String?>(json['strength']),
      unit: serializer.fromJson<String?>(json['unit']),
      lowStockThreshold: serializer.fromJson<double?>(
        json['lowStockThreshold'],
      ),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'form': serializer.toJson<String?>(
        $MedicinesTable.$converterformn.toJson(form),
      ),
      'strength': serializer.toJson<String?>(strength),
      'unit': serializer.toJson<String?>(unit),
      'lowStockThreshold': serializer.toJson<double?>(lowStockThreshold),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicineRow copyWith({
    String? id,
    String? name,
    Value<MedicineForm?> form = const Value.absent(),
    Value<String?> strength = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<double?> lowStockThreshold = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    DateTime? createdAt,
  }) => MedicineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    form: form.present ? form.value : this.form,
    strength: strength.present ? strength.value : this.strength,
    unit: unit.present ? unit.value : this.unit,
    lowStockThreshold: lowStockThreshold.present
        ? lowStockThreshold.value
        : this.lowStockThreshold,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicineRow copyWithCompanion(MedicinesCompanion data) {
    return MedicineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      form: data.form.present ? data.form.value : this.form,
      strength: data.strength.present ? data.strength.value : this.strength,
      unit: data.unit.present ? data.unit.value : this.unit,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('form: $form, ')
          ..write('strength: $strength, ')
          ..write('unit: $unit, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    form,
    strength,
    unit,
    lowStockThreshold,
    archivedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.form == this.form &&
          other.strength == this.strength &&
          other.unit == this.unit &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt);
}

class MedicinesCompanion extends UpdateCompanion<MedicineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<MedicineForm?> form;
  final Value<String?> strength;
  final Value<String?> unit;
  final Value<double?> lowStockThreshold;
  final Value<DateTime?> archivedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.form = const Value.absent(),
    this.strength = const Value.absent(),
    this.unit = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicinesCompanion.insert({
    required String id,
    required String name,
    this.form = const Value.absent(),
    this.strength = const Value.absent(),
    this.unit = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.archivedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<MedicineRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? form,
    Expression<String>? strength,
    Expression<String>? unit,
    Expression<double>? lowStockThreshold,
    Expression<DateTime>? archivedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (form != null) 'form': form,
      if (strength != null) 'strength': strength,
      if (unit != null) 'unit': unit,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<MedicineForm?>? form,
    Value<String?>? strength,
    Value<String?>? unit,
    Value<double?>? lowStockThreshold,
    Value<DateTime?>? archivedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MedicinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      form: form ?? this.form,
      strength: strength ?? this.strength,
      unit: unit ?? this.unit,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(
        $MedicinesTable.$converterformn.toSql(form.value),
      );
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<double>(lowStockThreshold.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('form: $form, ')
          ..write('strength: $strength, ')
          ..write('unit: $unit, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicinePackagesTable extends MedicinePackages
    with TableInfo<$MedicinePackagesTable, MedicinePackageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinePackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _initialQuantityMeta = const VerificationMeta(
    'initialQuantity',
  );
  @override
  late final GeneratedColumn<double> initialQuantity = GeneratedColumn<double>(
    'initial_quantity',
    aliasedName,
    false,
    check: () => ComparableExpr(initialQuantity).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    check: () => ComparableExpr(quantity).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> expiresOn =
      GeneratedColumn<String>(
        'expires_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($MedicinePackagesTable.$converterexpiresOnn);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineId,
    initialQuantity,
    quantity,
    unit,
    expiresOn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicine_packages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicinePackageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('initial_quantity')) {
      context.handle(
        _initialQuantityMeta,
        initialQuantity.isAcceptableOrUnknown(
          data['initial_quantity']!,
          _initialQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialQuantityMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicinePackageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicinePackageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      initialQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_quantity'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      expiresOn: $MedicinePackagesTable.$converterexpiresOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}expires_on'],
        ),
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicinePackagesTable createAlias(String alias) {
    return $MedicinePackagesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterexpiresOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterexpiresOnn =
      NullAwareTypeConverter.wrap($converterexpiresOn);
}

class MedicinePackageRow extends DataClass
    implements Insertable<MedicinePackageRow> {
  final String id;
  final String medicineId;
  final double initialQuantity;

  /// Backstop for the domain rule: a package can never go below zero.
  final double quantity;
  final String unit;
  final DateTime? expiresOn;
  final DateTime createdAt;
  const MedicinePackageRow({
    required this.id,
    required this.medicineId,
    required this.initialQuantity,
    required this.quantity,
    required this.unit,
    this.expiresOn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medicine_id'] = Variable<String>(medicineId);
    map['initial_quantity'] = Variable<double>(initialQuantity);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || expiresOn != null) {
      map['expires_on'] = Variable<String>(
        $MedicinePackagesTable.$converterexpiresOnn.toSql(expiresOn),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicinePackagesCompanion toCompanion(bool nullToAbsent) {
    return MedicinePackagesCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      initialQuantity: Value(initialQuantity),
      quantity: Value(quantity),
      unit: Value(unit),
      expiresOn: expiresOn == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresOn),
      createdAt: Value(createdAt),
    );
  }

  factory MedicinePackageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicinePackageRow(
      id: serializer.fromJson<String>(json['id']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      initialQuantity: serializer.fromJson<double>(json['initialQuantity']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      expiresOn: serializer.fromJson<DateTime?>(json['expiresOn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicineId': serializer.toJson<String>(medicineId),
      'initialQuantity': serializer.toJson<double>(initialQuantity),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'expiresOn': serializer.toJson<DateTime?>(expiresOn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicinePackageRow copyWith({
    String? id,
    String? medicineId,
    double? initialQuantity,
    double? quantity,
    String? unit,
    Value<DateTime?> expiresOn = const Value.absent(),
    DateTime? createdAt,
  }) => MedicinePackageRow(
    id: id ?? this.id,
    medicineId: medicineId ?? this.medicineId,
    initialQuantity: initialQuantity ?? this.initialQuantity,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    expiresOn: expiresOn.present ? expiresOn.value : this.expiresOn,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicinePackageRow copyWithCompanion(MedicinePackagesCompanion data) {
    return MedicinePackageRow(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      initialQuantity: data.initialQuantity.present
          ? data.initialQuantity.value
          : this.initialQuantity,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      expiresOn: data.expiresOn.present ? data.expiresOn.value : this.expiresOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicinePackageRow(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('expiresOn: $expiresOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicineId,
    initialQuantity,
    quantity,
    unit,
    expiresOn,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicinePackageRow &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.initialQuantity == this.initialQuantity &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.expiresOn == this.expiresOn &&
          other.createdAt == this.createdAt);
}

class MedicinePackagesCompanion extends UpdateCompanion<MedicinePackageRow> {
  final Value<String> id;
  final Value<String> medicineId;
  final Value<double> initialQuantity;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<DateTime?> expiresOn;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicinePackagesCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.initialQuantity = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.expiresOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicinePackagesCompanion.insert({
    required String id,
    required String medicineId,
    required double initialQuantity,
    required double quantity,
    required String unit,
    this.expiresOn = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicineId = Value(medicineId),
       initialQuantity = Value(initialQuantity),
       quantity = Value(quantity),
       unit = Value(unit),
       createdAt = Value(createdAt);
  static Insertable<MedicinePackageRow> custom({
    Expression<String>? id,
    Expression<String>? medicineId,
    Expression<double>? initialQuantity,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? expiresOn,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (initialQuantity != null) 'initial_quantity': initialQuantity,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (expiresOn != null) 'expires_on': expiresOn,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicinePackagesCompanion copyWith({
    Value<String>? id,
    Value<String>? medicineId,
    Value<double>? initialQuantity,
    Value<double>? quantity,
    Value<String>? unit,
    Value<DateTime?>? expiresOn,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MedicinePackagesCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiresOn: expiresOn ?? this.expiresOn,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (initialQuantity.present) {
      map['initial_quantity'] = Variable<double>(initialQuantity.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (expiresOn.present) {
      map['expires_on'] = Variable<String>(
        $MedicinePackagesTable.$converterexpiresOnn.toSql(expiresOn.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinePackagesCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('expiresOn: $expiresOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTransactionsTable extends InventoryTransactions
    with TableInfo<$InventoryTransactionsTable, InventoryTransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicine_packages (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionKind>(
        $InventoryTransactionsTable.$converterkind,
      );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<double> delta = GeneratedColumn<double>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityAfterMeta = const VerificationMeta(
    'quantityAfter',
  );
  @override
  late final GeneratedColumn<double> quantityAfter = GeneratedColumn<double>(
    'quantity_after',
    aliasedName,
    false,
    check: () => ComparableExpr(quantityAfter).isBiggerOrEqualValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageId,
    kind,
    delta,
    quantityAfter,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryTransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('quantity_after')) {
      context.handle(
        _quantityAfterMeta,
        quantityAfter.isAcceptableOrUnknown(
          data['quantity_after']!,
          _quantityAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityAfterMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryTransactionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryTransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      kind: $InventoryTransactionsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delta'],
      )!,
      quantityAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_after'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InventoryTransactionsTable createAlias(String alias) {
    return $InventoryTransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionKind, String, String> $converterkind =
      const EnumNameConverter<TransactionKind>(TransactionKind.values);
}

class InventoryTransactionRow extends DataClass
    implements Insertable<InventoryTransactionRow> {
  final String id;
  final String packageId;
  final TransactionKind kind;
  final double delta;
  final double quantityAfter;
  final DateTime createdAt;
  const InventoryTransactionRow({
    required this.id,
    required this.packageId,
    required this.kind,
    required this.delta,
    required this.quantityAfter,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['package_id'] = Variable<String>(packageId);
    {
      map['kind'] = Variable<String>(
        $InventoryTransactionsTable.$converterkind.toSql(kind),
      );
    }
    map['delta'] = Variable<double>(delta);
    map['quantity_after'] = Variable<double>(quantityAfter);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryTransactionsCompanion toCompanion(bool nullToAbsent) {
    return InventoryTransactionsCompanion(
      id: Value(id),
      packageId: Value(packageId),
      kind: Value(kind),
      delta: Value(delta),
      quantityAfter: Value(quantityAfter),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryTransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryTransactionRow(
      id: serializer.fromJson<String>(json['id']),
      packageId: serializer.fromJson<String>(json['packageId']),
      kind: $InventoryTransactionsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      delta: serializer.fromJson<double>(json['delta']),
      quantityAfter: serializer.fromJson<double>(json['quantityAfter']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'packageId': serializer.toJson<String>(packageId),
      'kind': serializer.toJson<String>(
        $InventoryTransactionsTable.$converterkind.toJson(kind),
      ),
      'delta': serializer.toJson<double>(delta),
      'quantityAfter': serializer.toJson<double>(quantityAfter),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryTransactionRow copyWith({
    String? id,
    String? packageId,
    TransactionKind? kind,
    double? delta,
    double? quantityAfter,
    DateTime? createdAt,
  }) => InventoryTransactionRow(
    id: id ?? this.id,
    packageId: packageId ?? this.packageId,
    kind: kind ?? this.kind,
    delta: delta ?? this.delta,
    quantityAfter: quantityAfter ?? this.quantityAfter,
    createdAt: createdAt ?? this.createdAt,
  );
  InventoryTransactionRow copyWithCompanion(
    InventoryTransactionsCompanion data,
  ) {
    return InventoryTransactionRow(
      id: data.id.present ? data.id.value : this.id,
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      kind: data.kind.present ? data.kind.value : this.kind,
      delta: data.delta.present ? data.delta.value : this.delta,
      quantityAfter: data.quantityAfter.present
          ? data.quantityAfter.value
          : this.quantityAfter,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryTransactionRow(')
          ..write('id: $id, ')
          ..write('packageId: $packageId, ')
          ..write('kind: $kind, ')
          ..write('delta: $delta, ')
          ..write('quantityAfter: $quantityAfter, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, packageId, kind, delta, quantityAfter, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryTransactionRow &&
          other.id == this.id &&
          other.packageId == this.packageId &&
          other.kind == this.kind &&
          other.delta == this.delta &&
          other.quantityAfter == this.quantityAfter &&
          other.createdAt == this.createdAt);
}

class InventoryTransactionsCompanion
    extends UpdateCompanion<InventoryTransactionRow> {
  final Value<String> id;
  final Value<String> packageId;
  final Value<TransactionKind> kind;
  final Value<double> delta;
  final Value<double> quantityAfter;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InventoryTransactionsCompanion({
    this.id = const Value.absent(),
    this.packageId = const Value.absent(),
    this.kind = const Value.absent(),
    this.delta = const Value.absent(),
    this.quantityAfter = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryTransactionsCompanion.insert({
    required String id,
    required String packageId,
    required TransactionKind kind,
    required double delta,
    required double quantityAfter,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       packageId = Value(packageId),
       kind = Value(kind),
       delta = Value(delta),
       quantityAfter = Value(quantityAfter),
       createdAt = Value(createdAt);
  static Insertable<InventoryTransactionRow> custom({
    Expression<String>? id,
    Expression<String>? packageId,
    Expression<String>? kind,
    Expression<double>? delta,
    Expression<double>? quantityAfter,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageId != null) 'package_id': packageId,
      if (kind != null) 'kind': kind,
      if (delta != null) 'delta': delta,
      if (quantityAfter != null) 'quantity_after': quantityAfter,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? packageId,
    Value<TransactionKind>? kind,
    Value<double>? delta,
    Value<double>? quantityAfter,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InventoryTransactionsCompanion(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      kind: kind ?? this.kind,
      delta: delta ?? this.delta,
      quantityAfter: quantityAfter ?? this.quantityAfter,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $InventoryTransactionsTable.$converterkind.toSql(kind.value),
      );
    }
    if (delta.present) {
      map['delta'] = Variable<double>(delta.value);
    }
    if (quantityAfter.present) {
      map['quantity_after'] = Variable<double>(quantityAfter.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('packageId: $packageId, ')
          ..write('kind: $kind, ')
          ..write('delta: $delta, ')
          ..write('quantityAfter: $quantityAfter, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, ScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<String> medicineId = GeneratedColumn<String>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ScheduleKind>($SchedulesTable.$converterkind);
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<String> weekdays = GeneratedColumn<String>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _datesMeta = const VerificationMeta('dates');
  @override
  late final GeneratedColumn<String> dates = GeneratedColumn<String>(
    'dates',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SchedulesTable.$converterstartDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SchedulesTable.$converterendDaten);
  static const VerificationMeta _timesMeta = const VerificationMeta('times');
  @override
  late final GeneratedColumn<String> times = GeneratedColumn<String>(
    'times',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _doseMeta = const VerificationMeta('dose');
  @override
  late final GeneratedColumn<double> dose = GeneratedColumn<double>(
    'dose',
    aliasedName,
    false,
    check: () => ComparableExpr(dose).isBiggerThanValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseUnitMeta = const VerificationMeta(
    'doseUnit',
  );
  @override
  late final GeneratedColumn<String> doseUnit = GeneratedColumn<String>(
    'dose_unit',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineId,
    kind,
    weekdays,
    dates,
    startDate,
    endDate,
    times,
    dose,
    doseUnit,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('dates')) {
      context.handle(
        _datesMeta,
        dates.isAcceptableOrUnknown(data['dates']!, _datesMeta),
      );
    }
    if (data.containsKey('times')) {
      context.handle(
        _timesMeta,
        times.isAcceptableOrUnknown(data['times']!, _timesMeta),
      );
    }
    if (data.containsKey('dose')) {
      context.handle(
        _doseMeta,
        dose.isAcceptableOrUnknown(data['dose']!, _doseMeta),
      );
    } else if (isInserting) {
      context.missing(_doseMeta);
    }
    if (data.containsKey('dose_unit')) {
      context.handle(
        _doseUnitMeta,
        doseUnit.isAcceptableOrUnknown(data['dose_unit']!, _doseUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_doseUnitMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_id'],
      )!,
      kind: $SchedulesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekdays'],
      )!,
      dates: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dates'],
      )!,
      startDate: $SchedulesTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      endDate: $SchedulesTable.$converterendDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        ),
      ),
      times: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times'],
      )!,
      dose: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose'],
      )!,
      doseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_unit'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ScheduleKind, String, String> $converterkind =
      const EnumNameConverter<ScheduleKind>(ScheduleKind.values);
  static TypeConverter<DateTime, String> $converterstartDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime, String> $converterendDate =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterendDaten =
      NullAwareTypeConverter.wrap($converterendDate);
}

class ScheduleRow extends DataClass implements Insertable<ScheduleRow> {
  final String id;

  /// The cabinet's own medicine, never a copy.
  final String medicineId;
  final ScheduleKind kind;

  /// Comma-separated weekday numbers, 1 = Monday.
  final String weekdays;

  /// Comma-separated `yyyy-MM-dd`.
  final String dates;
  final DateTime startDate;
  final DateTime? endDate;

  /// Comma-separated minutes from midnight; empty means one untimed intake.
  final String times;

  /// Per intake; independent of any package quantity.
  final double dose;
  final String doseUnit;
  final DateTime createdAt;
  const ScheduleRow({
    required this.id,
    required this.medicineId,
    required this.kind,
    required this.weekdays,
    required this.dates,
    required this.startDate,
    this.endDate,
    required this.times,
    required this.dose,
    required this.doseUnit,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medicine_id'] = Variable<String>(medicineId);
    {
      map['kind'] = Variable<String>(
        $SchedulesTable.$converterkind.toSql(kind),
      );
    }
    map['weekdays'] = Variable<String>(weekdays);
    map['dates'] = Variable<String>(dates);
    {
      map['start_date'] = Variable<String>(
        $SchedulesTable.$converterstartDate.toSql(startDate),
      );
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(
        $SchedulesTable.$converterendDaten.toSql(endDate),
      );
    }
    map['times'] = Variable<String>(times);
    map['dose'] = Variable<double>(dose);
    map['dose_unit'] = Variable<String>(doseUnit);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      kind: Value(kind),
      weekdays: Value(weekdays),
      dates: Value(dates),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      times: Value(times),
      dose: Value(dose),
      doseUnit: Value(doseUnit),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRow(
      id: serializer.fromJson<String>(json['id']),
      medicineId: serializer.fromJson<String>(json['medicineId']),
      kind: $SchedulesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      weekdays: serializer.fromJson<String>(json['weekdays']),
      dates: serializer.fromJson<String>(json['dates']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      times: serializer.fromJson<String>(json['times']),
      dose: serializer.fromJson<double>(json['dose']),
      doseUnit: serializer.fromJson<String>(json['doseUnit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicineId': serializer.toJson<String>(medicineId),
      'kind': serializer.toJson<String>(
        $SchedulesTable.$converterkind.toJson(kind),
      ),
      'weekdays': serializer.toJson<String>(weekdays),
      'dates': serializer.toJson<String>(dates),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'times': serializer.toJson<String>(times),
      'dose': serializer.toJson<double>(dose),
      'doseUnit': serializer.toJson<String>(doseUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScheduleRow copyWith({
    String? id,
    String? medicineId,
    ScheduleKind? kind,
    String? weekdays,
    String? dates,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    String? times,
    double? dose,
    String? doseUnit,
    DateTime? createdAt,
  }) => ScheduleRow(
    id: id ?? this.id,
    medicineId: medicineId ?? this.medicineId,
    kind: kind ?? this.kind,
    weekdays: weekdays ?? this.weekdays,
    dates: dates ?? this.dates,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    times: times ?? this.times,
    dose: dose ?? this.dose,
    doseUnit: doseUnit ?? this.doseUnit,
    createdAt: createdAt ?? this.createdAt,
  );
  ScheduleRow copyWithCompanion(SchedulesCompanion data) {
    return ScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      kind: data.kind.present ? data.kind.value : this.kind,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      dates: data.dates.present ? data.dates.value : this.dates,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      times: data.times.present ? data.times.value : this.times,
      dose: data.dose.present ? data.dose.value : this.dose,
      doseUnit: data.doseUnit.present ? data.doseUnit.value : this.doseUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRow(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('kind: $kind, ')
          ..write('weekdays: $weekdays, ')
          ..write('dates: $dates, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('times: $times, ')
          ..write('dose: $dose, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicineId,
    kind,
    weekdays,
    dates,
    startDate,
    endDate,
    times,
    dose,
    doseUnit,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRow &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.kind == this.kind &&
          other.weekdays == this.weekdays &&
          other.dates == this.dates &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.times == this.times &&
          other.dose == this.dose &&
          other.doseUnit == this.doseUnit &&
          other.createdAt == this.createdAt);
}

class SchedulesCompanion extends UpdateCompanion<ScheduleRow> {
  final Value<String> id;
  final Value<String> medicineId;
  final Value<ScheduleKind> kind;
  final Value<String> weekdays;
  final Value<String> dates;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<String> times;
  final Value<double> dose;
  final Value<String> doseUnit;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.kind = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.dates = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.times = const Value.absent(),
    this.dose = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchedulesCompanion.insert({
    required String id,
    required String medicineId,
    required ScheduleKind kind,
    this.weekdays = const Value.absent(),
    this.dates = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.times = const Value.absent(),
    required double dose,
    required String doseUnit,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       medicineId = Value(medicineId),
       kind = Value(kind),
       startDate = Value(startDate),
       dose = Value(dose),
       doseUnit = Value(doseUnit),
       createdAt = Value(createdAt);
  static Insertable<ScheduleRow> custom({
    Expression<String>? id,
    Expression<String>? medicineId,
    Expression<String>? kind,
    Expression<String>? weekdays,
    Expression<String>? dates,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? times,
    Expression<double>? dose,
    Expression<String>? doseUnit,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (kind != null) 'kind': kind,
      if (weekdays != null) 'weekdays': weekdays,
      if (dates != null) 'dates': dates,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (times != null) 'times': times,
      if (dose != null) 'dose': dose,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? medicineId,
    Value<ScheduleKind>? kind,
    Value<String>? weekdays,
    Value<String>? dates,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<String>? times,
    Value<double>? dose,
    Value<String>? doseUnit,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      kind: kind ?? this.kind,
      weekdays: weekdays ?? this.weekdays,
      dates: dates ?? this.dates,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      times: times ?? this.times,
      dose: dose ?? this.dose,
      doseUnit: doseUnit ?? this.doseUnit,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<String>(medicineId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $SchedulesTable.$converterkind.toSql(kind.value),
      );
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<String>(weekdays.value);
    }
    if (dates.present) {
      map['dates'] = Variable<String>(dates.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $SchedulesTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $SchedulesTable.$converterendDaten.toSql(endDate.value),
      );
    }
    if (times.present) {
      map['times'] = Variable<String>(times.value);
    }
    if (dose.present) {
      map['dose'] = Variable<double>(dose.value);
    }
    if (doseUnit.present) {
      map['dose_unit'] = Variable<String>(doseUnit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('kind: $kind, ')
          ..write('weekdays: $weekdays, ')
          ..write('dates: $dates, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('times: $times, ')
          ..write('dose: $dose, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IntakeLogsTable extends IntakeLogs
    with TableInfo<$IntakeLogsTable, IntakeLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntakeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
    'schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedules (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> day =
      GeneratedColumn<String>(
        'day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($IntakeLogsTable.$converterday);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(untimedSlot),
  );
  @override
  late final GeneratedColumnWithTypeConverter<IntakeStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(IntakeStatus.taken.name),
      ).withConverter<IntakeStatus>($IntakeLogsTable.$converterstatus);
  static const VerificationMeta _deductionsTrackedMeta = const VerificationMeta(
    'deductionsTracked',
  );
  @override
  late final GeneratedColumn<bool> deductionsTracked = GeneratedColumn<bool>(
    'deductions_tracked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deductions_tracked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicineNameMeta = const VerificationMeta(
    'medicineName',
  );
  @override
  late final GeneratedColumn<String> medicineName = GeneratedColumn<String>(
    'medicine_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MedicineForm?, String>
  medicineForm = GeneratedColumn<String>(
    'medicine_form',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<MedicineForm?>($IntakeLogsTable.$convertermedicineFormn);
  static const VerificationMeta _medicineStrengthMeta = const VerificationMeta(
    'medicineStrength',
  );
  @override
  late final GeneratedColumn<String> medicineStrength = GeneratedColumn<String>(
    'medicine_strength',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduleId,
    day,
    slot,
    status,
    deductionsTracked,
    takenAt,
    medicineName,
    medicineForm,
    medicineStrength,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intake_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntakeLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('deductions_tracked')) {
      context.handle(
        _deductionsTrackedMeta,
        deductionsTracked.isAcceptableOrUnknown(
          data['deductions_tracked']!,
          _deductionsTrackedMeta,
        ),
      );
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('medicine_name')) {
      context.handle(
        _medicineNameMeta,
        medicineName.isAcceptableOrUnknown(
          data['medicine_name']!,
          _medicineNameMeta,
        ),
      );
    }
    if (data.containsKey('medicine_strength')) {
      context.handle(
        _medicineStrengthMeta,
        medicineStrength.isAcceptableOrUnknown(
          data['medicine_strength']!,
          _medicineStrengthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {scheduleId, day, slot},
  ];
  @override
  IntakeLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntakeLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_id'],
      )!,
      day: $IntakeLogsTable.$converterday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}day'],
        )!,
      ),
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      status: $IntakeLogsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      deductionsTracked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deductions_tracked'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      medicineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_name'],
      ),
      medicineForm: $IntakeLogsTable.$convertermedicineFormn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}medicine_form'],
        ),
      ),
      medicineStrength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medicine_strength'],
      ),
    );
  }

  @override
  $IntakeLogsTable createAlias(String alias) {
    return $IntakeLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterday =
      const DateOnlyConverter();
  static JsonTypeConverter2<IntakeStatus, String, String> $converterstatus =
      const EnumNameConverter<IntakeStatus>(IntakeStatus.values);
  static JsonTypeConverter2<MedicineForm, String, String>
  $convertermedicineForm = const EnumNameConverter<MedicineForm>(
    MedicineForm.values,
  );
  static JsonTypeConverter2<MedicineForm?, String?, String?>
  $convertermedicineFormn = JsonTypeConverter2.asNullable(
    $convertermedicineForm,
  );
}

class IntakeLogRow extends DataClass implements Insertable<IntakeLogRow> {
  final String id;
  final String scheduleId;
  final DateTime day;

  /// Minutes from midnight of the taken intake, [untimedSlot] if untimed
  /// (not NULL, because NULLs never collide in a unique key).
  final int slot;
  final IntakeStatus status;

  /// Whether every stock deduction of this mark is in [IntakeDeductions].
  /// False for marks made before deductions were recorded: they cannot be
  /// undone, as the stock cannot be restored exactly.
  final bool deductionsTracked;
  final DateTime takenAt;

  /// The medicine as it was when the intake was marked, so history reads the
  /// same after a rename. All null for marks made before v5 (and while
  /// pending): those follow the current medicine.
  final String? medicineName;
  final MedicineForm? medicineForm;
  final String? medicineStrength;
  const IntakeLogRow({
    required this.id,
    required this.scheduleId,
    required this.day,
    required this.slot,
    required this.status,
    required this.deductionsTracked,
    required this.takenAt,
    this.medicineName,
    this.medicineForm,
    this.medicineStrength,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['schedule_id'] = Variable<String>(scheduleId);
    {
      map['day'] = Variable<String>($IntakeLogsTable.$converterday.toSql(day));
    }
    map['slot'] = Variable<int>(slot);
    {
      map['status'] = Variable<String>(
        $IntakeLogsTable.$converterstatus.toSql(status),
      );
    }
    map['deductions_tracked'] = Variable<bool>(deductionsTracked);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || medicineName != null) {
      map['medicine_name'] = Variable<String>(medicineName);
    }
    if (!nullToAbsent || medicineForm != null) {
      map['medicine_form'] = Variable<String>(
        $IntakeLogsTable.$convertermedicineFormn.toSql(medicineForm),
      );
    }
    if (!nullToAbsent || medicineStrength != null) {
      map['medicine_strength'] = Variable<String>(medicineStrength);
    }
    return map;
  }

  IntakeLogsCompanion toCompanion(bool nullToAbsent) {
    return IntakeLogsCompanion(
      id: Value(id),
      scheduleId: Value(scheduleId),
      day: Value(day),
      slot: Value(slot),
      status: Value(status),
      deductionsTracked: Value(deductionsTracked),
      takenAt: Value(takenAt),
      medicineName: medicineName == null && nullToAbsent
          ? const Value.absent()
          : Value(medicineName),
      medicineForm: medicineForm == null && nullToAbsent
          ? const Value.absent()
          : Value(medicineForm),
      medicineStrength: medicineStrength == null && nullToAbsent
          ? const Value.absent()
          : Value(medicineStrength),
    );
  }

  factory IntakeLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntakeLogRow(
      id: serializer.fromJson<String>(json['id']),
      scheduleId: serializer.fromJson<String>(json['scheduleId']),
      day: serializer.fromJson<DateTime>(json['day']),
      slot: serializer.fromJson<int>(json['slot']),
      status: $IntakeLogsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      deductionsTracked: serializer.fromJson<bool>(json['deductionsTracked']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      medicineName: serializer.fromJson<String?>(json['medicineName']),
      medicineForm: $IntakeLogsTable.$convertermedicineFormn.fromJson(
        serializer.fromJson<String?>(json['medicineForm']),
      ),
      medicineStrength: serializer.fromJson<String?>(json['medicineStrength']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scheduleId': serializer.toJson<String>(scheduleId),
      'day': serializer.toJson<DateTime>(day),
      'slot': serializer.toJson<int>(slot),
      'status': serializer.toJson<String>(
        $IntakeLogsTable.$converterstatus.toJson(status),
      ),
      'deductionsTracked': serializer.toJson<bool>(deductionsTracked),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'medicineName': serializer.toJson<String?>(medicineName),
      'medicineForm': serializer.toJson<String?>(
        $IntakeLogsTable.$convertermedicineFormn.toJson(medicineForm),
      ),
      'medicineStrength': serializer.toJson<String?>(medicineStrength),
    };
  }

  IntakeLogRow copyWith({
    String? id,
    String? scheduleId,
    DateTime? day,
    int? slot,
    IntakeStatus? status,
    bool? deductionsTracked,
    DateTime? takenAt,
    Value<String?> medicineName = const Value.absent(),
    Value<MedicineForm?> medicineForm = const Value.absent(),
    Value<String?> medicineStrength = const Value.absent(),
  }) => IntakeLogRow(
    id: id ?? this.id,
    scheduleId: scheduleId ?? this.scheduleId,
    day: day ?? this.day,
    slot: slot ?? this.slot,
    status: status ?? this.status,
    deductionsTracked: deductionsTracked ?? this.deductionsTracked,
    takenAt: takenAt ?? this.takenAt,
    medicineName: medicineName.present ? medicineName.value : this.medicineName,
    medicineForm: medicineForm.present ? medicineForm.value : this.medicineForm,
    medicineStrength: medicineStrength.present
        ? medicineStrength.value
        : this.medicineStrength,
  );
  IntakeLogRow copyWithCompanion(IntakeLogsCompanion data) {
    return IntakeLogRow(
      id: data.id.present ? data.id.value : this.id,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      day: data.day.present ? data.day.value : this.day,
      slot: data.slot.present ? data.slot.value : this.slot,
      status: data.status.present ? data.status.value : this.status,
      deductionsTracked: data.deductionsTracked.present
          ? data.deductionsTracked.value
          : this.deductionsTracked,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      medicineName: data.medicineName.present
          ? data.medicineName.value
          : this.medicineName,
      medicineForm: data.medicineForm.present
          ? data.medicineForm.value
          : this.medicineForm,
      medicineStrength: data.medicineStrength.present
          ? data.medicineStrength.value
          : this.medicineStrength,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntakeLogRow(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('day: $day, ')
          ..write('slot: $slot, ')
          ..write('status: $status, ')
          ..write('deductionsTracked: $deductionsTracked, ')
          ..write('takenAt: $takenAt, ')
          ..write('medicineName: $medicineName, ')
          ..write('medicineForm: $medicineForm, ')
          ..write('medicineStrength: $medicineStrength')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scheduleId,
    day,
    slot,
    status,
    deductionsTracked,
    takenAt,
    medicineName,
    medicineForm,
    medicineStrength,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntakeLogRow &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.day == this.day &&
          other.slot == this.slot &&
          other.status == this.status &&
          other.deductionsTracked == this.deductionsTracked &&
          other.takenAt == this.takenAt &&
          other.medicineName == this.medicineName &&
          other.medicineForm == this.medicineForm &&
          other.medicineStrength == this.medicineStrength);
}

class IntakeLogsCompanion extends UpdateCompanion<IntakeLogRow> {
  final Value<String> id;
  final Value<String> scheduleId;
  final Value<DateTime> day;
  final Value<int> slot;
  final Value<IntakeStatus> status;
  final Value<bool> deductionsTracked;
  final Value<DateTime> takenAt;
  final Value<String?> medicineName;
  final Value<MedicineForm?> medicineForm;
  final Value<String?> medicineStrength;
  final Value<int> rowid;
  const IntakeLogsCompanion({
    this.id = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.day = const Value.absent(),
    this.slot = const Value.absent(),
    this.status = const Value.absent(),
    this.deductionsTracked = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.medicineName = const Value.absent(),
    this.medicineForm = const Value.absent(),
    this.medicineStrength = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntakeLogsCompanion.insert({
    required String id,
    required String scheduleId,
    required DateTime day,
    this.slot = const Value.absent(),
    this.status = const Value.absent(),
    this.deductionsTracked = const Value.absent(),
    required DateTime takenAt,
    this.medicineName = const Value.absent(),
    this.medicineForm = const Value.absent(),
    this.medicineStrength = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scheduleId = Value(scheduleId),
       day = Value(day),
       takenAt = Value(takenAt);
  static Insertable<IntakeLogRow> custom({
    Expression<String>? id,
    Expression<String>? scheduleId,
    Expression<String>? day,
    Expression<int>? slot,
    Expression<String>? status,
    Expression<bool>? deductionsTracked,
    Expression<DateTime>? takenAt,
    Expression<String>? medicineName,
    Expression<String>? medicineForm,
    Expression<String>? medicineStrength,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (day != null) 'day': day,
      if (slot != null) 'slot': slot,
      if (status != null) 'status': status,
      if (deductionsTracked != null) 'deductions_tracked': deductionsTracked,
      if (takenAt != null) 'taken_at': takenAt,
      if (medicineName != null) 'medicine_name': medicineName,
      if (medicineForm != null) 'medicine_form': medicineForm,
      if (medicineStrength != null) 'medicine_strength': medicineStrength,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntakeLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? scheduleId,
    Value<DateTime>? day,
    Value<int>? slot,
    Value<IntakeStatus>? status,
    Value<bool>? deductionsTracked,
    Value<DateTime>? takenAt,
    Value<String?>? medicineName,
    Value<MedicineForm?>? medicineForm,
    Value<String?>? medicineStrength,
    Value<int>? rowid,
  }) {
    return IntakeLogsCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      day: day ?? this.day,
      slot: slot ?? this.slot,
      status: status ?? this.status,
      deductionsTracked: deductionsTracked ?? this.deductionsTracked,
      takenAt: takenAt ?? this.takenAt,
      medicineName: medicineName ?? this.medicineName,
      medicineForm: medicineForm ?? this.medicineForm,
      medicineStrength: medicineStrength ?? this.medicineStrength,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(
        $IntakeLogsTable.$converterday.toSql(day.value),
      );
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $IntakeLogsTable.$converterstatus.toSql(status.value),
      );
    }
    if (deductionsTracked.present) {
      map['deductions_tracked'] = Variable<bool>(deductionsTracked.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (medicineName.present) {
      map['medicine_name'] = Variable<String>(medicineName.value);
    }
    if (medicineForm.present) {
      map['medicine_form'] = Variable<String>(
        $IntakeLogsTable.$convertermedicineFormn.toSql(medicineForm.value),
      );
    }
    if (medicineStrength.present) {
      map['medicine_strength'] = Variable<String>(medicineStrength.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntakeLogsCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('day: $day, ')
          ..write('slot: $slot, ')
          ..write('status: $status, ')
          ..write('deductionsTracked: $deductionsTracked, ')
          ..write('takenAt: $takenAt, ')
          ..write('medicineName: $medicineName, ')
          ..write('medicineForm: $medicineForm, ')
          ..write('medicineStrength: $medicineStrength, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IntakeDeductionsTable extends IntakeDeductions
    with TableInfo<$IntakeDeductionsTable, IntakeDeductionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntakeDeductionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intakeLogIdMeta = const VerificationMeta(
    'intakeLogId',
  );
  @override
  late final GeneratedColumn<String> intakeLogId = GeneratedColumn<String>(
    'intake_log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES intake_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _packageIdMeta = const VerificationMeta(
    'packageId',
  );
  @override
  late final GeneratedColumn<String> packageId = GeneratedColumn<String>(
    'package_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicine_packages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restoredAtMeta = const VerificationMeta(
    'restoredAt',
  );
  @override
  late final GeneratedColumn<DateTime> restoredAt = GeneratedColumn<DateTime>(
    'restored_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    intakeLogId,
    packageId,
    amount,
    restoredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intake_deductions';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntakeDeductionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('intake_log_id')) {
      context.handle(
        _intakeLogIdMeta,
        intakeLogId.isAcceptableOrUnknown(
          data['intake_log_id']!,
          _intakeLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intakeLogIdMeta);
    }
    if (data.containsKey('package_id')) {
      context.handle(
        _packageIdMeta,
        packageId.isAcceptableOrUnknown(data['package_id']!, _packageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packageIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('restored_at')) {
      context.handle(
        _restoredAtMeta,
        restoredAt.isAcceptableOrUnknown(data['restored_at']!, _restoredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntakeDeductionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntakeDeductionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      intakeLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intake_log_id'],
      )!,
      packageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      restoredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}restored_at'],
      ),
    );
  }

  @override
  $IntakeDeductionsTable createAlias(String alias) {
    return $IntakeDeductionsTable(attachedDatabase, alias);
  }
}

class IntakeDeductionRow extends DataClass
    implements Insertable<IntakeDeductionRow> {
  final String id;
  final String intakeLogId;
  final String packageId;
  final double amount;
  final DateTime? restoredAt;
  const IntakeDeductionRow({
    required this.id,
    required this.intakeLogId,
    required this.packageId,
    required this.amount,
    this.restoredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['intake_log_id'] = Variable<String>(intakeLogId);
    map['package_id'] = Variable<String>(packageId);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || restoredAt != null) {
      map['restored_at'] = Variable<DateTime>(restoredAt);
    }
    return map;
  }

  IntakeDeductionsCompanion toCompanion(bool nullToAbsent) {
    return IntakeDeductionsCompanion(
      id: Value(id),
      intakeLogId: Value(intakeLogId),
      packageId: Value(packageId),
      amount: Value(amount),
      restoredAt: restoredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredAt),
    );
  }

  factory IntakeDeductionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntakeDeductionRow(
      id: serializer.fromJson<String>(json['id']),
      intakeLogId: serializer.fromJson<String>(json['intakeLogId']),
      packageId: serializer.fromJson<String>(json['packageId']),
      amount: serializer.fromJson<double>(json['amount']),
      restoredAt: serializer.fromJson<DateTime?>(json['restoredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'intakeLogId': serializer.toJson<String>(intakeLogId),
      'packageId': serializer.toJson<String>(packageId),
      'amount': serializer.toJson<double>(amount),
      'restoredAt': serializer.toJson<DateTime?>(restoredAt),
    };
  }

  IntakeDeductionRow copyWith({
    String? id,
    String? intakeLogId,
    String? packageId,
    double? amount,
    Value<DateTime?> restoredAt = const Value.absent(),
  }) => IntakeDeductionRow(
    id: id ?? this.id,
    intakeLogId: intakeLogId ?? this.intakeLogId,
    packageId: packageId ?? this.packageId,
    amount: amount ?? this.amount,
    restoredAt: restoredAt.present ? restoredAt.value : this.restoredAt,
  );
  IntakeDeductionRow copyWithCompanion(IntakeDeductionsCompanion data) {
    return IntakeDeductionRow(
      id: data.id.present ? data.id.value : this.id,
      intakeLogId: data.intakeLogId.present
          ? data.intakeLogId.value
          : this.intakeLogId,
      packageId: data.packageId.present ? data.packageId.value : this.packageId,
      amount: data.amount.present ? data.amount.value : this.amount,
      restoredAt: data.restoredAt.present
          ? data.restoredAt.value
          : this.restoredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntakeDeductionRow(')
          ..write('id: $id, ')
          ..write('intakeLogId: $intakeLogId, ')
          ..write('packageId: $packageId, ')
          ..write('amount: $amount, ')
          ..write('restoredAt: $restoredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, intakeLogId, packageId, amount, restoredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntakeDeductionRow &&
          other.id == this.id &&
          other.intakeLogId == this.intakeLogId &&
          other.packageId == this.packageId &&
          other.amount == this.amount &&
          other.restoredAt == this.restoredAt);
}

class IntakeDeductionsCompanion extends UpdateCompanion<IntakeDeductionRow> {
  final Value<String> id;
  final Value<String> intakeLogId;
  final Value<String> packageId;
  final Value<double> amount;
  final Value<DateTime?> restoredAt;
  final Value<int> rowid;
  const IntakeDeductionsCompanion({
    this.id = const Value.absent(),
    this.intakeLogId = const Value.absent(),
    this.packageId = const Value.absent(),
    this.amount = const Value.absent(),
    this.restoredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntakeDeductionsCompanion.insert({
    required String id,
    required String intakeLogId,
    required String packageId,
    required double amount,
    this.restoredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       intakeLogId = Value(intakeLogId),
       packageId = Value(packageId),
       amount = Value(amount);
  static Insertable<IntakeDeductionRow> custom({
    Expression<String>? id,
    Expression<String>? intakeLogId,
    Expression<String>? packageId,
    Expression<double>? amount,
    Expression<DateTime>? restoredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (intakeLogId != null) 'intake_log_id': intakeLogId,
      if (packageId != null) 'package_id': packageId,
      if (amount != null) 'amount': amount,
      if (restoredAt != null) 'restored_at': restoredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntakeDeductionsCompanion copyWith({
    Value<String>? id,
    Value<String>? intakeLogId,
    Value<String>? packageId,
    Value<double>? amount,
    Value<DateTime?>? restoredAt,
    Value<int>? rowid,
  }) {
    return IntakeDeductionsCompanion(
      id: id ?? this.id,
      intakeLogId: intakeLogId ?? this.intakeLogId,
      packageId: packageId ?? this.packageId,
      amount: amount ?? this.amount,
      restoredAt: restoredAt ?? this.restoredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (intakeLogId.present) {
      map['intake_log_id'] = Variable<String>(intakeLogId.value);
    }
    if (packageId.present) {
      map['package_id'] = Variable<String>(packageId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (restoredAt.present) {
      map['restored_at'] = Variable<DateTime>(restoredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntakeDeductionsCompanion(')
          ..write('id: $id, ')
          ..write('intakeLogId: $intakeLogId, ')
          ..write('packageId: $packageId, ')
          ..write('amount: $amount, ')
          ..write('restoredAt: $restoredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $MedicinePackagesTable medicinePackages = $MedicinePackagesTable(
    this,
  );
  late final $InventoryTransactionsTable inventoryTransactions =
      $InventoryTransactionsTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $IntakeLogsTable intakeLogs = $IntakeLogsTable(this);
  late final $IntakeDeductionsTable intakeDeductions = $IntakeDeductionsTable(
    this,
  );
  late final Index idxPackagesMedicine = Index(
    'idx_packages_medicine',
    'CREATE INDEX idx_packages_medicine ON medicine_packages (medicine_id)',
  );
  late final Index idxTransactionsPackage = Index(
    'idx_transactions_package',
    'CREATE INDEX idx_transactions_package ON inventory_transactions (package_id)',
  );
  late final Index idxSchedulesMedicine = Index(
    'idx_schedules_medicine',
    'CREATE INDEX idx_schedules_medicine ON schedules (medicine_id)',
  );
  late final Index idxDeductionsLog = Index(
    'idx_deductions_log',
    'CREATE INDEX idx_deductions_log ON intake_deductions (intake_log_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medicines,
    medicinePackages,
    inventoryTransactions,
    schedules,
    intakeLogs,
    intakeDeductions,
    idxPackagesMedicine,
    idxTransactionsPackage,
    idxSchedulesMedicine,
    idxDeductionsLog,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medicine_packages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicine_packages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('inventory_transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('schedules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'schedules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intake_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'intake_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intake_deductions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'medicine_packages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('intake_deductions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MedicinesTableCreateCompanionBuilder = MedicinesCompanion Function({
  required String id,
  required String name,
  Value<MedicineForm?> form,
  Value<String?> strength,
  Value<String?> unit,
  Value<double?> lowStockThreshold,
  Value<DateTime?> archivedAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MedicinesTableUpdateCompanionBuilder = MedicinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<MedicineForm?> form,
  Value<String?> strength,
  Value<String?> unit,
  Value<double?> lowStockThreshold,
  Value<DateTime?> archivedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$MedicinesTableReferences
    extends BaseReferences<_$AppDatabase, $MedicinesTable, MedicineRow> {
  $$MedicinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MedicinePackagesTable, List<MedicinePackageRow>>
  _medicinePackagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicinePackages,
    aliasName: 'medicines__id__medicine_packages__medicine_id',
  );

  $$MedicinePackagesTableProcessedTableManager get medicinePackagesRefs {
    final manager = $$MedicinePackagesTableTableManager(
      $_db,
      $_db.medicinePackages,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicinePackagesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SchedulesTable, List<ScheduleRow>>
  _schedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.schedules,
    aliasName: 'medicines__id__schedules__medicine_id',
  );

  $$SchedulesTableProcessedTableManager get schedulesRefs {
    final manager = $$SchedulesTableTableManager(
      $_db,
      $_db.schedules,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_schedulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicinesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MedicineForm?, MedicineForm, String>
  get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicinePackagesRefs(
    Expression<bool> Function($$MedicinePackagesTableFilterComposer f) f,
  ) {
    final $$MedicinePackagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicinePackages,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinePackagesTableFilterComposer(
            $db: $db,
            $table: $db.medicinePackages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> schedulesRefs(
    Expression<bool> Function($$SchedulesTableFilterComposer f) f,
  ) {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableFilterComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strength => $composableBuilder(
    column: $table.strength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MedicineForm?, String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> medicinePackagesRefs<T extends Object>(
    Expression<T> Function($$MedicinePackagesTableAnnotationComposer a) f,
  ) {
    final $$MedicinePackagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicinePackages,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinePackagesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicinePackages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> schedulesRefs<T extends Object>(
    Expression<T> Function($$SchedulesTableAnnotationComposer a) f,
  ) {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesTable,
          MedicineRow,
          $$MedicinesTableFilterComposer,
          $$MedicinesTableOrderingComposer,
          $$MedicinesTableAnnotationComposer,
          $$MedicinesTableCreateCompanionBuilder,
          $$MedicinesTableUpdateCompanionBuilder,
          (MedicineRow, $$MedicinesTableReferences),
          MedicineRow,
          PrefetchHooks Function({
            bool medicinePackagesRefs,
            bool schedulesRefs,
          })
        > {
  $$MedicinesTableTableManager(_$AppDatabase db, $MedicinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<MedicineForm?> form = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> lowStockThreshold = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion(
                id: id,
                name: name,
                form: form,
                strength: strength,
                unit: unit,
                lowStockThreshold: lowStockThreshold,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<MedicineForm?> form = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> lowStockThreshold = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion.insert(
                id: id,
                name: name,
                form: form,
                strength: strength,
                unit: unit,
                lowStockThreshold: lowStockThreshold,
                archivedAt: archivedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicinesTable, MedicineRow>(table),
                  $$MedicinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({medicinePackagesRefs = false, schedulesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicinePackagesRefs) db.medicinePackages,
                    if (schedulesRefs) db.schedules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicinePackagesRefs)
                        await $_getPrefetchedData<
                          MedicineRow,
                          $MedicinesTable,
                          MedicinePackageRow
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._medicinePackagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).medicinePackagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (schedulesRefs)
                        await $_getPrefetchedData<
                          MedicineRow,
                          $MedicinesTable,
                          ScheduleRow
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._schedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).schedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesTable,
      MedicineRow,
      $$MedicinesTableFilterComposer,
      $$MedicinesTableOrderingComposer,
      $$MedicinesTableAnnotationComposer,
      $$MedicinesTableCreateCompanionBuilder,
      $$MedicinesTableUpdateCompanionBuilder,
      (MedicineRow, $$MedicinesTableReferences),
      MedicineRow,
      PrefetchHooks Function({bool medicinePackagesRefs, bool schedulesRefs})
    >;
typedef $$MedicinePackagesTableCreateCompanionBuilder =
    MedicinePackagesCompanion Function({
      required String id,
      required String medicineId,
      required double initialQuantity,
      required double quantity,
      required String unit,
      Value<DateTime?> expiresOn,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MedicinePackagesTableUpdateCompanionBuilder =
    MedicinePackagesCompanion Function({
      Value<String> id,
      Value<String> medicineId,
      Value<double> initialQuantity,
      Value<double> quantity,
      Value<String> unit,
      Value<DateTime?> expiresOn,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MedicinePackagesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicinePackagesTable,
          MedicinePackageRow
        > {
  $$MedicinePackagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) =>
      db.medicines.createAlias('medicine_packages__medicine_id__medicines__id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $InventoryTransactionsTable,
    List<InventoryTransactionRow>
  >
  _inventoryTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.inventoryTransactions,
        aliasName: 'medicine_packages__id__inventory_transactions__package_id',
      );

  $$InventoryTransactionsTableProcessedTableManager
  get inventoryTransactionsRefs {
    final manager = $$InventoryTransactionsTableTableManager(
      $_db,
      $_db.inventoryTransactions,
    ).filter((f) => f.packageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _inventoryTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IntakeDeductionsTable, List<IntakeDeductionRow>>
  _intakeDeductionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.intakeDeductions,
    aliasName: 'medicine_packages__id__intake_deductions__package_id',
  );

  $$IntakeDeductionsTableProcessedTableManager get intakeDeductionsRefs {
    final manager = $$IntakeDeductionsTableTableManager(
      $_db,
      $_db.intakeDeductions,
    ).filter((f) => f.packageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _intakeDeductionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicinePackagesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinePackagesTable> {
  $$MedicinePackagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get expiresOn =>
      $composableBuilder(
        column: $table.expiresOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> inventoryTransactionsRefs(
    Expression<bool> Function($$InventoryTransactionsTableFilterComposer f) f,
  ) {
    final $$InventoryTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryTransactions,
          getReferencedColumn: (t) => t.packageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.inventoryTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> intakeDeductionsRefs(
    Expression<bool> Function($$IntakeDeductionsTableFilterComposer f) f,
  ) {
    final $$IntakeDeductionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeDeductions,
      getReferencedColumn: (t) => t.packageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeDeductionsTableFilterComposer(
            $db: $db,
            $table: $db.intakeDeductions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinePackagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinePackagesTable> {
  $$MedicinePackagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiresOn => $composableBuilder(
    column: $table.expiresOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicinePackagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinePackagesTable> {
  $$MedicinePackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get expiresOn =>
      $composableBuilder(column: $table.expiresOn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> inventoryTransactionsRefs<T extends Object>(
    Expression<T> Function($$InventoryTransactionsTableAnnotationComposer a) f,
  ) {
    final $$InventoryTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.inventoryTransactions,
          getReferencedColumn: (t) => t.packageId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> intakeDeductionsRefs<T extends Object>(
    Expression<T> Function($$IntakeDeductionsTableAnnotationComposer a) f,
  ) {
    final $$IntakeDeductionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeDeductions,
      getReferencedColumn: (t) => t.packageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeDeductionsTableAnnotationComposer(
            $db: $db,
            $table: $db.intakeDeductions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinePackagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinePackagesTable,
          MedicinePackageRow,
          $$MedicinePackagesTableFilterComposer,
          $$MedicinePackagesTableOrderingComposer,
          $$MedicinePackagesTableAnnotationComposer,
          $$MedicinePackagesTableCreateCompanionBuilder,
          $$MedicinePackagesTableUpdateCompanionBuilder,
          (MedicinePackageRow, $$MedicinePackagesTableReferences),
          MedicinePackageRow,
          PrefetchHooks Function({
            bool medicineId,
            bool inventoryTransactionsRefs,
            bool intakeDeductionsRefs,
          })
        > {
  $$MedicinePackagesTableTableManager(
    _$AppDatabase db,
    $MedicinePackagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinePackagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinePackagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinePackagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<double> initialQuantity = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<DateTime?> expiresOn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinePackagesCompanion(
                id: id,
                medicineId: medicineId,
                initialQuantity: initialQuantity,
                quantity: quantity,
                unit: unit,
                expiresOn: expiresOn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicineId,
                required double initialQuantity,
                required double quantity,
                required String unit,
                Value<DateTime?> expiresOn = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MedicinePackagesCompanion.insert(
                id: id,
                medicineId: medicineId,
                initialQuantity: initialQuantity,
                quantity: quantity,
                unit: unit,
                expiresOn: expiresOn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicinePackagesTable, MedicinePackageRow>(
                    table,
                  ),
                  $$MedicinePackagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicineId = false,
                inventoryTransactionsRefs = false,
                intakeDeductionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inventoryTransactionsRefs) db.inventoryTransactions,
                    if (intakeDeductionsRefs) db.intakeDeductions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (medicineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.medicineId,
                            referencedTable: $$MedicinePackagesTableReferences
                                ._medicineIdTable(db),
                            referencedColumn: $$MedicinePackagesTableReferences
                                ._medicineIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (inventoryTransactionsRefs)
                        await $_getPrefetchedData<
                          MedicinePackageRow,
                          $MedicinePackagesTable,
                          InventoryTransactionRow
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinePackagesTableReferences
                              ._inventoryTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinePackagesTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packageId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (intakeDeductionsRefs)
                        await $_getPrefetchedData<
                          MedicinePackageRow,
                          $MedicinePackagesTable,
                          IntakeDeductionRow
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinePackagesTableReferences
                              ._intakeDeductionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinePackagesTableReferences(
                                db,
                                table,
                                p0,
                              ).intakeDeductionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.packageId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicinePackagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinePackagesTable,
      MedicinePackageRow,
      $$MedicinePackagesTableFilterComposer,
      $$MedicinePackagesTableOrderingComposer,
      $$MedicinePackagesTableAnnotationComposer,
      $$MedicinePackagesTableCreateCompanionBuilder,
      $$MedicinePackagesTableUpdateCompanionBuilder,
      (MedicinePackageRow, $$MedicinePackagesTableReferences),
      MedicinePackageRow,
      PrefetchHooks Function({
        bool medicineId,
        bool inventoryTransactionsRefs,
        bool intakeDeductionsRefs,
      })
    >;
typedef $$InventoryTransactionsTableCreateCompanionBuilder =
    InventoryTransactionsCompanion Function({
      required String id,
      required String packageId,
      required TransactionKind kind,
      required double delta,
      required double quantityAfter,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$InventoryTransactionsTableUpdateCompanionBuilder =
    InventoryTransactionsCompanion Function({
      Value<String> id,
      Value<String> packageId,
      Value<TransactionKind> kind,
      Value<double> delta,
      Value<double> quantityAfter,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InventoryTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InventoryTransactionsTable,
          InventoryTransactionRow
        > {
  $$InventoryTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicinePackagesTable _packageIdTable(_$AppDatabase db) => db
      .medicinePackages
      .createAlias('inventory_transactions__package_id__medicine_packages__id');

  $$MedicinePackagesTableProcessedTableManager get packageId {
    final $_column = $_itemColumn<String>('package_id')!;

    final manager = $$MedicinePackagesTableTableManager(
      $_db,
      $_db.medicinePackages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoryTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionKind, TransactionKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityAfter => $composableBuilder(
    column: $table.quantityAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinePackagesTableFilterComposer get packageId {
    final $$MedicinePackagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.medicinePackages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinePackagesTableFilterComposer(
            $db: $db,
            $table: $db.medicinePackages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityAfter => $composableBuilder(
    column: $table.quantityAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinePackagesTableOrderingComposer get packageId {
    final $$MedicinePackagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.medicinePackages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinePackagesTableOrderingComposer(
            $db: $db,
            $table: $db.medicinePackages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryTransactionsTable> {
  $$InventoryTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<double> get quantityAfter => $composableBuilder(
    column: $table.quantityAfter,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicinePackagesTableAnnotationComposer get packageId {
    final $$MedicinePackagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.medicinePackages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinePackagesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicinePackages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryTransactionsTable,
          InventoryTransactionRow,
          $$InventoryTransactionsTableFilterComposer,
          $$InventoryTransactionsTableOrderingComposer,
          $$InventoryTransactionsTableAnnotationComposer,
          $$InventoryTransactionsTableCreateCompanionBuilder,
          $$InventoryTransactionsTableUpdateCompanionBuilder,
          (InventoryTransactionRow, $$InventoryTransactionsTableReferences),
          InventoryTransactionRow,
          PrefetchHooks Function({bool packageId})
        > {
  $$InventoryTransactionsTableTableManager(
    _$AppDatabase db,
    $InventoryTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InventoryTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InventoryTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> packageId = const Value.absent(),
                Value<TransactionKind> kind = const Value.absent(),
                Value<double> delta = const Value.absent(),
                Value<double> quantityAfter = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryTransactionsCompanion(
                id: id,
                packageId: packageId,
                kind: kind,
                delta: delta,
                quantityAfter: quantityAfter,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String packageId,
                required TransactionKind kind,
                required double delta,
                required double quantityAfter,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InventoryTransactionsCompanion.insert(
                id: id,
                packageId: packageId,
                kind: kind,
                delta: delta,
                quantityAfter: quantityAfter,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $InventoryTransactionsTable,
                    InventoryTransactionRow
                  >(table),
                  $$InventoryTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packageId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packageId,
                        referencedTable: $$InventoryTransactionsTableReferences
                            ._packageIdTable(db),
                        referencedColumn: $$InventoryTransactionsTableReferences
                            ._packageIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InventoryTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryTransactionsTable,
      InventoryTransactionRow,
      $$InventoryTransactionsTableFilterComposer,
      $$InventoryTransactionsTableOrderingComposer,
      $$InventoryTransactionsTableAnnotationComposer,
      $$InventoryTransactionsTableCreateCompanionBuilder,
      $$InventoryTransactionsTableUpdateCompanionBuilder,
      (InventoryTransactionRow, $$InventoryTransactionsTableReferences),
      InventoryTransactionRow,
      PrefetchHooks Function({bool packageId})
    >;
typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  required String id,
  required String medicineId,
  required ScheduleKind kind,
  Value<String> weekdays,
  Value<String> dates,
  required DateTime startDate,
  Value<DateTime?> endDate,
  Value<String> times,
  required double dose,
  required String doseUnit,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<String> id,
  Value<String> medicineId,
  Value<ScheduleKind> kind,
  Value<String> weekdays,
  Value<String> dates,
  Value<DateTime> startDate,
  Value<DateTime?> endDate,
  Value<String> times,
  Value<double> dose,
  Value<String> doseUnit,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, ScheduleRow> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) =>
      db.medicines.createAlias('schedules__medicine_id__medicines__id');

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<String>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IntakeLogsTable, List<IntakeLogRow>>
  _intakeLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.intakeLogs,
    aliasName: 'schedules__id__intake_logs__schedule_id',
  );

  $$IntakeLogsTableProcessedTableManager get intakeLogsRefs {
    final manager = $$IntakeLogsTableTableManager(
      $_db,
      $_db.intakeLogs,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_intakeLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ScheduleKind, ScheduleKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dates => $composableBuilder(
    column: $table.dates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get endDate =>
      $composableBuilder(
        column: $table.endDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> intakeLogsRefs(
    Expression<bool> Function($$IntakeLogsTableFilterComposer f) f,
  ) {
    final $$IntakeLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeLogs,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeLogsTableFilterComposer(
            $db: $db,
            $table: $db.intakeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dates => $composableBuilder(
    column: $table.dates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get times => $composableBuilder(
    column: $table.times,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dose => $composableBuilder(
    column: $table.dose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<String> get dates =>
      $composableBuilder(column: $table.dates, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  GeneratedColumn<double> get dose =>
      $composableBuilder(column: $table.dose, builder: (column) => column);

  GeneratedColumn<String> get doseUnit =>
      $composableBuilder(column: $table.doseUnit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> intakeLogsRefs<T extends Object>(
    Expression<T> Function($$IntakeLogsTableAnnotationComposer a) f,
  ) {
    final $$IntakeLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeLogs,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.intakeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          ScheduleRow,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (ScheduleRow, $$SchedulesTableReferences),
          ScheduleRow,
          PrefetchHooks Function({bool medicineId, bool intakeLogsRefs})
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> medicineId = const Value.absent(),
                Value<ScheduleKind> kind = const Value.absent(),
                Value<String> weekdays = const Value.absent(),
                Value<String> dates = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> times = const Value.absent(),
                Value<double> dose = const Value.absent(),
                Value<String> doseUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                medicineId: medicineId,
                kind: kind,
                weekdays: weekdays,
                dates: dates,
                startDate: startDate,
                endDate: endDate,
                times: times,
                dose: dose,
                doseUnit: doseUnit,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String medicineId,
                required ScheduleKind kind,
                Value<String> weekdays = const Value.absent(),
                Value<String> dates = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<String> times = const Value.absent(),
                required double dose,
                required String doseUnit,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SchedulesCompanion.insert(
                id: id,
                medicineId: medicineId,
                kind: kind,
                weekdays: weekdays,
                dates: dates,
                startDate: startDate,
                endDate: endDate,
                times: times,
                dose: dose,
                doseUnit: doseUnit,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchedulesTable, ScheduleRow>(table),
                  $$SchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({medicineId = false, intakeLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (intakeLogsRefs) db.intakeLogs],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (medicineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.medicineId,
                            referencedTable: $$SchedulesTableReferences
                                ._medicineIdTable(db),
                            referencedColumn: $$SchedulesTableReferences
                                ._medicineIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (intakeLogsRefs)
                        await $_getPrefetchedData<
                          ScheduleRow,
                          $SchedulesTable,
                          IntakeLogRow
                        >(
                          currentTable: table,
                          referencedTable: $$SchedulesTableReferences
                              ._intakeLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SchedulesTableReferences(
                                db,
                                table,
                                p0,
                              ).intakeLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      ScheduleRow,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (ScheduleRow, $$SchedulesTableReferences),
      ScheduleRow,
      PrefetchHooks Function({bool medicineId, bool intakeLogsRefs})
    >;
typedef $$IntakeLogsTableCreateCompanionBuilder = IntakeLogsCompanion Function({
  required String id,
  required String scheduleId,
  required DateTime day,
  Value<int> slot,
  Value<IntakeStatus> status,
  Value<bool> deductionsTracked,
  required DateTime takenAt,
  Value<String?> medicineName,
  Value<MedicineForm?> medicineForm,
  Value<String?> medicineStrength,
  Value<int> rowid,
});
typedef $$IntakeLogsTableUpdateCompanionBuilder = IntakeLogsCompanion Function({
  Value<String> id,
  Value<String> scheduleId,
  Value<DateTime> day,
  Value<int> slot,
  Value<IntakeStatus> status,
  Value<bool> deductionsTracked,
  Value<DateTime> takenAt,
  Value<String?> medicineName,
  Value<MedicineForm?> medicineForm,
  Value<String?> medicineStrength,
  Value<int> rowid,
});

final class $$IntakeLogsTableReferences
    extends BaseReferences<_$AppDatabase, $IntakeLogsTable, IntakeLogRow> {
  $$IntakeLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.schedules.createAlias('intake_logs__schedule_id__schedules__id');

  $$SchedulesTableProcessedTableManager get scheduleId {
    final $_column = $_itemColumn<String>('schedule_id')!;

    final manager = $$SchedulesTableTableManager(
      $_db,
      $_db.schedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IntakeDeductionsTable, List<IntakeDeductionRow>>
  _intakeDeductionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.intakeDeductions,
    aliasName: 'intake_logs__id__intake_deductions__intake_log_id',
  );

  $$IntakeDeductionsTableProcessedTableManager get intakeDeductionsRefs {
    final manager = $$IntakeDeductionsTableTableManager(
      $_db,
      $_db.intakeDeductions,
    ).filter((f) => f.intakeLogId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _intakeDeductionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IntakeLogsTableFilterComposer
    extends Composer<_$AppDatabase, $IntakeLogsTable> {
  $$IntakeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get day =>
      $composableBuilder(
        column: $table.day,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<IntakeStatus, IntakeStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get deductionsTracked => $composableBuilder(
    column: $table.deductionsTracked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MedicineForm?, MedicineForm, String>
  get medicineForm => $composableBuilder(
    column: $table.medicineForm,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get medicineStrength => $composableBuilder(
    column: $table.medicineStrength,
    builder: (column) => ColumnFilters(column),
  );

  $$SchedulesTableFilterComposer get scheduleId {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableFilterComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> intakeDeductionsRefs(
    Expression<bool> Function($$IntakeDeductionsTableFilterComposer f) f,
  ) {
    final $$IntakeDeductionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeDeductions,
      getReferencedColumn: (t) => t.intakeLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeDeductionsTableFilterComposer(
            $db: $db,
            $table: $db.intakeDeductions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IntakeLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $IntakeLogsTable> {
  $$IntakeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deductionsTracked => $composableBuilder(
    column: $table.deductionsTracked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineForm => $composableBuilder(
    column: $table.medicineForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicineStrength => $composableBuilder(
    column: $table.medicineStrength,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchedulesTableOrderingComposer get scheduleId {
    final $$SchedulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableOrderingComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakeLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntakeLogsTable> {
  $$IntakeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IntakeStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get deductionsTracked => $composableBuilder(
    column: $table.deductionsTracked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get medicineName => $composableBuilder(
    column: $table.medicineName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MedicineForm?, String> get medicineForm =>
      $composableBuilder(
        column: $table.medicineForm,
        builder: (column) => column,
      );

  GeneratedColumn<String> get medicineStrength => $composableBuilder(
    column: $table.medicineStrength,
    builder: (column) => column,
  );

  $$SchedulesTableAnnotationComposer get scheduleId {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> intakeDeductionsRefs<T extends Object>(
    Expression<T> Function($$IntakeDeductionsTableAnnotationComposer a) f,
  ) {
    final $$IntakeDeductionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeDeductions,
      getReferencedColumn: (t) => t.intakeLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeDeductionsTableAnnotationComposer(
            $db: $db,
            $table: $db.intakeDeductions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IntakeLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntakeLogsTable,
          IntakeLogRow,
          $$IntakeLogsTableFilterComposer,
          $$IntakeLogsTableOrderingComposer,
          $$IntakeLogsTableAnnotationComposer,
          $$IntakeLogsTableCreateCompanionBuilder,
          $$IntakeLogsTableUpdateCompanionBuilder,
          (IntakeLogRow, $$IntakeLogsTableReferences),
          IntakeLogRow,
          PrefetchHooks Function({bool scheduleId, bool intakeDeductionsRefs})
        > {
  $$IntakeLogsTableTableManager(_$AppDatabase db, $IntakeLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntakeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntakeLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntakeLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scheduleId = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<int> slot = const Value.absent(),
                Value<IntakeStatus> status = const Value.absent(),
                Value<bool> deductionsTracked = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String?> medicineName = const Value.absent(),
                Value<MedicineForm?> medicineForm = const Value.absent(),
                Value<String?> medicineStrength = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntakeLogsCompanion(
                id: id,
                scheduleId: scheduleId,
                day: day,
                slot: slot,
                status: status,
                deductionsTracked: deductionsTracked,
                takenAt: takenAt,
                medicineName: medicineName,
                medicineForm: medicineForm,
                medicineStrength: medicineStrength,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scheduleId,
                required DateTime day,
                Value<int> slot = const Value.absent(),
                Value<IntakeStatus> status = const Value.absent(),
                Value<bool> deductionsTracked = const Value.absent(),
                required DateTime takenAt,
                Value<String?> medicineName = const Value.absent(),
                Value<MedicineForm?> medicineForm = const Value.absent(),
                Value<String?> medicineStrength = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntakeLogsCompanion.insert(
                id: id,
                scheduleId: scheduleId,
                day: day,
                slot: slot,
                status: status,
                deductionsTracked: deductionsTracked,
                takenAt: takenAt,
                medicineName: medicineName,
                medicineForm: medicineForm,
                medicineStrength: medicineStrength,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IntakeLogsTable, IntakeLogRow>(table),
                  $$IntakeLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({scheduleId = false, intakeDeductionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (intakeDeductionsRefs) db.intakeDeductions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (scheduleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.scheduleId,
                            referencedTable: $$IntakeLogsTableReferences
                                ._scheduleIdTable(db),
                            referencedColumn: $$IntakeLogsTableReferences
                                ._scheduleIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (intakeDeductionsRefs)
                        await $_getPrefetchedData<
                          IntakeLogRow,
                          $IntakeLogsTable,
                          IntakeDeductionRow
                        >(
                          currentTable: table,
                          referencedTable: $$IntakeLogsTableReferences
                              ._intakeDeductionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IntakeLogsTableReferences(
                                db,
                                table,
                                p0,
                              ).intakeDeductionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.intakeLogId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IntakeLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntakeLogsTable,
      IntakeLogRow,
      $$IntakeLogsTableFilterComposer,
      $$IntakeLogsTableOrderingComposer,
      $$IntakeLogsTableAnnotationComposer,
      $$IntakeLogsTableCreateCompanionBuilder,
      $$IntakeLogsTableUpdateCompanionBuilder,
      (IntakeLogRow, $$IntakeLogsTableReferences),
      IntakeLogRow,
      PrefetchHooks Function({bool scheduleId, bool intakeDeductionsRefs})
    >;
typedef $$IntakeDeductionsTableCreateCompanionBuilder =
    IntakeDeductionsCompanion Function({
      required String id,
      required String intakeLogId,
      required String packageId,
      required double amount,
      Value<DateTime?> restoredAt,
      Value<int> rowid,
    });
typedef $$IntakeDeductionsTableUpdateCompanionBuilder =
    IntakeDeductionsCompanion Function({
      Value<String> id,
      Value<String> intakeLogId,
      Value<String> packageId,
      Value<double> amount,
      Value<DateTime?> restoredAt,
      Value<int> rowid,
    });

final class $$IntakeDeductionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IntakeDeductionsTable,
          IntakeDeductionRow
        > {
  $$IntakeDeductionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IntakeLogsTable _intakeLogIdTable(_$AppDatabase db) => db.intakeLogs
      .createAlias('intake_deductions__intake_log_id__intake_logs__id');

  $$IntakeLogsTableProcessedTableManager get intakeLogId {
    final $_column = $_itemColumn<String>('intake_log_id')!;

    final manager = $$IntakeLogsTableTableManager(
      $_db,
      $_db.intakeLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_intakeLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MedicinePackagesTable _packageIdTable(_$AppDatabase db) => db
      .medicinePackages
      .createAlias('intake_deductions__package_id__medicine_packages__id');

  $$MedicinePackagesTableProcessedTableManager get packageId {
    final $_column = $_itemColumn<String>('package_id')!;

    final manager = $$MedicinePackagesTableTableManager(
      $_db,
      $_db.medicinePackages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IntakeDeductionsTableFilterComposer
    extends Composer<_$AppDatabase, $IntakeDeductionsTable> {
  $$IntakeDeductionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$IntakeLogsTableFilterComposer get intakeLogId {
    final $$IntakeLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intakeLogId,
      referencedTable: $db.intakeLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeLogsTableFilterComposer(
            $db: $db,
            $table: $db.intakeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicinePackagesTableFilterComposer get packageId {
    final $$MedicinePackagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.medicinePackages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinePackagesTableFilterComposer(
            $db: $db,
            $table: $db.medicinePackages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakeDeductionsTableOrderingComposer
    extends Composer<_$AppDatabase, $IntakeDeductionsTable> {
  $$IntakeDeductionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$IntakeLogsTableOrderingComposer get intakeLogId {
    final $$IntakeLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intakeLogId,
      referencedTable: $db.intakeLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeLogsTableOrderingComposer(
            $db: $db,
            $table: $db.intakeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicinePackagesTableOrderingComposer get packageId {
    final $$MedicinePackagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.medicinePackages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinePackagesTableOrderingComposer(
            $db: $db,
            $table: $db.medicinePackages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakeDeductionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntakeDeductionsTable> {
  $$IntakeDeductionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => column,
  );

  $$IntakeLogsTableAnnotationComposer get intakeLogId {
    final $$IntakeLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.intakeLogId,
      referencedTable: $db.intakeLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.intakeLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicinePackagesTableAnnotationComposer get packageId {
    final $$MedicinePackagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packageId,
      referencedTable: $db.medicinePackages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinePackagesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicinePackages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakeDeductionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntakeDeductionsTable,
          IntakeDeductionRow,
          $$IntakeDeductionsTableFilterComposer,
          $$IntakeDeductionsTableOrderingComposer,
          $$IntakeDeductionsTableAnnotationComposer,
          $$IntakeDeductionsTableCreateCompanionBuilder,
          $$IntakeDeductionsTableUpdateCompanionBuilder,
          (IntakeDeductionRow, $$IntakeDeductionsTableReferences),
          IntakeDeductionRow,
          PrefetchHooks Function({bool intakeLogId, bool packageId})
        > {
  $$IntakeDeductionsTableTableManager(
    _$AppDatabase db,
    $IntakeDeductionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntakeDeductionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntakeDeductionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntakeDeductionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> intakeLogId = const Value.absent(),
                Value<String> packageId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime?> restoredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntakeDeductionsCompanion(
                id: id,
                intakeLogId: intakeLogId,
                packageId: packageId,
                amount: amount,
                restoredAt: restoredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String intakeLogId,
                required String packageId,
                required double amount,
                Value<DateTime?> restoredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntakeDeductionsCompanion.insert(
                id: id,
                intakeLogId: intakeLogId,
                packageId: packageId,
                amount: amount,
                restoredAt: restoredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IntakeDeductionsTable, IntakeDeductionRow>(
                    table,
                  ),
                  $$IntakeDeductionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({intakeLogId = false, packageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (intakeLogId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.intakeLogId,
                        referencedTable: $$IntakeDeductionsTableReferences
                            ._intakeLogIdTable(db),
                        referencedColumn: $$IntakeDeductionsTableReferences
                            ._intakeLogIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (packageId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packageId,
                        referencedTable: $$IntakeDeductionsTableReferences
                            ._packageIdTable(db),
                        referencedColumn: $$IntakeDeductionsTableReferences
                            ._packageIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IntakeDeductionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntakeDeductionsTable,
      IntakeDeductionRow,
      $$IntakeDeductionsTableFilterComposer,
      $$IntakeDeductionsTableOrderingComposer,
      $$IntakeDeductionsTableAnnotationComposer,
      $$IntakeDeductionsTableCreateCompanionBuilder,
      $$IntakeDeductionsTableUpdateCompanionBuilder,
      (IntakeDeductionRow, $$IntakeDeductionsTableReferences),
      IntakeDeductionRow,
      PrefetchHooks Function({bool intakeLogId, bool packageId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
  $$MedicinePackagesTableTableManager get medicinePackages =>
      $$MedicinePackagesTableTableManager(_db, _db.medicinePackages);
  $$InventoryTransactionsTableTableManager get inventoryTransactions =>
      $$InventoryTransactionsTableTableManager(_db, _db.inventoryTransactions);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$IntakeLogsTableTableManager get intakeLogs =>
      $$IntakeLogsTableTableManager(_db, _db.intakeLogs);
  $$IntakeDeductionsTableTableManager get intakeDeductions =>
      $$IntakeDeductionsTableTableManager(_db, _db.intakeDeductions);
}
