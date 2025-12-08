import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

// Google Places API service with safe testing limits
class PlacesApiService {
  static String get apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://places.googleapis.com/v1/places:searchText';
  static const Duration _timeout = Duration(seconds: 30);

  // Safe testing limits - adjust these for testing
  static const int MAX_TEST_QUERIES = 100; // Maximum queries per session
  static int _queryCount = 0;
  static bool _limitReached = false;

  // Copenhagen bounds
  static const double _south = 55.59;
  static const double _west = 12.50;
  static const double _north = 55.71;
  static const double _east = 12.65;

  // Check if we've reached the test limit
  static bool get hasReachedLimit => _limitReached;

  // Get current query count
  static int get queryCount => _queryCount;

  // Reset query counter (for testing)
  static void resetQueryCount() {
    _queryCount = 0;
    _limitReached = false;
  }

  // Fetch restaurants from Google Places API
  // Uses multiple search queries to get more results since pagination doesn't work
  // Returns empty list if limit reached or error occurs
  Future<List<Restaurant>> fetchCopenhagenRestaurants() async {
    if (_limitReached || apiKey.isEmpty) return [];

    try {
      final restaurants = <String, Restaurant>{};
      final searchQueries = [
        'restaurant in Copenhagen',
        'restaurant Copenhagen city center',
        'restaurant Copenhagen Nørrebro',
        'restaurant Copenhagen Vesterbro',
        'restaurant Copenhagen Østerbro',
        'restaurant Copenhagen Frederiksberg',
        'restaurant Copenhagen Amager',
        'restaurant Copenhagen Christianshavn',
        'restaurant Copenhagen Nordhavn',
        'fine dining Copenhagen',
        'italian restaurant Copenhagen',
        'asian restaurant Copenhagen',
        'japanese restaurant Copenhagen',
        'chinese restaurant Copenhagen',
        'indian restaurant Copenhagen',
        'mexican restaurant Copenhagen',
        'thai restaurant Copenhagen',
        'french restaurant Copenhagen',
        'greek restaurant Copenhagen',
        'cafe restaurant Copenhagen',
        'pizza Copenhagen',
        'sushi Copenhagen',
        'burger restaurant Copenhagen',
        'seafood restaurant Copenhagen',
      ];

      for (final query in searchQueries) {
        if (_limitReached ||
            _queryCount >= MAX_TEST_QUERIES ||
            restaurants.length >= 250) {
          break;
        }

        _queryCount++;
        try {
          final response = await _searchRestaurantsWithQuery(query);
          if (response['places'] != null) {
            for (final place in response['places'] as List) {
              try {
                final restaurant = _parsePlace(place, restaurants.length);
                if (restaurant != null) {
                  restaurants[restaurant.id] = restaurant;
                }
              } catch (e) {
                continue;
              }
            }
          }
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          continue;
        }
      }

      return restaurants.values.toList();
    } catch (e) {
      return [];
    }
  }

