import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Restaurants extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get cuisines => text()(); // JSON array as string
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get phone => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get openingHours => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get neighborhood => text().nullable()();
  BoolColumn get hasIndoorSeating =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get hasOutdoorSeating =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isWheelchairAccessible =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get hasTakeaway => boolean().withDefault(const Constant(false))();
  BoolColumn get hasDelivery => boolean().withDefault(const Constant(false))();
  BoolColumn get hasWifi => boolean().withDefault(const Constant(false))();
  BoolColumn get hasDriveThrough =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Restaurants])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'crf_database.db'));
    return NativeDatabase(file);
  });
}
