import 'package:flutter/cupertino.dart';

class AppSettings {
  static const Color primaryColor = Color(0xFF10B981); 
  static const Color secondaryColor = Color(0xFF64748B); 
  static const Color accentColor = Color(0xFF3B82F6); 
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B); 
  static const Color errorColor = Color(0xFFEF4444); 

  static Color getBackgroundColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF0F1419)
        : const Color(0xFFF7F3F0);
  }

  static Color getSurfaceColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF1A2332)
        : const Color(0xFFFEFCFB);
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
        ? const Color(0xFF2A3441)
        : const Color(0xFFE8E4E1);
  }

  static Color getBorderColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF2A3441)
        : const Color(0xFFE8E4E1);
  }

  static Color getPrimaryColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0xFF34D399) 
        : primaryColor;
  }

  static Color getShadowColor(BuildContext context) {
    return CupertinoTheme.brightnessOf(context) == Brightness.dark
        ? const Color(0x60000000)
        : const Color(0x1A10B981); 
  }

  static const String appName = 'Copenhagen Restaurant Finder';
  static const String appVersion = '1.0.0';


  static const double defaultMapZoom = 13.0;
  static const double defaultSearchRadius = 5.0;

  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;

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

  static const String keyUsername = 'username';
  static const String keyPreferredCuisines = 'preferred_cuisines';
  static const String keyLastLocation = 'last_location';
  static const String keyAppFirstLaunch = 'app_first_launch';
}
