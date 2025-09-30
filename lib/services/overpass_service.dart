import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class OverpassService {
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';
  static const Duration _timeout = Duration(seconds: 30);

  // Copenhagen bounding box (south, west, north, east)
  static const double _south = 55.59;
  static const double _west = 12.50;
  static const double _north = 55.71;
  static const double _east = 12.65;

  /// Fetch all restaurants in Copenhagen
  Future<List<Restaurant>> fetchCopenhagenRestaurants() async {
    try {
      final query = _buildCopenhagenRestaurantsQuery();
      final response = await _makeRequest(query);
      return _parseRestaurants(response);
    } catch (e) {
      print('Error fetching restaurants: $e');
      return [];
    }
  }

  /// Fetch restaurants by cuisine type
  Future<List<Restaurant>> fetchRestaurantsByCuisine(String cuisine) async {
    try {
      final query = _buildCuisineQuery(cuisine);
      final response = await _makeRequest(query);
      return _parseRestaurants(response);
    } catch (e) {
      print('Error fetching restaurants by cuisine: $e');
      return [];
    }
  }

  String _buildCopenhagenRestaurantsQuery() {
    return '''
[out:json][timeout:25];
(
  node["amenity"="restaurant"]($_south,$_west,$_north,$_east);
  way["amenity"="restaurant"]($_south,$_west,$_north,$_east);
);
out center meta;
''';
  }

  /// Build query for specific cuisine
  String _buildCuisineQuery(String cuisine) {
    return '''
[out:json][timeout:25];
(
  node["amenity"="restaurant"]["cuisine"~"$cuisine",i]($_south,$_west,$_north,$_east);
  way["amenity"="restaurant"]["cuisine"~"$cuisine",i]($_south,$_west,$_north,$_east);
);
out center meta;
''';
  }

  /// Make HTTP request to Overpass API
  Future<Map<String, dynamic>> _makeRequest(String query) async {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: 'data=${Uri.encodeComponent(query)}',
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }

  /// Parse Overpass API response into Restaurant objects
  List<Restaurant> _parseRestaurants(Map<String, dynamic> response) {
    final List<Restaurant> restaurants = [];

    if (response['elements'] == null) {
      return restaurants;
    }

    for (final element in response['elements']) {
      try {
        final restaurant = _parseRestaurantElement(element);
        if (restaurant != null) {
          restaurants.add(restaurant);
        }
      } catch (e) {
        print('Error parsing restaurant element: $e');
        continue;
      }
    }

    return restaurants;
  }

  /// Parse individual restaurant element
  Restaurant? _parseRestaurantElement(Map<String, dynamic> element) {
    final tags = element['tags'] as Map<String, dynamic>?;
    if (tags == null) return null;

    // Skip if no name
    if (tags['name'] == null) return null;

    // Get coordinates
    double? lat, lon;
    if (element['type'] == 'node') {
      lat = element['lat']?.toDouble();
      lon = element['lon']?.toDouble();
    } else if (element['type'] == 'way' && element['center'] != null) {
      lat = element['center']['lat']?.toDouble();
      lon = element['center']['lon']?.toDouble();
    }

    if (lat == null || lon == null) return null;

    final restaurantData = {
      'id': element['id'].toString(),
      'name': tags['name'],
      'cuisine': tags['cuisine'],
      'lat': lat,
      'lon': lon,
      'phone': tags['phone'],
      'website': tags['website'],
      'opening_hours': tags['opening_hours'],
      'addr:street': tags['addr:street'],
      'branch': tags['branch'],
      'indoor_seating': tags['indoor_seating'],
      'outdoor_seating': tags['outdoor_seating'],
      'wheelchair': tags['wheelchair'],
      'takeaway': tags['takeaway'],
      'delivery': tags['delivery'],
      'wifi': tags['wifi'],
      'drive_through': tags['drive_through'],
    };

    return Restaurant.fromJson(restaurantData);
  }
}
