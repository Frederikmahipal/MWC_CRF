import 'dart:math';
import '../models/restaurant.dart';
import 'overpass_service.dart';

class RestaurantService {
  final OverpassService _overpassService = OverpassService();

  // Cache for restaurants to avoid repeated API calls
  List<Restaurant>? _cachedRestaurants;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiry = Duration(hours: 1);

  /// Get all restaurants (with caching)
  Future<List<Restaurant>> getAllRestaurants() async {
    // Return cached data if still valid
    if (_cachedRestaurants != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheExpiry) {
      return _cachedRestaurants!;
    }

    // Fetch fresh data
    _cachedRestaurants = await _overpassService.fetchCopenhagenRestaurants();
    _lastFetchTime = DateTime.now();

    return _cachedRestaurants!;
  }

  /// Get restaurants by cuisine
  Future<List<Restaurant>> getRestaurantsByCuisine(String cuisine) async {
    final allRestaurants = await getAllRestaurants();
    return allRestaurants.where((restaurant) {
      return restaurant.cuisines.any(
        (c) => c.toLowerCase().contains(cuisine.toLowerCase()),
      );
    }).toList();
  }

  /// Search restaurants by name or cuisine
  Future<List<Restaurant>> searchRestaurants(String query) async {
    if (query.isEmpty) return await getAllRestaurants();

    final allRestaurants = await getAllRestaurants();
    final lowercaseQuery = query.toLowerCase();

    return allRestaurants.where((restaurant) {
      // Search in name
      if (restaurant.name.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // Search in cuisines
      if (restaurant.cuisines.any(
        (cuisine) => cuisine.toLowerCase().contains(lowercaseQuery),
      )) {
        return true;
      }

      // Search in neighborhood
      if (restaurant.neighborhood?.toLowerCase().contains(lowercaseQuery) ==
          true) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Get restaurants with specific features
  Future<List<Restaurant>> getRestaurantsWithFeatures({
    bool? hasOutdoorSeating,
    bool? isWheelchairAccessible,
    bool? hasTakeaway,
    bool? hasDelivery,
    bool? hasWifi,
  }) async {
    final allRestaurants = await getAllRestaurants();

    return allRestaurants.where((restaurant) {
      if (hasOutdoorSeating != null &&
          restaurant.features.hasOutdoorSeating != hasOutdoorSeating) {
        return false;
      }

      if (isWheelchairAccessible != null &&
          restaurant.features.isWheelchairAccessible !=
              isWheelchairAccessible) {
        return false;
      }

      if (hasTakeaway != null &&
          restaurant.features.hasTakeaway != hasTakeaway) {
        return false;
      }

      if (hasDelivery != null &&
          restaurant.features.hasDelivery != hasDelivery) {
        return false;
      }

      if (hasWifi != null && restaurant.features.hasWifi != hasWifi) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Get restaurants near a location (within radius in km)
  Future<List<Restaurant>> getRestaurantsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
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
  }

  /// Get available cuisine types
  Future<List<String>> getAvailableCuisines() async {
    final allRestaurants = await getAllRestaurants();
    final cuisines = <String>{};

    for (final restaurant in allRestaurants) {
      cuisines.addAll(restaurant.cuisines);
    }

    return cuisines.toList()..sort();
  }

  /// Clear cache (useful for testing or forcing refresh)
  void clearCache() {
    _cachedRestaurants = null;
    _lastFetchTime = null;
  }

  /// Calculate distance between two points in kilometers
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
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
