// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $RestaurantsTable extends Restaurants
    with TableInfo<$RestaurantsTable, Restaurant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestaurantsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuisinesMeta = const VerificationMeta(
    'cuisines',
  );
  @override
  late final GeneratedColumn<String> cuisines = GeneratedColumn<String>(
    'cuisines',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingHoursMeta = const VerificationMeta(
    'openingHours',
  );
  @override
  late final GeneratedColumn<String> openingHours = GeneratedColumn<String>(
    'opening_hours',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _neighborhoodMeta = const VerificationMeta(
    'neighborhood',
  );
  @override
  late final GeneratedColumn<String> neighborhood = GeneratedColumn<String>(
    'neighborhood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasIndoorSeatingMeta = const VerificationMeta(
    'hasIndoorSeating',
  );
  @override
  late final GeneratedColumn<bool> hasIndoorSeating = GeneratedColumn<bool>(
    'has_indoor_seating',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_indoor_seating" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasOutdoorSeatingMeta = const VerificationMeta(
    'hasOutdoorSeating',
  );
  @override
  late final GeneratedColumn<bool> hasOutdoorSeating = GeneratedColumn<bool>(
    'has_outdoor_seating',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_outdoor_seating" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWheelchairAccessibleMeta =
      const VerificationMeta('isWheelchairAccessible');
  @override
  late final GeneratedColumn<bool> isWheelchairAccessible =
      GeneratedColumn<bool>(
        'is_wheelchair_accessible',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_wheelchair_accessible" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _hasTakeawayMeta = const VerificationMeta(
    'hasTakeaway',
  );
  @override
  late final GeneratedColumn<bool> hasTakeaway = GeneratedColumn<bool>(
    'has_takeaway',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_takeaway" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasDeliveryMeta = const VerificationMeta(
    'hasDelivery',
  );
  @override
  late final GeneratedColumn<bool> hasDelivery = GeneratedColumn<bool>(
    'has_delivery',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_delivery" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasWifiMeta = const VerificationMeta(
    'hasWifi',
  );
  @override
  late final GeneratedColumn<bool> hasWifi = GeneratedColumn<bool>(
    'has_wifi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_wifi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasDriveThroughMeta = const VerificationMeta(
    'hasDriveThrough',
  );
  @override
  late final GeneratedColumn<bool> hasDriveThrough = GeneratedColumn<bool>(
    'has_drive_through',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_drive_through" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    cuisines,
    latitude,
    longitude,
    phone,
    website,
    openingHours,
    address,
    neighborhood,
    hasIndoorSeating,
    hasOutdoorSeating,
    isWheelchairAccessible,
    hasTakeaway,
    hasDelivery,
    hasWifi,
    hasDriveThrough,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'restaurants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Restaurant> instance, {
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
    if (data.containsKey('cuisines')) {
      context.handle(
        _cuisinesMeta,
        cuisines.isAcceptableOrUnknown(data['cuisines']!, _cuisinesMeta),
      );
    } else if (isInserting) {
      context.missing(_cuisinesMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('opening_hours')) {
      context.handle(
        _openingHoursMeta,
        openingHours.isAcceptableOrUnknown(
          data['opening_hours']!,
          _openingHoursMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('neighborhood')) {
      context.handle(
        _neighborhoodMeta,
        neighborhood.isAcceptableOrUnknown(
          data['neighborhood']!,
          _neighborhoodMeta,
        ),
      );
    }
    if (data.containsKey('has_indoor_seating')) {
      context.handle(
        _hasIndoorSeatingMeta,
        hasIndoorSeating.isAcceptableOrUnknown(
          data['has_indoor_seating']!,
          _hasIndoorSeatingMeta,
        ),
      );
    }
    if (data.containsKey('has_outdoor_seating')) {
      context.handle(
        _hasOutdoorSeatingMeta,
        hasOutdoorSeating.isAcceptableOrUnknown(
          data['has_outdoor_seating']!,
          _hasOutdoorSeatingMeta,
        ),
      );
    }
    if (data.containsKey('is_wheelchair_accessible')) {
      context.handle(
        _isWheelchairAccessibleMeta,
        isWheelchairAccessible.isAcceptableOrUnknown(
          data['is_wheelchair_accessible']!,
          _isWheelchairAccessibleMeta,
        ),
      );
    }
    if (data.containsKey('has_takeaway')) {
      context.handle(
        _hasTakeawayMeta,
        hasTakeaway.isAcceptableOrUnknown(
          data['has_takeaway']!,
          _hasTakeawayMeta,
        ),
      );
    }
    if (data.containsKey('has_delivery')) {
      context.handle(
        _hasDeliveryMeta,
        hasDelivery.isAcceptableOrUnknown(
          data['has_delivery']!,
          _hasDeliveryMeta,
        ),
      );
    }
    if (data.containsKey('has_wifi')) {
      context.handle(
        _hasWifiMeta,
        hasWifi.isAcceptableOrUnknown(data['has_wifi']!, _hasWifiMeta),
      );
    }
    if (data.containsKey('has_drive_through')) {
      context.handle(
        _hasDriveThroughMeta,
        hasDriveThrough.isAcceptableOrUnknown(
          data['has_drive_through']!,
          _hasDriveThroughMeta,
        ),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Restaurant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Restaurant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cuisines: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuisines'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      ),
      openingHours: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_hours'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      neighborhood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}neighborhood'],
      ),
      hasIndoorSeating: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_indoor_seating'],
      )!,
      hasOutdoorSeating: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_outdoor_seating'],
      )!,
      isWheelchairAccessible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_wheelchair_accessible'],
      )!,
      hasTakeaway: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_takeaway'],
      )!,
      hasDelivery: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_delivery'],
      )!,
      hasWifi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_wifi'],
      )!,
      hasDriveThrough: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_drive_through'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RestaurantsTable createAlias(String alias) {
    return $RestaurantsTable(attachedDatabase, alias);
  }
}

