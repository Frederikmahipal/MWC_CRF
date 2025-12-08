import '../models/restaurant.dart';

class RestaurantState {
  final List<Restaurant> restaurants;
  final bool isLoading;
  final String? error;

  const RestaurantState({
    this.restaurants = const [],
    this.isLoading = false,
    this.error,
  });

  RestaurantState copyWith({
    List<Restaurant>? restaurants,
    bool? isLoading,
    String? error,
  }) {
    return RestaurantState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'RestaurantState('
        'restaurants: ${restaurants.length}, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }
}
