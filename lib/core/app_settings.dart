import 'package:flutter/cupertino.dart';

class AppSettings {
  static const Color primaryColor = CupertinoColors.systemBlue;
  static const Color secondaryColor = CupertinoColors.systemGrey;

  static Color getBackgroundColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF1C1C1E) 
        : const Color(0xFFF2F2F7); 
  }

  static Color getSurfaceColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF2C2C2E) 
        : const Color(0xFFFFFFFF); 
  }

  static Color getTextColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFFFFFFFF) 
        : const Color(0xFF000000); 
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF8E8E93) 
        : const Color(0xFF6D6D70); 
  }

  static const String appName = 'Copenhagen Restaurant Finder';
  static const String appVersion = '1.0.0';

  static const String overpassApiUrl =
      'https://overpass-api.de/api/interpreter';
  static const double defaultMapZoom = 13.0;
  static const double defaultSearchRadius = 5.0; // km

  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

// TODO update when api is handled
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

  // TODO update when api is handled
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
