import '../models/restaurant.dart';
import 'restaurant_service.dart';

/// Service for smart filtering of restaurants before sending to AI
/// This reduces the number of restaurants sent to AI, making it faster and cheaper
class RestaurantFilterService {
  final RestaurantService _restaurantService = RestaurantService();

  /// Extract filters from user query and return pre-filtered restaurants
  /// Returns top 20-50 most relevant restaurants
  Future<List<Restaurant>> getFilteredRestaurantsForAI(String userQuery) async {
    final queryLower = userQuery.toLowerCase();

    // Extract cuisine from query
    String? cuisineFilter = _extractCuisine(queryLower);

    // Extract location/neighborhood
    String? locationFilter = _extractLocation(queryLower);

    // Extract features
    bool? hasOutdoorSeating = _extractFeature(queryLower, [
      'outdoor',
      'outside',
      'terrace',
      'patio',
      'garden',
    ]);

    bool? isWheelchairAccessible = _extractFeature(queryLower, [
      'wheelchair',
      'accessible',
      'accessibility',
      'disabled',
    ]);

    bool? hasTakeaway = _extractFeature(queryLower, [
      'takeaway',
      'take away',
      'take-out',
      'to go',
    ]);

    bool? hasDelivery = _extractFeature(queryLower, ['delivery', 'deliver']);

    bool? hasWifi = _extractFeature(queryLower, [
      'wifi',
      'wi-fi',
      'internet',
      'free wifi',
    ]);

    // Get restaurants with filters
    var restaurants = await _restaurantService.getRestaurantsForAI(
      cuisineFilter: cuisineFilter,
      locationFilter: locationFilter,
      hasOutdoorSeating: hasOutdoorSeating,
      isWheelchairAccessible: isWheelchairAccessible,
    );

    // Apply additional filters
    if (hasTakeaway != null) {
      restaurants = restaurants.where((r) {
        return r.features.hasTakeaway == hasTakeaway;
      }).toList();
    }

    if (hasDelivery != null) {
      restaurants = restaurants.where((r) {
        return r.features.hasDelivery == hasDelivery;
      }).toList();
    }

    if (hasWifi != null) {
      restaurants = restaurants.where((r) {
        return r.features.hasWifi == hasWifi;
      }).toList();
    }

    // If we have too many results, limit to top 50
    if (restaurants.length > 50) {
      restaurants = restaurants.take(50).toList();
    }

    // If we have too few results, expand search
    if (restaurants.length < 5) {
      // Remove filters and get more results
      restaurants = await _restaurantService.getRestaurantsForAI();
      restaurants = restaurants.take(30).toList();
    }

    print(
      '🔍 Filtered ${restaurants.length} restaurants for AI from query: "$userQuery"',
    );
    return restaurants;
  }

  /// Extract cuisine type from query
  String? _extractCuisine(String query) {
    final cuisineMap = {
      'italian': ['italian', 'pizza', 'pasta', 'spaghetti', 'lasagna'],
      'chinese': ['chinese', 'dim sum', 'szechuan', 'cantonese'],
      'japanese': ['japanese', 'sushi', 'sashimi', 'ramen', 'tempura'],
      'indian': ['indian', 'curry', 'tandoori', 'naan', 'biryani'],
      'mexican': ['mexican', 'taco', 'burrito', 'quesadilla', 'enchilada'],
      'thai': ['thai', 'pad thai', 'tom yum', 'green curry'],
      'french': ['french', 'bistro', 'croissant', 'escargot'],
      'greek': ['greek', 'gyro', 'souvlaki', 'moussaka'],
      'mediterranean': ['mediterranean', 'hummus', 'falafel'],
      'american': ['american', 'burger', 'bbq', 'barbecue', 'steakhouse'],
      'seafood': ['seafood', 'fish', 'lobster', 'crab', 'oyster'],
      'vegetarian': ['vegetarian', 'veggie'],
      'vegan': ['vegan'],
      'asian': ['asian', 'oriental'],
      'korean': ['korean', 'kimchi', 'bulgogi'],
      'vietnamese': ['vietnamese', 'pho', 'banh mi'],
    };

    for (final entry in cuisineMap.entries) {
      for (final keyword in entry.value) {
        if (query.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return null;
  }

  /// Extract location/neighborhood from query
  String? _extractLocation(String query) {
    // Common Copenhagen neighborhoods
    final locations = [
      'nørrebro',
      'vesterbro',
      'østerbro',
      'christianshavn',
      'amager',
      'frederiksberg',
      'valby',
      'vanløse',
      'brønshøj',
      'nordhavn',
      'nyhavn',
      'strøget',
      'city center',
      'downtown',
      'centrum',
    ];

    for (final location in locations) {
      if (query.contains(location)) {
        return location;
      }
    }

    return null;
  }

  /// Extract feature requirement from query
  bool? _extractFeature(String query, List<String> keywords) {
    // Check for positive mentions
    for (final keyword in keywords) {
      if (query.contains(keyword)) {
        // Check for negative words
        final negativeWords = ['no', 'not', 'without', "don't", "doesn't"];
        for (final negative in negativeWords) {
          // Check if negative word appears before keyword
          final negativeIndex = query.indexOf(negative);
          final keywordIndex = query.indexOf(keyword);
          if (negativeIndex != -1 &&
              keywordIndex != -1 &&
              negativeIndex < keywordIndex &&
              keywordIndex - negativeIndex < 20) {
            return false;
          }
        }
        return true;
      }
    }

    return null;
  }
}
