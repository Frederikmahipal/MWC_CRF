import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../states/restaurant_state.dart';
import '../services/restaurant_service.dart';
import '../services/review_service.dart';
import '../services/favorites_service.dart';

class RestaurantController extends ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();

  RestaurantState _state = const RestaurantState();
  RestaurantState get state => _state;

  RestaurantController();

  List<Restaurant> get restaurants => _state.restaurants;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  double get averageRating => _state.averageRating;
  int get totalReviews => _state.totalReviews;
  bool get isLoadingRating => _state.isLoadingRating;
  List<Review> get reviews => _state.reviews;
  bool get isLoadingReviews => _state.isLoadingReviews;
  String? get address => _state.address;
  bool get isLoadingAddress => _state.isLoadingAddress;
  bool get isFavorited => _state.isFavorited;
  bool get isLoadingFavorite => _state.isLoadingFavorite;

  Future<void> loadAllRestaurants() async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final restaurants = await _restaurantService.getAllRestaurants();
      _updateState(
        _state.copyWith(
          restaurants: restaurants,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> searchRestaurants(String query) async {
    if (query.isEmpty) {
      await loadAllRestaurants();
      return;
    }

    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final restaurants = await _restaurantService.searchRestaurants(query);
      _updateState(
        _state.copyWith(
          restaurants: restaurants,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      _updateState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadRestaurantDetails(
    String restaurantId, {
    Restaurant? restaurant,
  }) async {
    if (restaurant != null) {
      _updateState(
        _state.copyWith(
          averageRating: restaurant.averageRating,
          totalReviews: restaurant.totalReviews,
          isLoadingRating: false,
        ),
      );
    } else {
      await _loadRatingSummary(restaurantId);
    }

    await Future.wait([
      _loadReviews(restaurantId),
      _loadAddress(restaurantId),
      _checkFavoriteStatus(restaurantId),
    ]);
  }

  Future<void> _loadRatingSummary(String restaurantId) async {
    _updateState(_state.copyWith(isLoadingRating: true));

    try {
      final ratingSummary = await ReviewService.getRestaurantRatingSummary(
        restaurantId,
      );
      _updateState(
        _state.copyWith(
          averageRating: ratingSummary['averageRating'] as double,
          totalReviews: ratingSummary['totalReviews'] as int,
          isLoadingRating: false,
        ),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(
          averageRating: 0.0,
          totalReviews: 0,
          isLoadingRating: false,
        ),
      );
    }
  }

  Future<void> _loadReviews(String restaurantId) async {
    _updateState(_state.copyWith(isLoadingReviews: true));

    try {
      final reviews = await ReviewService.getRestaurantReviews(restaurantId);
      _updateState(
        _state.copyWith(
          reviews: reviews.take(2).toList(),
          isLoadingReviews: false,
        ),
      );
    } catch (e) {
      _updateState(_state.copyWith(reviews: [], isLoadingReviews: false));
    }
  }

  Future<void> _loadAddress(String restaurantId) async {
    _updateState(_state.copyWith(isLoadingAddress: true));

    try {
      final restaurants = await _restaurantService.getAllRestaurants();
      final restaurant = restaurants.firstWhere(
        (r) => r.id == restaurantId,
        orElse: () => throw Exception('Restaurant not found'),
      );
      final address = await _restaurantService.convertToAddress(
        restaurant.location.latitude,
        restaurant.location.longitude,
      );
      _updateState(_state.copyWith(address: address, isLoadingAddress: false));
    } catch (e) {
      _updateState(
        _state.copyWith(
          address: 'Address not available',
          isLoadingAddress: false,
        ),
      );
    }
  }

  Future<void> _checkFavoriteStatus(String restaurantId) async {
    _updateState(_state.copyWith(isLoadingFavorite: true));

    try {
      final isFavorited = await FavoritesService.isFavorited(restaurantId);
      _updateState(
        _state.copyWith(isFavorited: isFavorited, isLoadingFavorite: false),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(isFavorited: false, isLoadingFavorite: false),
      );
    }
  }

  Future<void> toggleFavorite(String restaurantId) async {
    if (_state.isLoadingFavorite) return;

    _updateState(_state.copyWith(isLoadingFavorite: true));

    try {
      if (_state.isFavorited) {
        final success = await FavoritesService.removeFromFavorites(
          restaurantId,
        );
        _updateState(
          _state.copyWith(
            isFavorited: success ? false : _state.isFavorited,
            isLoadingFavorite: false,
          ),
        );
      } else {
        final success = await FavoritesService.addToFavorites(restaurantId);
        _updateState(
          _state.copyWith(
            isFavorited: success ? true : _state.isFavorited,
            isLoadingFavorite: false,
          ),
        );
      }

      // recheck the actual favorite status from Firestore to ensure sync
      final actualStatus = await FavoritesService.isFavorited(restaurantId);
      if (actualStatus != _state.isFavorited) {
        _updateState(_state.copyWith(isFavorited: actualStatus));
      }
    } catch (e) {
      _updateState(
        _state.copyWith(isLoadingFavorite: false, error: e.toString()),
      );
    }
  }

  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  void reset() {
    _state = const RestaurantState();
    notifyListeners();
  }

  void _updateState(RestaurantState newState) {
    _state = newState;
    notifyListeners();
  }
}
