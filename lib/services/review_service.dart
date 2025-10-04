import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _reviewsCollection = 'reviews';

  static Future<void> addReview({
    required String restaurantId,
    required String restaurantName,
    required int rating,
    required String comment,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');
      final userName = prefs.getString('user_name') ?? 'Anonymous';
      final userAvatar = prefs.getString('user_avatar') ?? '👤';

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final reviewData = {
        'userId': userId,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_reviewsCollection).add(reviewData);

      print('✅ Review added successfully');
    } catch (e) {
      print('❌ Error adding review: $e');
      rethrow;
    }
  }

  static Future<List<Review>> getRestaurantReviews(String restaurantId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      final reviews = querySnapshot.docs.map((doc) {
        return Review.fromMap(doc.id, doc.data());
      }).toList();

      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reviews;
    } catch (e) {
      print('❌ Error getting restaurant reviews: $e');
      return [];
    }
  }

  static Future<List<Review>> getUserReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final reviews = querySnapshot.docs.map((doc) {
        return Review.fromMap(doc.id, doc.data());
      }).toList();

      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reviews;
    } catch (e) {
      print('Error getting user reviews: $e');
      return [];
    }
  }

  static Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _firestore.collection(_reviewsCollection).doc(reviewId).update({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Review updated successfully');
    } catch (e) {
      print('Error updating review: $e');
      rethrow;
    }
  }

  static Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(_reviewsCollection).doc(reviewId).delete();
      print('Review deleted successfully');
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }

  static Future<Review?> getUserReviewForRestaurant(String restaurantId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) {
        return null;
      }

      final querySnapshot = await _firestore
          .collection(_reviewsCollection)
          .where('userId', isEqualTo: userId)
          .where('restaurantId', isEqualTo: restaurantId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return Review.fromMap(doc.id, doc.data());
      }

      return null;
    } catch (e) {
      print('Error checking user review: $e');
      return null;
    }
  }

  // Calculate average rating for a restaurant
  static Future<double> getRestaurantAverageRating(String restaurantId) async {
    try {
      final reviews = await getRestaurantReviews(restaurantId);

      if (reviews.isEmpty) {
        return 0.0;
      }

      final totalRating = reviews.fold(
        0.0,
        (sum, review) => sum + review.rating,
      );
      return totalRating / reviews.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }

  // Get restaurant rating summary
  static Future<Map<String, dynamic>> getRestaurantRatingSummary(
    String restaurantId,
  ) async {
    try {
      final reviews = await getRestaurantReviews(restaurantId);

      if (reviews.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': <int, int>{},
        };
      }

      final totalRating = reviews.fold(
        0.0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      // Calculate rating distribution
      final ratingDistribution = <int, int>{};
      for (final review in reviews) {
        ratingDistribution[review.rating] =
            (ratingDistribution[review.rating] ?? 0) + 1;
      }

      return {
        'averageRating': averageRating,
        'totalReviews': reviews.length,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      print('Error getting rating summary: $e');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': <int, int>{},
      };
    }
  }
}
