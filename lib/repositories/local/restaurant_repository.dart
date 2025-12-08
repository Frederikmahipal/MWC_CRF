import 'dart:math' as math;
import 'package:drift/drift.dart';
import 'package:latlong2/latlong.dart';
import '../../models/restaurant.dart' as model;
import 'database.dart';

// Repository for managing restaurants in local SQLite database
class RestaurantRepository {
  final AppDatabase _database;

  RestaurantRepository(this._database);

  // Get all restaurants from local database
  Future<List<model.Restaurant>> getAllRestaurants() async {
    try {
      final dbRestaurants = await (_database.select(
        _database.restaurants,
      )..orderBy([(r) => OrderingTerm(expression: r.name)])).get();

      return dbRestaurants.map(_dbToModel).toList();
    } catch (e) {
      print('Error getting restaurants from database: $e');
      return [];
    }
  }

  // Check if database has restaurants
  Future<bool> hasRestaurants() async {
    try {
      final count = await (_database.selectOnly(
        _database.restaurants,
      )..addColumns([_database.restaurants.id.count()])).getSingle();
      return (count.read(_database.restaurants.id.count()) ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  // Get the last update time of restaurants
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final result = await (_database.selectOnly(
        _database.restaurants,
      )..addColumns([_database.restaurants.updatedAt.max()])).getSingle();
      return result.read(_database.restaurants.updatedAt.max());
    } catch (e) {
      return null;
    }
  }

  // Save restaurants to database (replace all existing)
  Future<void> saveRestaurants(List<model.Restaurant> restaurants) async {
    try {
      // Delete all existing restaurants
      await _database.delete(_database.restaurants).go();

      // Insert new restaurants
      final now = DateTime.now();
      final companions = restaurants.map((r) {
        return RestaurantsCompanion.insert(
          id: r.id,
          name: r.name,
          cuisines: r.cuisines.join(';'),
          latitude: r.location.latitude,
          longitude: r.location.longitude,
          phone: Value(r.phone),
          website: Value(r.website),
          openingHours: Value(r.openingHours),
          address: Value(r.address),
          neighborhood: Value(r.neighborhood),
          hasIndoorSeating: Value(r.features.hasIndoorSeating),
          hasOutdoorSeating: Value(r.features.hasOutdoorSeating),
          isWheelchairAccessible: Value(r.features.isWheelchairAccessible),
          hasTakeaway: Value(r.features.hasTakeaway),
          hasDelivery: Value(r.features.hasDelivery),
          hasWifi: Value(r.features.hasWifi),
          hasDriveThrough: Value(r.features.hasDriveThrough),
          averageRating: Value(r.averageRating),
          totalReviews: Value(r.totalReviews),
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

      await _database.batch((batch) {
        batch.insertAll(_database.restaurants, companions);
      });
    } catch (e) {
      rethrow;
    }
  }

  // Search restaurants by query (name, cuisine, neighborhood)
  Future<List<model.Restaurant>> searchRestaurants(String query) async {
    if (query.isEmpty) return await getAllRestaurants();

    try {
      final lowercaseQuery = query.toLowerCase();
      final dbRestaurants =
          await (_database.select(_database.restaurants)..where(
                (r) =>
                    r.name.lower().contains(lowercaseQuery) |
                    r.cuisines.lower().contains(lowercaseQuery) |
                    (r.neighborhood.isNotNull() &
                        r.neighborhood.lower().contains(lowercaseQuery)),
              ))
              .get();

      return dbRestaurants.map(_dbToModel).toList();
    } catch (e) {
      return [];
    }
  }

  // Get restaurants by cuisine
  Future<List<model.Restaurant>> getRestaurantsByCuisine(String cuisine) async {
    try {
      final lowercaseCuisine = cuisine.toLowerCase();
      final dbRestaurants = await (_database.select(
        _database.restaurants,
      )..where((r) => r.cuisines.lower().contains(lowercaseCuisine))).get();

      return dbRestaurants.map(_dbToModel).toList();
    } catch (e) {
      print('Error getting restaurants by cuisine: $e');
      return [];
    }
  }

  // Get restaurants with specific features
  Future<List<model.Restaurant>> getRestaurantsWithFeatures({
    bool? hasOutdoorSeating,
    bool? isWheelchairAccessible,
    bool? hasTakeaway,
    bool? hasDelivery,
    bool? hasWifi,
  }) async {
    try {
      var query = _database.select(_database.restaurants);

      if (hasOutdoorSeating != null) {
        query = query
          ..where((r) => r.hasOutdoorSeating.equals(hasOutdoorSeating));
      }
      if (isWheelchairAccessible != null) {
        query = query
          ..where(
            (r) => r.isWheelchairAccessible.equals(isWheelchairAccessible),
          );
      }
      if (hasTakeaway != null) {
        query = query..where((r) => r.hasTakeaway.equals(hasTakeaway));
      }
      if (hasDelivery != null) {
        query = query..where((r) => r.hasDelivery.equals(hasDelivery));
      }
      if (hasWifi != null) {
        query = query..where((r) => r.hasWifi.equals(hasWifi));
      }

      final dbRestaurants = await query.get();
      return dbRestaurants.map(_dbToModel).toList();
    } catch (e) {
      print('Error getting restaurants with features: $e');
      return [];
    }
  }

  // Get restaurants near a location
  Future<List<model.Restaurant>> getRestaurantsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final allRestaurants = await getAllRestaurants();
      return allRestaurants.where((restaurant) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          restaurant.location.latitude,
          restaurant.location.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error getting restaurants near location: $e');
      return [];
    }
  }

  // Get available cuisines
  Future<List<String>> getAvailableCuisines() async {
    try {
      final restaurants = await getAllRestaurants();
      final cuisines = <String>{};

      for (final restaurant in restaurants) {
        cuisines.addAll(restaurant.cuisines);
      }

      return cuisines.toList()..sort();
    } catch (e) {
      print('Error getting available cuisines: $e');
      return [];
    }
  }

  model.Restaurant _dbToModel(Restaurant dbRestaurant) {
    final cuisines = dbRestaurant.cuisines
        .split(';')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    if (cuisines.isEmpty) cuisines.add('restaurant');

    return model.Restaurant(
      id: dbRestaurant.id,
      name: dbRestaurant.name,
      cuisines: cuisines,
      location: LatLng(dbRestaurant.latitude, dbRestaurant.longitude),
      phone: dbRestaurant.phone,
      website: dbRestaurant.website,
      openingHours: dbRestaurant.openingHours,
      address: dbRestaurant.address,
      neighborhood: dbRestaurant.neighborhood,
      averageRating: dbRestaurant.averageRating,
      totalReviews: dbRestaurant.totalReviews,
      features: model.RestaurantFeatures(
        hasIndoorSeating: dbRestaurant.hasIndoorSeating,
        hasOutdoorSeating: dbRestaurant.hasOutdoorSeating,
        isWheelchairAccessible: dbRestaurant.isWheelchairAccessible,
        hasTakeaway: dbRestaurant.hasTakeaway,
        hasDelivery: dbRestaurant.hasDelivery,
        hasWifi: dbRestaurant.hasWifi,
        hasDriveThrough: dbRestaurant.hasDriveThrough,
      ),
    );
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
