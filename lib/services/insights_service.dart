import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import '../models/insights.dart';

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
    int monthsBack = 6,
  }) async {
    try {
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
          final monthlyInsight = _generateMonthlyInsight(
            year,
            month,
            monthlyReviews,
          );
          insights.add(monthlyInsight);
        }
      }

      return insights;
    } catch (e) {
      print('Error getting monthly insights: $e');
      return [];
    }
  }

  static Future<MonthlyInsights?> getInsightsForMonth(
    int year,
    int month,
  ) async {
    try {
      final allReviews = await _getAllReviews();

      final monthlyReviews = allReviews.where((review) {
        return review.createdAt.year == year && review.createdAt.month == month;
      }).toList();

      if (monthlyReviews.isEmpty) {
        return null;
      }

      return _generateMonthlyInsight(year, month, monthlyReviews);
    } catch (e) {
      print('Error getting insights for month: $e');
      return null;
    }
  }

  static Future<List<Review>> _getAllReviews() async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .get();

      return querySnapshot.docs.map((doc) {
        return Review.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('Error getting all reviews: $e');
      return [];
    }
  }

  static MonthlyInsights _generateMonthlyInsight(
    int year,
    int month,
    List<Review> reviews,
  ) {
    final restaurantReviews = <String, List<Review>>{};

    for (final review in reviews) {
      if (!restaurantReviews.containsKey(review.restaurantId)) {
        restaurantReviews[review.restaurantId] = [];
      }
      restaurantReviews[review.restaurantId]!.add(review);
    }

    final restaurantInsights = <RestaurantInsight>[];

    for (final entry in restaurantReviews.entries) {
      final restaurantId = entry.key;
      final restaurantReviews = entry.value;
      final restaurantName = restaurantReviews.first.restaurantName;

      final insight = _calculateRestaurantInsight(
        restaurantId,
        restaurantName,
        restaurantReviews,
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
      totalReviews: totalReviews,
      averageRating: averageRating,
      ratingDistribution: ratingDistribution,
    );
  }

  static RestaurantInsight _calculateRestaurantInsight(
    String restaurantId,
    String restaurantName,
    List<Review> reviews,
  ) {
    final reviewCount = reviews.length;
    final averageRating =
        reviews.fold(0.0, (sum, review) => sum + review.rating) / reviewCount;

    final fiveStarCount = reviews.where((r) => r.rating == 5).length;
    final fourStarCount = reviews.where((r) => r.rating == 4).length;
    final threeStarCount = reviews.where((r) => r.rating == 3).length;
    final twoStarCount = reviews.where((r) => r.rating == 2).length;
    final oneStarCount = reviews.where((r) => r.rating == 1).length;

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
    );
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
      print('Error getting best restaurant for month: $e');
      return null;
    }
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
      print('Error getting top 5-star restaurants for month: $e');
      return [];
    }
  }

  static Future<void> printInsightsSummary() async {
    try {
      final insights = await getMonthlyInsights(monthsBack: 3);
      print('📊 Insights Summary:');
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
      print('Error printing insights summary: $e');
    }
  }
}