  // Search restaurants using Places API Text Search with a specific query
  Future<Map<String, dynamic>> _searchRestaurantsWithQuery(String query) async {
    final requestBody = {
      'textQuery': query,
      'maxResultCount': 20, // Max per request
      'locationBias': {
        'rectangle': {
          'low': {'latitude': _south, 'longitude': _west},
          'high': {'latitude': _north, 'longitude': _east},
        },
      },
    };

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            'X-Goog-FieldMask':
                'places.id,places.displayName,places.formattedAddress,places.location,places.nationalPhoneNumber,places.websiteUri,places.regularOpeningHours,places.currentOpeningHours,places.types,places.primaryType,places.priceLevel,places.rating,places.userRatingCount,places.accessibilityOptions,places.businessStatus',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Response: ${response.body}');
      throw Exception('Places API request failed: ${response.statusCode}');
    }
  }

  // Parse a place from Places API response to Restaurant model
  Restaurant? _parsePlace(Map<String, dynamic> place, int currentCount) {
    try {
      final id = place['id'] as String?;
      final displayName = place['displayName']?['text'] as String?;
      final location = place['location'] as Map<String, dynamic>?;
      final types = place['types'] as List<dynamic>?;

      if (id == null || displayName == null || location == null) {
        return null;
      }

      final lat = location['latitude']?.toDouble();
      final lng = location['longitude']?.toDouble();

      if (lat == null || lng == null) {
        return null;
      }

      final primaryType = place['primaryType'] as String?;
      final allTypes = <String>[];
      if (primaryType != null) allTypes.add(primaryType);
      if (types != null) {
        for (final type in types) {
          allTypes.add(type.toString());
        }
      }
      final cuisines = _extractCuisines(allTypes, displayName);

      // Parse features
      final accessibilityOptions =
          place['accessibilityOptions'] as Map<String, dynamic>?;
      final wheelchairAccessible =
          accessibilityOptions?['wheelchairAccessibleParking'] == true ||
          accessibilityOptions?['wheelchairAccessibleEntrance'] == true;

      // Infer features from types (Places API types can indicate services)
      final typeStrings = allTypes
          .map((t) => t.toString().toLowerCase())
          .join(' ');
      final hasTakeaway =
          typeStrings.contains('meal_takeaway') ||
          typeStrings.contains('takeout') ||
          typeStrings.contains('take_away');
      final hasDelivery =
          typeStrings.contains('meal_delivery') ||
          typeStrings.contains('delivery');
      final hasOutdoorSeating =
          typeStrings.contains('outdoor_seating') ||
          typeStrings.contains('outdoor');
      final hasDriveThrough =
          typeStrings.contains('drive_through') ||
          typeStrings.contains('drive_thru');

      // Parse other fields
      final phone = place['nationalPhoneNumber'] as String?;
      final website = place['websiteUri'] as String?;
      final address = place['formattedAddress'] as String?;
      final openingHours = _parseOpeningHours(
        place['regularOpeningHours'] ?? place['currentOpeningHours'],
      );

      final rating = place['rating'] != null
          ? (place['rating'] as num).toDouble()
          : 0.0;
      final userRatingCount = place['userRatingCount'] != null
          ? (place['userRatingCount'] as num).toInt()
          : 0;

      final restaurantData = {
        'id': id,
        'name': displayName,
        'cuisine': cuisines.join(';'),
        'lat': lat,
        'lon': lng,
        'phone': phone,
        'website': website,
        'opening_hours': openingHours,
        'addr:street': address,
        'averageRating': rating,
        'totalReviews': userRatingCount,
        'indoor_seating': true, 
        'outdoor_seating': hasOutdoorSeating,
        'wheelchair': wheelchairAccessible,
        'takeaway': hasTakeaway,
        'delivery': hasDelivery,
        'wifi': false, 
        'drive_through': hasDriveThrough,
      };

      return Restaurant.fromJson(restaurantData);
    } catch (e) {
      return null;
    }
  }

  // Extract cuisine types from Places API types and restaurant name
  List<String> _extractCuisines(List<dynamic> types, String? restaurantName) {
    final cuisines = <String>{};
    final nameLower = (restaurantName ?? '').toLowerCase();
    for (final type in types) {
      final typeStr = type.toString().toLowerCase();

      // Check for specific cuisine types in type string
      if (typeStr.contains('italian') ||
          typeStr.contains('pizza') ||
          typeStr.contains('ristorante')) {
        cuisines.add('italian');
      } else if (typeStr.contains('chinese') || typeStr.contains('dim_sum')) {
        cuisines.add('chinese');
      } else if (typeStr.contains('japanese') ||
          typeStr.contains('sushi') ||
          typeStr.contains('ramen')) {
        cuisines.add('japanese');
      } else if (typeStr.contains('indian') || typeStr.contains('curry')) {
        cuisines.add('indian');
      } else if (typeStr.contains('mexican') ||
          typeStr.contains('taco') ||
          typeStr.contains('burrito')) {
        cuisines.add('mexican');
      } else if (typeStr.contains('thai')) {
        cuisines.add('thai');
      } else if (typeStr.contains('french') || typeStr.contains('bistro')) {
        cuisines.add('french');
      } else if (typeStr.contains('greek')) {
        cuisines.add('greek');
      } else if (typeStr.contains('mediterranean')) {
        cuisines.add('mediterranean');
      } else if (typeStr.contains('american') ||
          typeStr.contains('burger') ||
          typeStr.contains('bbq') ||
          typeStr.contains('barbecue')) {
        cuisines.add('american');
      } else if (typeStr.contains('seafood') || typeStr.contains('fish')) {
        cuisines.add('seafood');
      } else if (typeStr.contains('steak') || typeStr.contains('steakhouse')) {
        cuisines.add('steak');
      } else if (typeStr.contains('vegetarian')) {
        cuisines.add('vegetarian');
      } else if (typeStr.contains('vegan')) {
        cuisines.add('vegan');
      } else if (typeStr.contains('asian')) {
        cuisines.add('asian');
      } else if (typeStr.contains('korean')) {
        cuisines.add('korean');
      } else if (typeStr.contains('vietnamese')) {
        cuisines.add('vietnamese');
      } else if (typeStr.contains('spanish') || typeStr.contains('tapas')) {
        cuisines.add('spanish');
      } else if (typeStr.contains('scandinavian') ||
          typeStr.contains('nordic') ||
          typeStr.contains('danish')) {
        cuisines.add('scandinavian');
      } else if (typeStr.contains('fine_dining')) {
        cuisines.add('fine dining');
      }
    }

    // Also check restaurant name for cuisine hints
    if (nameLower.contains('pizza') ||
        nameLower.contains('ristorante') ||
        nameLower.contains('trattoria')) {
      cuisines.add('italian');
    } else if (nameLower.contains('sushi') ||
        nameLower.contains('ramen') ||
        nameLower.contains('izakaya')) {
      cuisines.add('japanese');
    } else if (nameLower.contains('wok') ||
        nameLower.contains('dim sum') ||
        nameLower.contains('chinese')) {
      cuisines.add('chinese');
    } else if (nameLower.contains('curry') ||
        nameLower.contains('tandoor') ||
        nameLower.contains('indian')) {
      cuisines.add('indian');
    } else if (nameLower.contains('taco') ||
        nameLower.contains('burrito') ||
        nameLower.contains('mexican')) {
      cuisines.add('mexican');
    } else if (nameLower.contains('thai')) {
      cuisines.add('thai');
    } else if (nameLower.contains('bistro') ||
        nameLower.contains('brasserie') ||
        nameLower.contains('french')) {
      cuisines.add('french');
    } else if (nameLower.contains('burger') ||
        nameLower.contains('bbq') ||
        nameLower.contains('barbecue')) {
      cuisines.add('american');
    } else if (nameLower.contains('cafe') || nameLower.contains('coffee')) {
      cuisines.add('cafe');
    }
    if (cuisines.isEmpty) {
      cuisines.add('restaurant');
    }

    return cuisines.toList();
  }

  // Parse opening hours from Places API format
  String? _parseOpeningHours(dynamic openingHours) {
    if (openingHours == null) return null;

    try {
      final weekdayDescriptions =
          openingHours['weekdayDescriptions'] as List<dynamic>?;
      if (weekdayDescriptions != null && weekdayDescriptions.isNotEmpty) {
        return weekdayDescriptions.join('; ');
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}
