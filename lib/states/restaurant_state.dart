import '../models/restaurant.dart';
import '../models/review.dart';

class RestaurantState {
  final List<Restaurant> restaurants;
  final bool isLoading;
  final String? error;
  final double averageRating;
  final int totalReviews;
  final bool isLoadingRating;
  final List<Review> reviews;
  final bool isLoadingReviews;
  final String? address;
  final bool isLoadingAddress;
  final bool isFavorited;
  final bool isLoadingFavorite;

  const RestaurantState({
    this.restaurants = const [],
    this.isLoading = false,
    this.error,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isLoadingRating = false,
    this.reviews = const [],
    this.isLoadingReviews = false,
    this.address,
    this.isLoadingAddress = false,
    this.isFavorited = false,
    this.isLoadingFavorite = false,
  });

  RestaurantState copyWith({
    List<Restaurant>? restaurants,
    bool? isLoading,
    String? error,
    double? averageRating,
    int? totalReviews,
    bool? isLoadingRating,
    List<Review>? reviews,
    bool? isLoadingReviews,
    String? address,
    bool? isLoadingAddress,
    bool? isFavorited,
    bool? isLoadingFavorite,
  }) {
    return RestaurantState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isLoadingRating: isLoadingRating ?? this.isLoadingRating,
      reviews: reviews ?? this.reviews,
      isLoadingReviews: isLoadingReviews ?? this.isLoadingReviews,
      address: address ?? this.address,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      isFavorited: isFavorited ?? this.isFavorited,
      isLoadingFavorite: isLoadingFavorite ?? this.isLoadingFavorite,
    );
  }

  @override
  String toString() {
    return 'RestaurantState('
        'restaurants: ${restaurants.length}, '
        'isLoading: $isLoading, '
        'error: $error, '
        'averageRating: $averageRating, '
        'totalReviews: $totalReviews, '
        'isLoadingRating: $isLoadingRating, '
        'reviews: ${reviews.length}, '
        'isLoadingReviews: $isLoadingReviews, '
        'address: $address, '
        'isLoadingAddress: $isLoadingAddress, '
        'isFavorited: $isFavorited, '
        'isLoadingFavorite: $isLoadingFavorite'
        ')';
  }
}
