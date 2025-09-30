import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_settings.dart';

class OnboardingController {
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyCurrentUserId = 'current_user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatar = 'user_avatar';

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> completeOnboarding({
    required String userId,
    required String firstName,
    required String lastName,
    required String avatarEmoji,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyOnboardingCompleted, true);
    await prefs.setString(_keyCurrentUserId, userId);
    await prefs.setString(_keyUserName, '$firstName $lastName');
    await prefs.setString(_keyUserAvatar, avatarEmoji);
  }

  static Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'userId': prefs.getString(_keyCurrentUserId),
      'name': prefs.getString(_keyUserName),
      'avatar': prefs.getString(_keyUserAvatar),
    };
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyOnboardingCompleted);
    await prefs.remove(_keyCurrentUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserAvatar);
  }

  static String generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }
}
