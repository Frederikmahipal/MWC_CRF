import '../services/database_seeder.dart';

Future<void> seedDatabase() async {
  print('Starting database seeding...');
  await DatabaseSeeder.seedDatabase();
  print('Database seeding completed');
}

void runSeeder() {
  seedDatabase();
}
