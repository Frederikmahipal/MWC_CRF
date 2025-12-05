import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import '../models/insights.dart';
import 'insights_cache_service.dart';

class InsightsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _reviewsCollection = 'reviews';

  static final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static Future<List<MonthlyInsights>> getMonthlyInsights({
    int monthsBack = 36, // 3 years to match seeder
  }) async {
    try {
      // Try to get from cache first
      final cachedInsights = await InsightsCacheService.getCachedInsights();
      if (cachedInsights != null) {
        return cachedInsights;
      }

      // Cache miss - generate fresh insights
      final allReviews = await _getAllReviews();
      final insights = <MonthlyInsights>[];

      final now = DateTime.now();

      for (int i = 0; i < monthsBack; i++) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        final year = targetDate.year;
        final month = targetDate.month;

        final monthlyReviews = allReviews.where((review) {
          return review.createdAt.year == year &&
              review.createdAt.month == month;
        }).toList();

        if (monthlyReviews.isNotEmpty) {
          final monthlyInsight = await _generateMonthlyInsight(
            year,
            month,
            monthlyReviews,
          );
          insights.add(monthlyInsight);
        }
      }

      // Cache the results
      await InsightsCacheService.cacheInsights(insights);

      return insights;
    } catch (e) {
      return [];
    }
  }

  static Future<MonthlyInsights?> getInsightsForMonth(
    int year,
    int month,
  ) async {
    try {
      // Try to get from cache first
      final cachedInsights = await InsightsCacheService.getCachedInsights();
      if (cachedInsights != null) {
        // Find the specific month in cached data
        for (final insight in cachedInsights) {
          if (insight.year == year && insight.month == month) {
            return insight;
          }
        }
      }

      // Cache miss - generate fresh insight for this month
      final allReviews = await _getAllReviews();

      final monthlyReviews = allReviews.where((review) {
        return review.createdAt.year == year && review.createdAt.month == month;
      }).toList();

      if (monthlyReviews.isEmpty) {
        return null;
      }

      return await _generateMonthlyInsight(year, month, monthlyReviews);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Review>> _getAllReviews() async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .get()
          .timeout(const Duration(seconds: 60));

      final reviews = querySnapshot.docs.map((doc) {
        return Review.fromMap(doc.id, doc.data());
      }).toList();

      return reviews;
    } catch (e) {
      return [];
    }
  }

  static Future<MonthlyInsights> _generateMonthlyInsight(
    int year,
    int month,
    List<Review> reviews,
  ) async {
    final restaurantReviews = <String, List<Review>>{};

    for (final review in reviews) {
      if (!restaurantReviews.containsKey(review.restaurantId)) {
        restaurantReviews[review.restaurantId] = [];
      }
      restaurantReviews[review.restaurantId]!.add(review);
    }

    // Only fetch data for restaurants that have reviews this month (much more efficient)
    final restaurantIds = restaurantReviews.keys.toList();
    final visitorsData = await _getMonthlyVisitorsDataForRestaurants(
      restaurantIds,
      year,
      month,
    );
    final likesData = await _getMonthlyLikesDataForRestaurants(
      restaurantIds,
      year,
      month,
    );

    final restaurantInsights = <RestaurantInsight>[];

    for (final entry in restaurantReviews.entries) {
      final restaurantId = entry.key;
      final restaurantReviews = entry.value;
      final restaurantName = restaurantReviews.first.restaurantName;

      final insight = _calculateRestaurantInsight(
        restaurantId,
        restaurantName,
        restaurantReviews,
        visitorsData,
        likesData,
      );
      restaurantInsights.add(insight);
    }

    final topRestaurants = List<RestaurantInsight>.from(restaurantInsights)
      ..sort((a, b) => b.ratingPercentage.compareTo(a.ratingPercentage));

    final mostReviewedRestaurants = List<RestaurantInsight>.from(
      restaurantInsights,
    )..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));

    final highestRatedRestaurants = List<RestaurantInsight>.from(
      restaurantInsights,
    )..sort((a, b) => b.averageRating.compareTo(a.averageRating));

    final mostVisitedRestaurants = List<RestaurantInsight>.from(
      restaurantInsights,
    )..sort((a, b) => b.uniqueVisitors.compareTo(a.uniqueVisitors));

    final mostLikedRestaurants = List<RestaurantInsight>.from(
      restaurantInsights,
    )..sort((a, b) => b.totalLikes.compareTo(a.totalLikes));

    final totalReviews = reviews.length;
    final averageRating =
        reviews.fold(0.0, (sum, review) => sum + review.rating) / totalReviews;

    final ratingDistribution = <int, int>{};
    for (final review in reviews) {
      ratingDistribution[review.rating] =
          (ratingDistribution[review.rating] ?? 0) + 1;
    }

    return MonthlyInsights(
      year: year,
      month: month,
      monthName: _monthNames[month - 1],
      topRestaurants: topRestaurants.take(5).toList(),
      mostReviewedRestaurants: mostReviewedRestaurants.take(5).toList(),
      highestRatedRestaurants: highestRatedRestaurants.take(5).toList(),
      mostVisitedRestaurants: mostVisitedRestaurants.take(5).toList(),
      mostLikedRestaurants: mostLikedRestaurants.take(5).toList(),
      totalReviews: totalReviews,
      averageRating: averageRating,
      ratingDistribution: ratingDistribution,
    );
  }

  static RestaurantInsight _calculateRestaurantInsight(
    String restaurantId,
    String restaurantName,
    List<Review> reviews,
    Map<String, int> allVisitorsData,
    Map<String, int> allLikesData,
  ) {
    final reviewCount = reviews.length;
    final averageRating =
        reviews.fold(0.0, (sum, review) => sum + review.rating) / reviewCount;

    final fiveStarCount = reviews.where((r) => r.rating == 5).length;
    final fourStarCount = reviews.where((r) => r.rating == 4).length;
    final threeStarCount = reviews.where((r) => r.rating == 3).length;
    final twoStarCount = reviews.where((r) => r.rating == 2).length;
    final oneStarCount = reviews.where((r) => r.rating == 1).length;

    // Get unique visitors count from batched data
    final uniqueVisitors = allVisitorsData[restaurantId] ?? 0;

    // Get total likes count from batched data
    final totalLikes = allLikesData[restaurantId] ?? 0;

    return RestaurantInsight(
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      reviewCount: reviewCount,
      averageRating: averageRating,
      fiveStarCount: fiveStarCount,
      fourStarCount: fourStarCount,
      threeStarCount: threeStarCount,
      twoStarCount: twoStarCount,
      oneStarCount: oneStarCount,
      uniqueVisitors: uniqueVisitors,
      totalLikes: totalLikes,
    );
  }

  /// Fetch monthly visitors data for specific restaurants and month
  static Future<Map<String, int>> _getMonthlyVisitorsDataForRestaurants(
    List<String> restaurantIds,
    int year,
    int month,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_visits')
          .get()
          .timeout(const Duration(seconds: 30));

      final visitorsData = <String, int>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        for (final restaurantId in data.keys) {
          // Only count restaurants we're interested in
          if (restaurantIds.contains(restaurantId)) {
            final visitTimestamp = data[restaurantId];

            // Check if the visit happened in the specified month
            if (visitTimestamp != null) {
              DateTime? visitDate;

              if (visitTimestamp is String) {
                visitDate = DateTime.tryParse(visitTimestamp);
              } else if (visitTimestamp is Timestamp) {
                visitDate = visitTimestamp.toDate();
              }

              if (visitDate != null &&
                  visitDate.year == year &&
                  visitDate.month == month) {
                visitorsData[restaurantId] =
                    (visitorsData[restaurantId] ?? 0) + 1;
              }
            }
          }
        }
      }

      return visitorsData;
    } catch (e) {
      return {};
    }
  }

  /// Fetch monthly likes data for specific restaurants and month
  static Future<Map<String, int>> _getMonthlyLikesDataForRestaurants(
    List<String> restaurantIds,
    int year,
    int month,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('favorites')
          .get()
          .timeout(const Duration(seconds: 30));

      final likesData = <String, int>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        for (final entry in data.entries) {
          final restaurantId = entry.key;
          final likeValue = entry.value;

          // Only count restaurants we're interested in
          if (restaurantIds.contains(restaurantId)) {
            // Check if this is a favorited restaurant
            final isFavorited =
                likeValue == true ||
                (likeValue is String && likeValue.toString().isNotEmpty);

            if (isFavorited) {
              // Check if the like happened in the specified month
              DateTime? likeDate;

              if (likeValue is String) {
                likeDate = DateTime.tryParse(likeValue);
              } else if (likeValue is Timestamp) {
                likeDate = likeValue.toDate();
              }

              // If it's a boolean true (manual like), count it as current month
              // If it's a timestamp, check if it's in the specified month
              if (likeValue == true ||
                  (likeDate != null &&
                      likeDate.year == year &&
                      likeDate.month == month)) {
                likesData[restaurantId] = (likesData[restaurantId] ?? 0) + 1;
              }
            }
          }
        }
      }

      return likesData;
    } catch (e) {
      return {};
    }
  }

  static Future<RestaurantInsight?> getBestRestaurantForMonth(
    int year,
    int month,
  ) async {
    try {
      final insights = await getInsightsForMonth(year, month);
      if (insights == null || insights.topRestaurants.isEmpty) {
        return null;
      }
      return insights.topRestaurants.first;
    } catch (e) {
      return null;
    }
  }

  /// Get insights for specific months (for lazy loading)
  static Future<List<MonthlyInsights?>> getInsightsForMonths(
    List<Map<String, int>> months,
  ) async {
    try {
      // Try to get from cache first
      final cachedInsights = await InsightsCacheService.getCachedInsights();
      if (cachedInsights != null) {
        final results = <MonthlyInsights?>[];
        final monthsToFetch = <Map<String, int>>[];

        // Check which months are in cache and which need to be fetched
        for (final monthData in months) {
          final year = monthData['year']!;
          final month = monthData['month']!;

          MonthlyInsights? insight;
          try {
            insight = cachedInsights.firstWhere(
              (insight) => insight.year == year && insight.month == month,
            );
          } catch (e) {
            monthsToFetch.add(monthData);
            insight = null;
          }
          results.add(insight);
        }

        // If all months are cached, return results
        if (monthsToFetch.isEmpty) {
          return results;
        }

        // Fetch missing months from Firestore
        final fetchedInsights = await _fetchInsightsForMonths(monthsToFetch);

        // Update results with fetched insights
        int fetchIndex = 0;
        for (int i = 0; i < results.length; i++) {
          if (results[i] == null) {
            results[i] = fetchedInsights[fetchIndex];
            fetchIndex++;
          }
        }

        return results;
      }

      // Cache miss - generate fresh insights
      return await _fetchInsightsForMonths(months);
    } catch (e) {
      return List.filled(months.length, null);
    }
  }

  /// Helper method to fetch insights for specific months from Firestore
  static Future<List<MonthlyInsights?>> _fetchInsightsForMonths(
    List<Map<String, int>> months,
  ) async {
    try {
      final allReviews = await _getAllReviews();
      final results = <MonthlyInsights?>[];

      for (final monthData in months) {
        final year = monthData['year']!;
        final month = monthData['month']!;

        final monthlyReviews = allReviews.where((review) {
          return review.createdAt.year == year &&
              review.createdAt.month == month;
        }).toList();

        if (monthlyReviews.isNotEmpty) {
          final insight = await _generateMonthlyInsight(
            year,
            month,
            monthlyReviews,
          );
          results.add(insight);
        } else {
          results.add(null);
        }
      }

      // Cache the results if we successfully got data
      final validInsights = results
          .where((insight) => insight != null)
          .cast<MonthlyInsights>()
          .toList();
      if (validInsights.isNotEmpty) {
        await InsightsCacheService.cacheInsights(validInsights);
      }

      return results;
    } catch (e) {
      return List.filled(months.length, null);
    }
  }

  /// Clear the insights cache manually
  static Future<void> clearCache() async {
    await InsightsCacheService.invalidateCache();
  }

  /// Get list of months that have data (for lazy loading)
  static Future<List<Map<String, int>>> getAvailableMonths({
    int monthsBack = 36, // 3 years to match seeder
  }) async {
    try {
      // Instead of reading all reviews, just return recent months
      // This is much faster and the seeder creates data for recent months anyway
      final months = <Map<String, int>>[];
      final now = DateTime.now();

      for (int i = 0; i < monthsBack; i++) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        final year = targetDate.year;
        final month = targetDate.month;

        // Add all recent months - we'll check if they have data when we actually load them
        months.add({'year': year, 'month': month});
      }

      return months;
    } catch (e) {
      return [];
    }
  }

  /// Get total visits and likes for a specific restaurant
  static Future<Map<String, int>> getRestaurantTotals(
    String restaurantId,
  ) async {
    try {

      // Get total visits
      final visitsSnapshot = await _firestore
          .collection('user_visits')
          .get()
          .timeout(const Duration(seconds: 30));

      int totalVisits = 0;
      for (final doc in visitsSnapshot.docs) {
        final data = doc.data();
        // Check if this user document contains the restaurant ID
        if (data.containsKey(restaurantId)) {
          totalVisits++;
        }
      }

      // Get total likes
      final favoritesSnapshot = await _firestore
          .collection('favorites')
          .get()
          .timeout(const Duration(seconds: 30));

      int totalLikes = 0;
      for (final doc in favoritesSnapshot.docs) {
        final data = doc.data();
        // Check if this user document contains the restaurant ID
        if (data.containsKey(restaurantId)) {
          final value = data[restaurantId];
          // Check if it's favorited (true or timestamp string)
          if (value == true ||
              (value is String && value.toString().isNotEmpty)) {
            totalLikes++;
          }
        }
      }

      print(
        '📊 Restaurant $restaurantId: $totalVisits visits, $totalLikes likes',
      );
      return {'visits': totalVisits, 'likes': totalLikes};
    } catch (e) {
      print('Error getting restaurant totals for $restaurantId: $e');
      return {'visits': 0, 'likes': 0};
    }
  }

  /// Invalidate cache when data changes (call this from other services)
  static Future<void> invalidateCache() async {
    await InsightsCacheService.invalidateCache();
  }

  static Future<List<RestaurantInsight>> getTopFiveStarRestaurantsForMonth(
    int year,
    int month,
  ) async {
    try {
      final insights = await getInsightsForMonth(year, month);
      if (insights == null) {
        return [];
      }

      final restaurants = insights.topRestaurants
          .where((r) => r.fiveStarCount > 0)
          .toList();
      restaurants.sort((a, b) => b.fiveStarCount.compareTo(a.fiveStarCount));

      return restaurants.take(5).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> printInsightsSummary() async {
    try {
      final insights = await getMonthlyInsights(monthsBack: 3);
      for (final insight in insights) {
        print(
          '${insight.monthName} ${insight.year}: ${insight.totalReviews} reviews, avg: ${insight.averageRating.toStringAsFixed(1)}',
        );
        if (insight.topRestaurants.isNotEmpty) {
          print(
            '  Top restaurant: ${insight.topRestaurants.first.restaurantName} (${insight.topRestaurants.first.averageRating.toStringAsFixed(1)} ⭐)',
          );
        }
      }
    } catch (e) {
      // Summary printing failure is not critical
    }
  }
}
