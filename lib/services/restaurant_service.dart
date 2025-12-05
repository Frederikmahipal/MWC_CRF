import '../models/restaurant.dart';
import 'places_api_service.dart';
import '../repositories/local/database.dart' hide Restaurant;
import '../repositories/local/restaurant_repository.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();
  factory RestaurantService() => _instance;
  RestaurantService._internal();

  final PlacesApiService _placesApiService = PlacesApiService();
  late final AppDatabase _database;
  late final RestaurantRepository _repository;
  bool _isInitialized = false;

  static const Duration _cacheExpiry = Duration(days: 80); 

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _database = AppDatabase();
    _repository = RestaurantRepository(_database);
    _isInitialized = true;
  }

  Future<List<Restaurant>> getAllRestaurants() async {
    await _ensureInitialized();

    try {
      final hasRestaurants = await _repository.hasRestaurants();
      if (hasRestaurants) {
        final lastUpdate = await _repository.getLastUpdateTime();
        final isStale =
            lastUpdate == null ||
            DateTime.now().difference(lastUpdate) > _cacheExpiry;

        if (!isStale) {
          return await _repository.getAllRestaurants();
        }
      }

      final restaurants = await _placesApiService.fetchCopenhagenRestaurants();
      if (restaurants.isNotEmpty) {
        await _repository.saveRestaurants(restaurants);
      } else if (hasRestaurants) {
        return await _repository.getAllRestaurants();
      }

      return restaurants;
    } catch (e) {
      try {
        final localRestaurants = await _repository.getAllRestaurants();
        if (localRestaurants.isNotEmpty) return localRestaurants;
      } catch (_) {}
      return [];
    }
  }

  Future<List<Restaurant>> getRestaurantsByCuisine(String cuisine) async {
    await _ensureInitialized();
    return await _repository.getRestaurantsByCuisine(cuisine);
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    await _ensureInitialized();
    return query.isEmpty
        ? await _repository.getAllRestaurants()
        : await _repository.searchRestaurants(query);
  }

  Future<List<Restaurant>> getRestaurantsWithFeatures({
    bool? hasOutdoorSeating,
    bool? isWheelchairAccessible,
    bool? hasTakeaway,
    bool? hasDelivery,
    bool? hasWifi,
  }) async {
    await _ensureInitialized();
    return await _repository.getRestaurantsWithFeatures(
      hasOutdoorSeating: hasOutdoorSeating,
      isWheelchairAccessible: isWheelchairAccessible,
      hasTakeaway: hasTakeaway,
      hasDelivery: hasDelivery,
      hasWifi: hasWifi,
    );
  }

  Future<List<Restaurant>> getRestaurantsNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    await _ensureInitialized();
    return await _repository.getRestaurantsNearLocation(
      latitude,
      longitude,
      radiusKm,
    );
  }

  Future<List<String>> getAvailableCuisines() async {
    await _ensureInitialized();
    return await _repository.getAvailableCuisines();
  }

  Future<String> convertToAddress(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) {
        return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
      }

      final placemark = placemarks.first;
      final parts = [
        placemark.street,
        placemark.subLocality,
        placemark.locality,
        placemark.postalCode,
      ].where((p) => p != null && p.isNotEmpty).toList();

      return parts.isEmpty
          ? '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}'
          : parts.join(', ');
    } catch (e) {
      return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
    }
  }

  Future<List<Restaurant>> getRestaurantsForAI({
    String? cuisineFilter,
    String? locationFilter,
    bool? hasOutdoorSeating,
    bool? isWheelchairAccessible,
  }) async {
    await _ensureInitialized();
    var restaurants = await _repository.getAllRestaurants();

    if (cuisineFilter != null && cuisineFilter.isNotEmpty) {
      restaurants = restaurants.where((r) {
        return r.cuisines.any(
          (c) => c.toLowerCase().contains(cuisineFilter.toLowerCase()),
        );
      }).toList();
    }

    if (hasOutdoorSeating != null) {
      restaurants = restaurants
          .where((r) => r.features.hasOutdoorSeating == hasOutdoorSeating)
          .toList();
    }

    if (isWheelchairAccessible != null) {
      restaurants = restaurants
          .where(
            (r) => r.features.isWheelchairAccessible == isWheelchairAccessible,
          )
          .toList();
    }

    return restaurants.take(50).toList();
  }

  void dispose() {
    if (_isInitialized) {
      _database.close();
      _isInitialized = false;
    }
  }
}
