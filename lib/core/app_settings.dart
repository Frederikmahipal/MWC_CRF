import 'package:flutter/cupertino.dart';

class AppSettings {
  static const Color primaryColor = Color(0xFFD97D55);
  static const Color secondaryColor = Color(0xFF95A5A6); // Muted gray
  static const Color accentColor = Color(0xFFF39C12); // Golden orange
  static const Color successColor = Color(0xFF27AE60); // Green for success
  static const Color warningColor = Color(0xFFF39C12); // Orange for warnings
  static const Color errorColor = Color(0xFFE74C3C); // Red for errors

  static Color getBackgroundColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF1A1A1A) // Darker, warmer dark mode
        : const Color(
            0xFFFB8C4A9,
          ); // Warm cream background that complements red
  }

  static Color getSurfaceColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF2D2D2D) // Warmer dark surface
        : const Color(0xFFFF4E9D7); // Light warm surface that stands out
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

  static Color getChipColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF3D3D3D) // Dark chip background
        : const Color(0xFFF1F3F4); // Light chip background
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
