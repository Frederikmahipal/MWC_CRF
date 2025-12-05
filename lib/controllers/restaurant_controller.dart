import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../states/restaurant_state.dart';
import '../services/restaurant_service.dart';

class RestaurantController extends ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();

  RestaurantState _state = const RestaurantState();
  RestaurantState get state => _state;

  RestaurantController();

  List<Restaurant> get restaurants => _state.restaurants;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

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
