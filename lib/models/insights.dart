class MonthlyInsights {
  final int year;
  final int month;
  final String monthName;
  final List<RestaurantInsight> topRestaurants;
  final List<RestaurantInsight> mostReviewedRestaurants;
  final List<RestaurantInsight> highestRatedRestaurants;
  final List<RestaurantInsight> mostVisitedRestaurants;
  final List<RestaurantInsight> mostLikedRestaurants;
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution;

  const MonthlyInsights({
    required this.year,
    required this.month,
    required this.monthName,
    required this.topRestaurants,
    required this.mostReviewedRestaurants,
    required this.highestRatedRestaurants,
    required this.mostVisitedRestaurants,
    required this.mostLikedRestaurants,
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
  });

  @override
  String toString() {
    return 'MonthlyInsights(year: $year, month: $month, totalReviews: $totalReviews, averageRating: $averageRating)';
  }
}

class RestaurantInsight {
  final String restaurantId;
  final String restaurantName;
  final int reviewCount;
  final double averageRating;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final int uniqueVisitors;
  final int totalLikes;

  const RestaurantInsight({
    required this.restaurantId,
    required this.restaurantName,
    required this.reviewCount,
    required this.averageRating,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
    this.uniqueVisitors = 0,
    this.totalLikes = 0,
  });

  double get ratingPercentage {
    if (reviewCount == 0) return 0.0;
    return (fiveStarCount + fourStarCount) / reviewCount * 100;
  }

  @override
  String toString() {
    return 'RestaurantInsight(restaurantId: $restaurantId, restaurantName: $restaurantName, reviewCount: $reviewCount, averageRating: $averageRating)';
  }
}
