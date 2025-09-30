import 'package:flutter/cupertino.dart';

class AppSettings {
  // Theme colors
  static const Color primaryColor = CupertinoColors.systemBlue;
  static const Color secondaryColor = CupertinoColors.systemGrey;
  static const Color backgroundColor = CupertinoColors.systemBackground;
  static const Color surfaceColor = CupertinoColors.systemGrey6;
  
  // App configuration
  static const String appName = 'Copenhagen Restaurant Finder';
  static const String appVersion = '1.0.0';
  
  // API settings
  static const String overpassApiUrl = 'https://overpass-api.de/api/interpreter';
  static const double defaultMapZoom = 13.0;
  static const double defaultSearchRadius = 5.0; // km
  
  // UI settings
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;
  
  // Cuisine types
  static const List<String> cuisineTypes = [
    'All',
    'Italian',
    'Asian',
    'Danish',
    'French',
    'Mediterranean',
    'American',
    'Mexican',
    'Indian',
    'Thai',
    'Japanese',
    'Chinese',
    'Korean',
    'Vietnamese',
    'Middle Eastern',
    'Vegetarian',
    'Vegan',
  ];
  
  // Filter options
  static const List<String> filterOptions = [
    'Open Now',
    'Outdoor Seating',
    'Wheelchair Accessible',
    'Takeaway',
    'Delivery',
    'WiFi',
    'Pet Friendly',
  ];
  
  // SharedPreferences keys
  static const String keyUsername = 'username';
  static const String keyPreferredCuisines = 'preferred_cuisines';
  static const String keyDefaultFilters = 'default_filters';
  static const String keyLastLocation = 'last_location';
  static const String keyAppFirstLaunch = 'app_first_launch';
}
