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
  List<GeneratedColumn> get $columns => [id, name, form, strength, createdAt];
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
  final DateTime createdAt;
  const MedicineRow({
    required this.id,
    required this.name,
    this.form,
    this.strength,
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicineRow copyWith({
    String? id,
    String? name,
    Value<MedicineForm?> form = const Value.absent(),
    Value<String?> strength = const Value.absent(),
    DateTime? createdAt,
  }) => MedicineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    form: form.present ? form.value : this.form,
    strength: strength.present ? strength.value : this.strength,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicineRow copyWithCompanion(MedicinesCompanion data) {
    return MedicineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      form: data.form.present ? data.form.value : this.form,
      strength: data.strength.present ? data.strength.value : this.strength,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, form, strength, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.form == this.form &&
          other.strength == this.strength &&
          other.createdAt == this.createdAt);
}

class MedicinesCompanion extends UpdateCompanion<MedicineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<MedicineForm?> form;
  final Value<String?> strength;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.form = const Value.absent(),
    this.strength = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicinesCompanion.insert({
    required String id,
    required String name,
    this.form = const Value.absent(),
    this.strength = const Value.absent(),
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
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (form != null) 'form': form,
      if (strength != null) 'strength': strength,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<MedicineForm?>? form,
    Value<String?>? strength,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MedicinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      form: form ?? this.form,
      strength: strength ?? this.strength,
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $MedicinePackagesTable medicinePackages = $MedicinePackagesTable(
    this,
  );
  late final $InventoryTransactionsTable inventoryTransactions =
      $InventoryTransactionsTable(this);
  late final Index idxPackagesMedicine = Index(
    'idx_packages_medicine',
    'CREATE INDEX idx_packages_medicine ON medicine_packages (medicine_id)',
  );
  late final Index idxTransactionsPackage = Index(
    'idx_transactions_package',
    'CREATE INDEX idx_transactions_package ON inventory_transactions (package_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medicines,
    medicinePackages,
    inventoryTransactions,
    idxPackagesMedicine,
    idxTransactionsPackage,
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
  ]);
}

typedef $$MedicinesTableCreateCompanionBuilder = MedicinesCompanion Function({
  required String id,
  required String name,
  Value<MedicineForm?> form,
  Value<String?> strength,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MedicinesTableUpdateCompanionBuilder = MedicinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<MedicineForm?> form,
  Value<String?> strength,
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
          PrefetchHooks Function({bool medicinePackagesRefs})
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
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion(
                id: id,
                name: name,
                form: form,
                strength: strength,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<MedicineForm?> form = const Value.absent(),
                Value<String?> strength = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MedicinesCompanion.insert(
                id: id,
                name: name,
                form: form,
                strength: strength,
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
          prefetchHooksCallback: ({medicinePackagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (medicinePackagesRefs) db.medicinePackages,
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.medicineId == item.id),
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
      PrefetchHooks Function({bool medicinePackagesRefs})
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
              ({medicineId = false, inventoryTransactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inventoryTransactionsRefs) db.inventoryTransactions,
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
      PrefetchHooks Function({bool medicineId, bool inventoryTransactionsRefs})
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
  $$MedicinePackagesTableTableManager get medicinePackages =>
      $$MedicinePackagesTableTableManager(_db, _db.medicinePackages);
  $$InventoryTransactionsTableTableManager get inventoryTransactions =>
      $$InventoryTransactionsTableTableManager(_db, _db.inventoryTransactions);
}
