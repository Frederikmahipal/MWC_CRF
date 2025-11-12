import 'dart:math';
import '../models/restaurant.dart';
import 'overpass_service.dart';
import 'review_service.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantService {
  static final RestaurantService _instance = RestaurantService._internal();
  factory RestaurantService() => _instance;
  RestaurantService._internal();

  final OverpassService _overpassService = OverpassService();

  List<Restaurant>? _cachedRestaurants;
  DateTime? _lastFetchTime;
  static const Duration _cacheExpiry = Duration(hours: 6);

  Future<List<Restaurant>> getAllRestaurants() async {
    print('getAllRestaurants');
    if (_cachedRestaurants != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheExpiry) {
      print('Returning fresh cached restaurants');
      return _cachedRestaurants!;
    }

    try {
      _cachedRestaurants = await _overpassService
          .fetchCopenhagenRestaurants()
          .timeout(const Duration(seconds: 45));
      _lastFetchTime = DateTime.now();
      return _cachedRestaurants!;
    } catch (e) {
      if (_cachedRestaurants != null) {
        return _cachedRestaurants!;
      }
      return [];
    }
  }

  Future<List<Restaurant>> getRestaurantsByCuisine(String cuisine) async {
    final allRestaurants = await getAllRestaurants();
    return allRestaurants.where((restaurant) {
      return restaurant.cuisines.any(
        (c) => c.toLowerCase().contains(cuisine.toLowerCase()),
      );
    }).toList();
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    if (query.isEmpty) return await getAllRestaurants();

    final allRestaurants = await getAllRestaurants();
    final lowercaseQuery = query.toLowerCase();

    return allRestaurants.where((restaurant) {
      if (restaurant.name.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      if (restaurant.cuisines.any(
        (cuisine) => cuisine.toLowerCase().contains(lowercaseQuery),
      )) {
        return true;
      }

      if (restaurant.neighborhood?.toLowerCase().contains(lowercaseQuery) ==
          true) {
        return true;
      }

      return false;
    }).toList();
  }

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

  Future<List<String>> getAvailableCuisines() async {
    final allRestaurants = await getAllRestaurants();
    final cuisines = <String>{};

    for (final restaurant in allRestaurants) {
      cuisines.addAll(restaurant.cuisines);
    }

    return cuisines.toList()..sort();
  }

  void clearCache() {
    _cachedRestaurants = null;
    _lastFetchTime = null;
  }

  List<Restaurant>? getCachedRestaurants() {
    return _cachedRestaurants;
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earths radius in kilometers

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

  Future<String> convertToAddress(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);

      if (placemarks.isEmpty) {
        return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
      }

      final placemark = placemarks.first;
      final addressParts = <String>[];

      final street = placemark.street;
      final subLocality = placemark.subLocality;
      final locality = placemark.locality;
      final postalCode = placemark.postalCode;

      if (street != null && street.isNotEmpty) {
        addressParts.add(street);
      }

      if (subLocality != null && subLocality.isNotEmpty) {
        addressParts.add(subLocality);
      }

      if (locality != null && locality.isNotEmpty) {
        addressParts.add(locality);
      }

      if (postalCode != null && postalCode.isNotEmpty) {
        addressParts.add(postalCode);
      }

      if (addressParts.isNotEmpty) {
        return addressParts.join(', ');
      }

      return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
    } catch (e) {
      return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
    }
  }

  Future<List<Restaurant>> getAllRestaurantsWithRatings() async {
    final restaurants = await getAllRestaurants();
    final restaurantsWithRatings = <Restaurant>[];

    for (final restaurant in restaurants) {
      try {
        final ratingSummary = await ReviewService.getRestaurantRatingSummary(
          restaurant.id,
        );
        final updatedRestaurant = restaurant.copyWith(
          averageRating: ratingSummary['averageRating'] as double,
          totalReviews: ratingSummary['totalReviews'] as int,
        );
        restaurantsWithRatings.add(updatedRestaurant);
      } catch (e) {
        restaurantsWithRatings.add(restaurant);
      }
    }

    return restaurantsWithRatings;
  }

  Future<List<Restaurant>> getRestaurantsForAI() async {
    final restaurants = await getAllRestaurants();
    final restaurantsWithRatings = <Restaurant>[];

    final limitedRestaurants = restaurants.take(50).toList();

    for (final restaurant in limitedRestaurants) {
      try {
        final averageRating = await ReviewService.getRestaurantAverageRating(
          restaurant.id,
        );
        final updatedRestaurant = restaurant.copyWith(
          averageRating: averageRating,
        );
        restaurantsWithRatings.add(updatedRestaurant);
      } catch (e) {
        // If rating calculation fails, use the original restaurant
        restaurantsWithRatings.add(restaurant);
      }
    }

    return restaurantsWithRatings;
  }
}
