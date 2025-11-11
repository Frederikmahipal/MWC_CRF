import '../repositories/remote/firestore_service.dart';
import '../core/onboarding_controller.dart';
import '../core/insights_refresh_notifier.dart';

class FavoritesService {
  static Future<bool> addToFavorites(String restaurantId) async {
    try {
      final userData = await OnboardingController.getCurrentUser();
      final userId = userData['userId'];

      if (userId == null) {
        return false;
      }

      await FirestoreService.addToFavorites(userId, restaurantId);

      // Notify insights page to refresh (likes changed)
      InsightsRefreshNotifier().notifyRefresh(DataChangeType.likes);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> removeFromFavorites(String restaurantId) async {
    try {
      final userData = await OnboardingController.getCurrentUser();
      final userId = userData['userId'];

      if (userId == null) {
        return false;
      }

      await FirestoreService.removeFromFavorites(userId, restaurantId);

      // Notify insights page to refresh (likes changed)
      InsightsRefreshNotifier().notifyRefresh(DataChangeType.likes);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isFavorited(String restaurantId) async {
    try {
      final userData = await OnboardingController.getCurrentUser();
      final userId = userData['userId'];

      if (userId == null) return false;

      return await FirestoreService.isRestaurantFavorited(userId, restaurantId);
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> getUserFavorites() async {
    try {
      final userData = await OnboardingController.getCurrentUser();
      final userId = userData['userId'];

      if (userId == null) return [];

      final doc = await FirestoreService.getUserFavorites(userId);
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return [];

      return data.entries
          .where(
            (entry) =>
                entry.value == true ||
                (entry.value is String && entry.value.toString().isNotEmpty),
          )
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
