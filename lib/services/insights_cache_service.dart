import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/insights.dart';

class InsightsCacheService {
  static const String _cacheKey = 'insights_cache';
  static const String _cacheTimestampKey = 'insights_cache_timestamp';
  static const String _cacheVersionKey = 'insights_cache_version';
  static const Duration _cacheExpiry = Duration(hours: 1);
  static const int _currentCacheVersion =
      1; // Increment when data structure changes

  static Future<List<MonthlyInsights>?> getCachedInsights() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cacheData = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);
      final version = prefs.getInt(_cacheVersionKey);

      if (cacheData == null || timestamp == null || version == null) {
        return null;
      }

      // Check cache version
      if (version != _currentCacheVersion) {
        await _clearCache();
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        await _clearCache();
        return null;
      }

      // Parse and return cached data
      final List<dynamic> jsonList = jsonDecode(cacheData);
      return jsonList.map((json) => _monthlyInsightsFromJson(json)).toList();
    } catch (e) {
      print('Error getting cached insights: $e');
      await _clearCache();
      return null;
    }
  }

  /// Cache insights data
  static Future<void> cacheInsights(List<MonthlyInsights> insights) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = insights
          .map((insight) => _monthlyInsightsToJson(insight))
          .toList();

      final cacheData = jsonEncode(jsonList);

      // Store in cache
      await prefs.setString(_cacheKey, cacheData);
      await prefs.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setInt(_cacheVersionKey, _currentCacheVersion);
    } catch (e) {
    }
  }

  static Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      await prefs.remove(_cacheVersionKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  static Future<void> invalidateCache() async {
    await _clearCache();
  }

  static Future<void> invalidateCacheFor({
    bool likes = false,
    bool visits = false,
    bool reviews = false,
  }) async {

    if (likes || visits || reviews) {
      await _clearCache();
    }
  }

  static Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      final version = prefs.getInt(_cacheVersionKey);

      if (timestamp == null || version == null) {
        return false;
      }

      if (version != _currentCacheVersion) {
        return false;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cacheTime) <= _cacheExpiry;
    } catch (e) {
      return false;
    }
  }

  /// Convert MonthlyInsights to JSON
  static Map<String, dynamic> _monthlyInsightsToJson(MonthlyInsights insight) {
    return {
      'year': insight.year,
      'month': insight.month,
      'monthName': insight.monthName,
      'totalReviews': insight.totalReviews,
      'averageRating': insight.averageRating,
      'ratingDistribution': insight.ratingDistribution.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'topRestaurants': insight.topRestaurants
          .map((r) => _restaurantInsightToJson(r))
          .toList(),
      'mostReviewedRestaurants': insight.mostReviewedRestaurants
          .map((r) => _restaurantInsightToJson(r))
          .toList(),
      'highestRatedRestaurants': insight.highestRatedRestaurants
          .map((r) => _restaurantInsightToJson(r))
          .toList(),
      'mostVisitedRestaurants': insight.mostVisitedRestaurants
          .map((r) => _restaurantInsightToJson(r))
          .toList(),
      'mostLikedRestaurants': insight.mostLikedRestaurants
          .map((r) => _restaurantInsightToJson(r))
          .toList(),
    };
  }

  static MonthlyInsights _monthlyInsightsFromJson(Map<String, dynamic> json) {
    return MonthlyInsights(
      year: json['year'],
      month: json['month'],
      monthName: json['monthName'],
      totalReviews: json['totalReviews'],
      averageRating: json['averageRating'],
      ratingDistribution: (json['ratingDistribution'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(int.parse(k), v as int)),
      topRestaurants: (json['topRestaurants'] as List)
          .map((r) => _restaurantInsightFromJson(r))
          .toList(),
      mostReviewedRestaurants: (json['mostReviewedRestaurants'] as List)
          .map((r) => _restaurantInsightFromJson(r))
          .toList(),
      highestRatedRestaurants: (json['highestRatedRestaurants'] as List)
          .map((r) => _restaurantInsightFromJson(r))
          .toList(),
      mostVisitedRestaurants: (json['mostVisitedRestaurants'] as List)
          .map((r) => _restaurantInsightFromJson(r))
          .toList(),
      mostLikedRestaurants: (json['mostLikedRestaurants'] as List)
          .map((r) => _restaurantInsightFromJson(r))
          .toList(),
    );
  }

  static Map<String, dynamic> _restaurantInsightToJson(
    RestaurantInsight insight,
  ) {
    return {
      'restaurantId': insight.restaurantId,
      'restaurantName': insight.restaurantName,
      'reviewCount': insight.reviewCount,
      'averageRating': insight.averageRating,
      'fiveStarCount': insight.fiveStarCount,
      'fourStarCount': insight.fourStarCount,
      'threeStarCount': insight.threeStarCount,
      'twoStarCount': insight.twoStarCount,
      'oneStarCount': insight.oneStarCount,
      'uniqueVisitors': insight.uniqueVisitors,
      'totalLikes': insight.totalLikes,
    };
  }

  static RestaurantInsight _restaurantInsightFromJson(
    Map<String, dynamic> json,
  ) {
    return RestaurantInsight(
      restaurantId: json['restaurantId'],
      restaurantName: json['restaurantName'],
      reviewCount: json['reviewCount'],
      averageRating: json['averageRating'],
      fiveStarCount: json['fiveStarCount'],
      fourStarCount: json['fourStarCount'],
      threeStarCount: json['threeStarCount'],
      twoStarCount: json['twoStarCount'],
      oneStarCount: json['oneStarCount'],
      uniqueVisitors: json['uniqueVisitors'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
    );
  }
}
