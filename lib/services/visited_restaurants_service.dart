import '../repositories/remote/firestore_service.dart';
import '../core/onboarding_controller.dart';
import '../core/insights_refresh_notifier.dart';

class VisitedRestaurantsService {
  static Future<bool> markAsVisited(String restaurantId) async {
    try {
      final userData = await OnboardingController.getCurrentUser();
      final userId = userData['userId'];

      if (userId == null) {
        return false;
      }

      await FirestoreService.markRestaurantAsVisited(userId, restaurantId);

      // Notify insights page to refresh (visits changed)
      InsightsRefreshNotifier().notifyRefresh(DataChangeType.visits);

      return true;
    } catch (e) {
      print('Error marking restaurant as visited: $e');
      return false;
    }
  }

  static Future<bool> removeFromVisited(String restaurantId) async {
    try {
      final userData = await OnboardingController.getCurrentUser();
      final userId = userData['userId'];

      if (userId == null) {
        return false;
      }

      await FirestoreService.removeRestaurantFromVisited(userId, restaurantId);

      // Notify insights page to refresh (visits changed)
      InsightsRefreshNotifier().notifyRefresh(DataChangeType.visits);

      return true;
    } catch (e) {
      print('Error removing restaurant from visited: $e');
      return false;
    }
  }

  static Future<bool> hasVisited(String restaurantId) async {
    try {
      final userData = await OnboardingController.getCurrentUser();
      final userId = userData['userId'];

      if (userId == null) return false;

      return await FirestoreService.hasUserVisitedRestaurant(
        userId,
        restaurantId,
      );
    } catch (e) {
      print('Error checking if restaurant was visited: $e');
      return false;
    }
  }


  static Future<List<String>> getVisitedRestaurants() async {
    try {
      final userData = await OnboardingController.getCurrentUser();
      final userId = userData['userId'];

      if (userId == null) return [];

      final doc = await FirestoreService.getUserVisitedRestaurants(userId);
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return [];

      return data.keys.toList();
    } catch (e) {
      print('Error getting visited restaurants: $e');
      return [];
    }
  }

  static Future<int> getUniqueVisitorsCount(String restaurantId) async {
    try {
      return await FirestoreService.getUniqueVisitorsCount(restaurantId);
    } catch (e) {
      print('Error getting unique visitors count: $e');
      return 0;
    }
  }

  static Future<List<String>> getUsersWhoVisited(String restaurantId) async {
    try {
      return await FirestoreService.getUsersWhoVisited(restaurantId);
    } catch (e) {
      print('Error getting users who visited: $e');
      return [];
    }
  }
}
