import 'dart:io';
import '../models/restaurant.dart';
import '../services/ml_food_classifier_service.dart';
import '../services/restaurant_service.dart';

/// Service for ML-based food search
/// Takes a photo, classifies the food, and finds restaurants serving that cuisine
class MLFoodSearchService {
  final RestaurantService _restaurantService = RestaurantService();

  /// Classify food from image and find matching restaurants
  Future<MLFoodSearchResult> searchByFoodImage(File imageFile) async {
    try {
      // Classify the food
      final foodLabel = await MLFoodClassifierService.classifyFood(imageFile);

      if (foodLabel == null) {
        return MLFoodSearchResult(
          success: false,
          error:
              'Could not identify the food in the image. Please try another photo.',
          detectedFood: null,
          restaurants: [],
        );
      }

      // Map food label to cuisine type
      final cuisineType = _mapFoodToCuisine(foodLabel);

      // Search for restaurants with that cuisine
      final restaurants = await _restaurantService.getRestaurantsByCuisine(
        cuisineType,
      );

      return MLFoodSearchResult(
        success: true,
        error: null,
        detectedFood: foodLabel,
        cuisineType: cuisineType,
        restaurants: restaurants,
      );
    } catch (e) {
      return MLFoodSearchResult(
        success: false,
        error: 'Error processing image: $e',
        detectedFood: null,
        restaurants: [],
      );
    }
  }

  /// Map detected food label to cuisine type for restaurant search
  /// Only uses actual labels from food_labels.txt
  String _mapFoodToCuisine(String foodLabel) {
    final labelLower = foodLabel.toLowerCase();

    // Italian - only actual labels from file
    if (labelLower == 'lasagne' ||
        labelLower == 'salami' ||
        labelLower == 'pepperoni' ||
        labelLower.contains('prosciutto') ||
        labelLower == 'risotto' ||
        labelLower == 'spaghetti' ||
        labelLower.contains('pizza') ||
        labelLower.contains('pasta')) {
      return 'italian';
    }

    // Japanese - only actual labels from file
    if (labelLower == 'sushi' ||
        labelLower == 'ramen' ||
        labelLower == 'udon' ||
        labelLower.contains('miso') ||
        labelLower == 'dango' ||
        labelLower == 'onigiri' ||
        labelLower == 'takoyaki' ||
        labelLower == 'tempura' ||
        labelLower == 'mochi' ||
        labelLower == 'bento' ||
        labelLower == 'okonomiyaki' ||
        labelLower == 'tonkatsu' ||
        labelLower == 'oyakodon' ||
        labelLower == 'katsudon') {
      return 'japanese';
    }

    // Chinese - only actual labels from file
    if (labelLower == 'dumpling' ||
        labelLower == 'peking duck' ||
        labelLower.contains('dim sum') ||
        labelLower == 'wonton' ||
        labelLower == 'chow mein' ||
        labelLower == 'lo mein' ||
        labelLower.contains('char siu') ||
        labelLower == 'xiaolongbao' ||
        labelLower == 'jiaozi' ||
        labelLower == 'baozi' ||
        labelLower == 'congee' ||
        labelLower.contains('hot pot') ||
        labelLower == 'orange chicken' ||
        labelLower.contains('sweet and sour')) {
      return 'chinese';
    }

    // Indian - only actual labels from file
    if (labelLower.contains('curry') ||
        labelLower.contains('tandoori') ||
        labelLower == 'samosa' ||
        labelLower.contains('dal') ||
        labelLower.contains('tikka') ||
        labelLower.contains('paneer') ||
        labelLower.contains('roti') ||
        labelLower == 'idli' ||
        labelLower == 'pakora' ||
        labelLower == 'butter chicken' ||
        labelLower.contains('palak') ||
        labelLower.contains('chana')) {
      return 'indian';
    }

    // Mexican - only actual labels from file
    if (labelLower == 'taco' ||
        labelLower == 'burrito' ||
        labelLower == 'quesadilla' ||
        labelLower == 'enchilada' ||
        labelLower == 'nachos' ||
        labelLower == 'fajita' ||
        labelLower.contains('chili') ||
        labelLower == 'tamale' ||
        labelLower == 'pozole' ||
        labelLower == 'carnitas' ||
        labelLower.contains('al pastor') ||
        labelLower == 'churro' ||
        labelLower == 'elote') {
      return 'mexican';
    }

    // Thai - only actual labels from file
    if (labelLower == 'pad thai' ||
        labelLower == 'tom yum' ||
        labelLower == 'green curry' ||
        labelLower == 'red curry' ||
        labelLower == 'massaman' ||
        labelLower.contains('phanaeng') ||
        labelLower == 'larb' ||
        labelLower == 'satay' ||
        labelLower == 'khao soi' ||
        labelLower == 'mango sticky rice') {
      return 'thai';
    }

    // American - only actual labels from file
    if (labelLower.contains('burger') ||
        labelLower == 'hot dog' ||
        labelLower.contains('cheeseburger') ||
        labelLower.contains('sandwich') ||
        labelLower.contains('steak') ||
        labelLower.contains('buffalo') ||
        labelLower == 'cornbread') {
      return 'american';
    }

    // Seafood - only actual labels from file
    if (labelLower.contains('fish') ||
        labelLower.contains('lobster') ||
        labelLower.contains('crab') ||
        labelLower.contains('shrimp') ||
        labelLower.contains('prawn') ||
        labelLower.contains('oyster') ||
        labelLower.contains('clam') ||
        labelLower == 'squid' ||
        labelLower == 'octopus' ||
        labelLower.contains('tuna') ||
        labelLower == 'ceviche') {
      return 'seafood';
    }

    // French - only actual labels from file
    if (labelLower == 'ratatouille' ||
        labelLower == 'coq au vin' ||
        labelLower == 'bouillabaisse' ||
        labelLower == 'quiche' ||
        labelLower == 'foie gras' ||
        labelLower == 'cassoulet' ||
        labelLower == 'tarte tatin' ||
        labelLower == 'soufflé' ||
        labelLower.contains('crème brûlée') ||
        labelLower == 'crêpe') {
      return 'french';
    }

    // Greek - only actual labels from file
    if (labelLower == 'gyro' ||
        labelLower == 'souvlaki' ||
        labelLower == 'moussaka' ||
        labelLower == 'spanakopita' ||
        labelLower == 'baklava') {
      return 'greek';
    }

    // Spanish - only actual labels from file
    if (labelLower == 'paella' ||
        labelLower == 'gazpacho' ||
        labelLower == 'chorizo' ||
        labelLower.contains('jamón')) {
      return 'spanish';
    }

    // Default: try the label itself
    return foodLabel;
  }
}

/// Result of ML food search
class MLFoodSearchResult {
  final bool success;
  final String? error;
  final String? detectedFood;
  final String? cuisineType;
  final List<Restaurant> restaurants;

  MLFoodSearchResult({
    required this.success,
    this.error,
    this.detectedFood,
    this.cuisineType,
    required this.restaurants,
  });
}