class Restaurant extends DataClass implements Insertable<Restaurant> {
  final String id;
  final String name;
  final String cuisines;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String? openingHours;
  final String? address;
  final String? neighborhood;
  final bool hasIndoorSeating;
  final bool hasOutdoorSeating;
  final bool isWheelchairAccessible;
  final bool hasTakeaway;
  final bool hasDelivery;
  final bool hasWifi;
  final bool hasDriveThrough;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisines,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.openingHours,
    this.address,
    this.neighborhood,
    required this.hasIndoorSeating,
    required this.hasOutdoorSeating,
    required this.isWheelchairAccessible,
    required this.hasTakeaway,
    required this.hasDelivery,
    required this.hasWifi,
    required this.hasDriveThrough,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['cuisines'] = Variable<String>(cuisines);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || openingHours != null) {
      map['opening_hours'] = Variable<String>(openingHours);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || neighborhood != null) {
      map['neighborhood'] = Variable<String>(neighborhood);
    }
    map['has_indoor_seating'] = Variable<bool>(hasIndoorSeating);
    map['has_outdoor_seating'] = Variable<bool>(hasOutdoorSeating);
    map['is_wheelchair_accessible'] = Variable<bool>(isWheelchairAccessible);
    map['has_takeaway'] = Variable<bool>(hasTakeaway);
    map['has_delivery'] = Variable<bool>(hasDelivery);
    map['has_wifi'] = Variable<bool>(hasWifi);
    map['has_drive_through'] = Variable<bool>(hasDriveThrough);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RestaurantsCompanion toCompanion(bool nullToAbsent) {
    return RestaurantsCompanion(
      id: Value(id),
      name: Value(name),
      cuisines: Value(cuisines),
      latitude: Value(latitude),
      longitude: Value(longitude),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      openingHours: openingHours == null && nullToAbsent
          ? const Value.absent()
          : Value(openingHours),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      neighborhood: neighborhood == null && nullToAbsent
          ? const Value.absent()
          : Value(neighborhood),
      hasIndoorSeating: Value(hasIndoorSeating),
      hasOutdoorSeating: Value(hasOutdoorSeating),
      isWheelchairAccessible: Value(isWheelchairAccessible),
      hasTakeaway: Value(hasTakeaway),
      hasDelivery: Value(hasDelivery),
      hasWifi: Value(hasWifi),
      hasDriveThrough: Value(hasDriveThrough),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Restaurant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Restaurant(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cuisines: serializer.fromJson<String>(json['cuisines']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      phone: serializer.fromJson<String?>(json['phone']),
      website: serializer.fromJson<String?>(json['website']),
      openingHours: serializer.fromJson<String?>(json['openingHours']),
      address: serializer.fromJson<String?>(json['address']),
      neighborhood: serializer.fromJson<String?>(json['neighborhood']),
      hasIndoorSeating: serializer.fromJson<bool>(json['hasIndoorSeating']),
      hasOutdoorSeating: serializer.fromJson<bool>(json['hasOutdoorSeating']),
      isWheelchairAccessible: serializer.fromJson<bool>(
        json['isWheelchairAccessible'],
      ),
      hasTakeaway: serializer.fromJson<bool>(json['hasTakeaway']),
      hasDelivery: serializer.fromJson<bool>(json['hasDelivery']),
      hasWifi: serializer.fromJson<bool>(json['hasWifi']),
      hasDriveThrough: serializer.fromJson<bool>(json['hasDriveThrough']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'cuisines': serializer.toJson<String>(cuisines),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'phone': serializer.toJson<String?>(phone),
      'website': serializer.toJson<String?>(website),
      'openingHours': serializer.toJson<String?>(openingHours),
      'address': serializer.toJson<String?>(address),
      'neighborhood': serializer.toJson<String?>(neighborhood),
      'hasIndoorSeating': serializer.toJson<bool>(hasIndoorSeating),
      'hasOutdoorSeating': serializer.toJson<bool>(hasOutdoorSeating),
      'isWheelchairAccessible': serializer.toJson<bool>(isWheelchairAccessible),
      'hasTakeaway': serializer.toJson<bool>(hasTakeaway),
      'hasDelivery': serializer.toJson<bool>(hasDelivery),
      'hasWifi': serializer.toJson<bool>(hasWifi),
      'hasDriveThrough': serializer.toJson<bool>(hasDriveThrough),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Restaurant copyWith({
    String? id,
    String? name,
    String? cuisines,
    double? latitude,
    double? longitude,
    Value<String?> phone = const Value.absent(),
    Value<String?> website = const Value.absent(),
    Value<String?> openingHours = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> neighborhood = const Value.absent(),
    bool? hasIndoorSeating,
    bool? hasOutdoorSeating,
    bool? isWheelchairAccessible,
    bool? hasTakeaway,
    bool? hasDelivery,
    bool? hasWifi,
    bool? hasDriveThrough,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Restaurant(
    id: id ?? this.id,
    name: name ?? this.name,
    cuisines: cuisines ?? this.cuisines,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    phone: phone.present ? phone.value : this.phone,
    website: website.present ? website.value : this.website,
    openingHours: openingHours.present ? openingHours.value : this.openingHours,
    address: address.present ? address.value : this.address,
    neighborhood: neighborhood.present ? neighborhood.value : this.neighborhood,
    hasIndoorSeating: hasIndoorSeating ?? this.hasIndoorSeating,
    hasOutdoorSeating: hasOutdoorSeating ?? this.hasOutdoorSeating,
    isWheelchairAccessible:
        isWheelchairAccessible ?? this.isWheelchairAccessible,
    hasTakeaway: hasTakeaway ?? this.hasTakeaway,
    hasDelivery: hasDelivery ?? this.hasDelivery,
    hasWifi: hasWifi ?? this.hasWifi,
    hasDriveThrough: hasDriveThrough ?? this.hasDriveThrough,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Restaurant copyWithCompanion(RestaurantsCompanion data) {
    return Restaurant(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cuisines: data.cuisines.present ? data.cuisines.value : this.cuisines,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      phone: data.phone.present ? data.phone.value : this.phone,
      website: data.website.present ? data.website.value : this.website,
      openingHours: data.openingHours.present
          ? data.openingHours.value
          : this.openingHours,
      address: data.address.present ? data.address.value : this.address,
      neighborhood: data.neighborhood.present
          ? data.neighborhood.value
          : this.neighborhood,
      hasIndoorSeating: data.hasIndoorSeating.present
          ? data.hasIndoorSeating.value
          : this.hasIndoorSeating,
      hasOutdoorSeating: data.hasOutdoorSeating.present
          ? data.hasOutdoorSeating.value
          : this.hasOutdoorSeating,
      isWheelchairAccessible: data.isWheelchairAccessible.present
          ? data.isWheelchairAccessible.value
          : this.isWheelchairAccessible,
      hasTakeaway: data.hasTakeaway.present
          ? data.hasTakeaway.value
          : this.hasTakeaway,
      hasDelivery: data.hasDelivery.present
          ? data.hasDelivery.value
          : this.hasDelivery,
      hasWifi: data.hasWifi.present ? data.hasWifi.value : this.hasWifi,
      hasDriveThrough: data.hasDriveThrough.present
          ? data.hasDriveThrough.value
          : this.hasDriveThrough,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Restaurant(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cuisines: $cuisines, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('phone: $phone, ')
          ..write('website: $website, ')
          ..write('openingHours: $openingHours, ')
          ..write('address: $address, ')
          ..write('neighborhood: $neighborhood, ')
          ..write('hasIndoorSeating: $hasIndoorSeating, ')
          ..write('hasOutdoorSeating: $hasOutdoorSeating, ')
          ..write('isWheelchairAccessible: $isWheelchairAccessible, ')
          ..write('hasTakeaway: $hasTakeaway, ')
          ..write('hasDelivery: $hasDelivery, ')
          ..write('hasWifi: $hasWifi, ')
          ..write('hasDriveThrough: $hasDriveThrough, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    cuisines,
    latitude,
    longitude,
    phone,
    website,
    openingHours,
    address,
    neighborhood,
    hasIndoorSeating,
    hasOutdoorSeating,
    isWheelchairAccessible,
    hasTakeaway,
    hasDelivery,
    hasWifi,
    hasDriveThrough,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Restaurant &&
          other.id == this.id &&
          other.name == this.name &&
          other.cuisines == this.cuisines &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.phone == this.phone &&
          other.website == this.website &&
          other.openingHours == this.openingHours &&
          other.address == this.address &&
          other.neighborhood == this.neighborhood &&
          other.hasIndoorSeating == this.hasIndoorSeating &&
          other.hasOutdoorSeating == this.hasOutdoorSeating &&
          other.isWheelchairAccessible == this.isWheelchairAccessible &&
          other.hasTakeaway == this.hasTakeaway &&
          other.hasDelivery == this.hasDelivery &&
          other.hasWifi == this.hasWifi &&
          other.hasDriveThrough == this.hasDriveThrough &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RestaurantsCompanion extends UpdateCompanion<Restaurant> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> cuisines;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String?> phone;
  final Value<String?> website;
  final Value<String?> openingHours;
  final Value<String?> address;
  final Value<String?> neighborhood;
  final Value<bool> hasIndoorSeating;
  final Value<bool> hasOutdoorSeating;
  final Value<bool> isWheelchairAccessible;
  final Value<bool> hasTakeaway;
  final Value<bool> hasDelivery;
  final Value<bool> hasWifi;
  final Value<bool> hasDriveThrough;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RestaurantsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cuisines = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.phone = const Value.absent(),
    this.website = const Value.absent(),
    this.openingHours = const Value.absent(),
    this.address = const Value.absent(),
    this.neighborhood = const Value.absent(),
    this.hasIndoorSeating = const Value.absent(),
    this.hasOutdoorSeating = const Value.absent(),
    this.isWheelchairAccessible = const Value.absent(),
    this.hasTakeaway = const Value.absent(),
    this.hasDelivery = const Value.absent(),
    this.hasWifi = const Value.absent(),
    this.hasDriveThrough = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestaurantsCompanion.insert({
    required String id,
    required String name,
    required String cuisines,
    required double latitude,
    required double longitude,
    this.phone = const Value.absent(),
    this.website = const Value.absent(),
    this.openingHours = const Value.absent(),
    this.address = const Value.absent(),
    this.neighborhood = const Value.absent(),
    this.hasIndoorSeating = const Value.absent(),
    this.hasOutdoorSeating = const Value.absent(),
    this.isWheelchairAccessible = const Value.absent(),
    this.hasTakeaway = const Value.absent(),
    this.hasDelivery = const Value.absent(),
    this.hasWifi = const Value.absent(),
    this.hasDriveThrough = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       cuisines = Value(cuisines),
       latitude = Value(latitude),
       longitude = Value(longitude),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Restaurant> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? cuisines,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? phone,
    Expression<String>? website,
    Expression<String>? openingHours,
    Expression<String>? address,
    Expression<String>? neighborhood,
    Expression<bool>? hasIndoorSeating,
    Expression<bool>? hasOutdoorSeating,
    Expression<bool>? isWheelchairAccessible,
    Expression<bool>? hasTakeaway,
    Expression<bool>? hasDelivery,
    Expression<bool>? hasWifi,
    Expression<bool>? hasDriveThrough,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cuisines != null) 'cuisines': cuisines,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (openingHours != null) 'opening_hours': openingHours,
      if (address != null) 'address': address,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (hasIndoorSeating != null) 'has_indoor_seating': hasIndoorSeating,
      if (hasOutdoorSeating != null) 'has_outdoor_seating': hasOutdoorSeating,
      if (isWheelchairAccessible != null)
        'is_wheelchair_accessible': isWheelchairAccessible,
      if (hasTakeaway != null) 'has_takeaway': hasTakeaway,
      if (hasDelivery != null) 'has_delivery': hasDelivery,
      if (hasWifi != null) 'has_wifi': hasWifi,
      if (hasDriveThrough != null) 'has_drive_through': hasDriveThrough,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestaurantsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? cuisines,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String?>? phone,
    Value<String?>? website,
    Value<String?>? openingHours,
    Value<String?>? address,
    Value<String?>? neighborhood,
    Value<bool>? hasIndoorSeating,
    Value<bool>? hasOutdoorSeating,
    Value<bool>? isWheelchairAccessible,
    Value<bool>? hasTakeaway,
    Value<bool>? hasDelivery,
    Value<bool>? hasWifi,
    Value<bool>? hasDriveThrough,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RestaurantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisines: cuisines ?? this.cuisines,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      hasIndoorSeating: hasIndoorSeating ?? this.hasIndoorSeating,
      hasOutdoorSeating: hasOutdoorSeating ?? this.hasOutdoorSeating,
      isWheelchairAccessible:
          isWheelchairAccessible ?? this.isWheelchairAccessible,
      hasTakeaway: hasTakeaway ?? this.hasTakeaway,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      hasWifi: hasWifi ?? this.hasWifi,
      hasDriveThrough: hasDriveThrough ?? this.hasDriveThrough,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (cuisines.present) {
      map['cuisines'] = Variable<String>(cuisines.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (openingHours.present) {
      map['opening_hours'] = Variable<String>(openingHours.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (neighborhood.present) {
      map['neighborhood'] = Variable<String>(neighborhood.value);
    }
    if (hasIndoorSeating.present) {
      map['has_indoor_seating'] = Variable<bool>(hasIndoorSeating.value);
    }
    if (hasOutdoorSeating.present) {
      map['has_outdoor_seating'] = Variable<bool>(hasOutdoorSeating.value);
    }
    if (isWheelchairAccessible.present) {
      map['is_wheelchair_accessible'] = Variable<bool>(
        isWheelchairAccessible.value,
      );
    }
    if (hasTakeaway.present) {
      map['has_takeaway'] = Variable<bool>(hasTakeaway.value);
    }
    if (hasDelivery.present) {
      map['has_delivery'] = Variable<bool>(hasDelivery.value);
    }
    if (hasWifi.present) {
      map['has_wifi'] = Variable<bool>(hasWifi.value);
    }
    if (hasDriveThrough.present) {
      map['has_drive_through'] = Variable<bool>(hasDriveThrough.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestaurantsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cuisines: $cuisines, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('phone: $phone, ')
          ..write('website: $website, ')
          ..write('openingHours: $openingHours, ')
          ..write('address: $address, ')
          ..write('neighborhood: $neighborhood, ')
          ..write('hasIndoorSeating: $hasIndoorSeating, ')
          ..write('hasOutdoorSeating: $hasOutdoorSeating, ')
          ..write('isWheelchairAccessible: $isWheelchairAccessible, ')
          ..write('hasTakeaway: $hasTakeaway, ')
          ..write('hasDelivery: $hasDelivery, ')
          ..write('hasWifi: $hasWifi, ')
          ..write('hasDriveThrough: $hasDriveThrough, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RestaurantsTable restaurants = $RestaurantsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [restaurants];
}

typedef $$RestaurantsTableCreateCompanionBuilder =
    RestaurantsCompanion Function({
      required String id,
      required String name,
      required String cuisines,
      required double latitude,
      required double longitude,
      Value<String?> phone,
      Value<String?> website,
      Value<String?> openingHours,
      Value<String?> address,
      Value<String?> neighborhood,
      Value<bool> hasIndoorSeating,
      Value<bool> hasOutdoorSeating,
      Value<bool> isWheelchairAccessible,
      Value<bool> hasTakeaway,
      Value<bool> hasDelivery,
      Value<bool> hasWifi,
      Value<bool> hasDriveThrough,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RestaurantsTableUpdateCompanionBuilder =
    RestaurantsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> cuisines,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> phone,
      Value<String?> website,
      Value<String?> openingHours,
      Value<String?> address,
      Value<String?> neighborhood,
      Value<bool> hasIndoorSeating,
      Value<bool> hasOutdoorSeating,
      Value<bool> isWheelchairAccessible,
      Value<bool> hasTakeaway,
      Value<bool> hasDelivery,
      Value<bool> hasWifi,
      Value<bool> hasDriveThrough,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RestaurantsTableFilterComposer
    extends Composer<_$AppDatabase, $RestaurantsTable> {
  $$RestaurantsTableFilterComposer({
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

  ColumnFilters<String> get cuisines => $composableBuilder(
    column: $table.cuisines,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingHours => $composableBuilder(
    column: $table.openingHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get neighborhood => $composableBuilder(
    column: $table.neighborhood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasIndoorSeating => $composableBuilder(
    column: $table.hasIndoorSeating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasOutdoorSeating => $composableBuilder(
    column: $table.hasOutdoorSeating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWheelchairAccessible => $composableBuilder(
    column: $table.isWheelchairAccessible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasTakeaway => $composableBuilder(
    column: $table.hasTakeaway,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDelivery => $composableBuilder(
    column: $table.hasDelivery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasWifi => $composableBuilder(
    column: $table.hasWifi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasDriveThrough => $composableBuilder(
    column: $table.hasDriveThrough,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RestaurantsTableOrderingComposer
    extends Composer<_$AppDatabase, $RestaurantsTable> {
  $$RestaurantsTableOrderingComposer({
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

  ColumnOrderings<String> get cuisines => $composableBuilder(
    column: $table.cuisines,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingHours => $composableBuilder(
    column: $table.openingHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get neighborhood => $composableBuilder(
    column: $table.neighborhood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasIndoorSeating => $composableBuilder(
    column: $table.hasIndoorSeating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasOutdoorSeating => $composableBuilder(
    column: $table.hasOutdoorSeating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWheelchairAccessible => $composableBuilder(
    column: $table.isWheelchairAccessible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasTakeaway => $composableBuilder(
    column: $table.hasTakeaway,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDelivery => $composableBuilder(
    column: $table.hasDelivery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasWifi => $composableBuilder(
    column: $table.hasWifi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasDriveThrough => $composableBuilder(
    column: $table.hasDriveThrough,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RestaurantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RestaurantsTable> {
  $$RestaurantsTableAnnotationComposer({
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

  GeneratedColumn<String> get cuisines =>
      $composableBuilder(column: $table.cuisines, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get openingHours => $composableBuilder(
    column: $table.openingHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get neighborhood => $composableBuilder(
    column: $table.neighborhood,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasIndoorSeating => $composableBuilder(
    column: $table.hasIndoorSeating,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasOutdoorSeating => $composableBuilder(
    column: $table.hasOutdoorSeating,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWheelchairAccessible => $composableBuilder(
    column: $table.isWheelchairAccessible,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasTakeaway => $composableBuilder(
    column: $table.hasTakeaway,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasDelivery => $composableBuilder(
    column: $table.hasDelivery,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasWifi =>
      $composableBuilder(column: $table.hasWifi, builder: (column) => column);

  GeneratedColumn<bool> get hasDriveThrough => $composableBuilder(
    column: $table.hasDriveThrough,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RestaurantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RestaurantsTable,
          Restaurant,
          $$RestaurantsTableFilterComposer,
          $$RestaurantsTableOrderingComposer,
          $$RestaurantsTableAnnotationComposer,
          $$RestaurantsTableCreateCompanionBuilder,
          $$RestaurantsTableUpdateCompanionBuilder,
          (
            Restaurant,
            BaseReferences<_$AppDatabase, $RestaurantsTable, Restaurant>,
          ),
          Restaurant,
          PrefetchHooks Function()
        > {
  $$RestaurantsTableTableManager(_$AppDatabase db, $RestaurantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestaurantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestaurantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestaurantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> cuisines = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> openingHours = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> neighborhood = const Value.absent(),
                Value<bool> hasIndoorSeating = const Value.absent(),
                Value<bool> hasOutdoorSeating = const Value.absent(),
                Value<bool> isWheelchairAccessible = const Value.absent(),
                Value<bool> hasTakeaway = const Value.absent(),
                Value<bool> hasDelivery = const Value.absent(),
                Value<bool> hasWifi = const Value.absent(),
                Value<bool> hasDriveThrough = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestaurantsCompanion(
                id: id,
                name: name,
                cuisines: cuisines,
                latitude: latitude,
                longitude: longitude,
                phone: phone,
                website: website,
                openingHours: openingHours,
                address: address,
                neighborhood: neighborhood,
                hasIndoorSeating: hasIndoorSeating,
                hasOutdoorSeating: hasOutdoorSeating,
                isWheelchairAccessible: isWheelchairAccessible,
                hasTakeaway: hasTakeaway,
                hasDelivery: hasDelivery,
                hasWifi: hasWifi,
                hasDriveThrough: hasDriveThrough,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String cuisines,
                required double latitude,
                required double longitude,
                Value<String?> phone = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String?> openingHours = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> neighborhood = const Value.absent(),
                Value<bool> hasIndoorSeating = const Value.absent(),
                Value<bool> hasOutdoorSeating = const Value.absent(),
                Value<bool> isWheelchairAccessible = const Value.absent(),
                Value<bool> hasTakeaway = const Value.absent(),
                Value<bool> hasDelivery = const Value.absent(),
                Value<bool> hasWifi = const Value.absent(),
                Value<bool> hasDriveThrough = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RestaurantsCompanion.insert(
                id: id,
                name: name,
                cuisines: cuisines,
                latitude: latitude,
                longitude: longitude,
                phone: phone,
                website: website,
                openingHours: openingHours,
                address: address,
                neighborhood: neighborhood,
                hasIndoorSeating: hasIndoorSeating,
                hasOutdoorSeating: hasOutdoorSeating,
                isWheelchairAccessible: isWheelchairAccessible,
                hasTakeaway: hasTakeaway,
                hasDelivery: hasDelivery,
                hasWifi: hasWifi,
                hasDriveThrough: hasDriveThrough,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RestaurantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RestaurantsTable,
      Restaurant,
      $$RestaurantsTableFilterComposer,
      $$RestaurantsTableOrderingComposer,
      $$RestaurantsTableAnnotationComposer,
      $$RestaurantsTableCreateCompanionBuilder,
      $$RestaurantsTableUpdateCompanionBuilder,
      (
        Restaurant,
        BaseReferences<_$AppDatabase, $RestaurantsTable, Restaurant>,
      ),
      Restaurant,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RestaurantsTableTableManager get restaurants =>
      $$RestaurantsTableTableManager(_db, _db.restaurants);
}
