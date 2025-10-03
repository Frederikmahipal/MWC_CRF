import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

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

    // Create user object for consistent data handling
    final user = User.create(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      avatarEmoji: avatarEmoji,
      phoneNumber: '', // Will be set when user completes phone verification
    );

    await prefs.setBool(_keyOnboardingCompleted, true);
    await prefs.setString(_keyCurrentUserId, user.id);
    await prefs.setString(_keyUserName, user.fullName);
    await prefs.setString(_keyUserAvatar, user.avatarEmoji);
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
