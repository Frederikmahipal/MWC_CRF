import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';
import '../../models/user.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _reviewsCollection = 'reviews';
  static const String _favoritesCollection = 'favorites';
  static const String _notificationsCollection = 'notifications';

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }

  static FirebaseFirestore get firestore => _firestore;

  static Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Connection test successful',
      });
      return true;
    } catch (e) {
      print('Firestore connection failed: $e');
      return false;
    }
  }

  static Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return User.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  static Future<void> createOrUpdateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String avatarEmoji,
    required String phoneNumber,
  }) async {
    try {
      final user = User.create(
        id: userId,
        firstName: firstName,
        lastName: lastName,
        avatarEmoji: avatarEmoji,
        phoneNumber: phoneNumber,
      );

      await _firestore.collection(_usersCollection).doc(userId).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating/updating user: $e');
      rethrow;
    }
  }

  static Future<String> addReview({
    required String userId,
    required String restaurantId,
    required int rating,
    required String comment,
    String? photoUrl,
    String? detectedDish,
  }) async {
    final reviewRef = await _firestore.collection(_reviewsCollection).add({
      'userId': userId,
      'restaurantId': restaurantId,
      'rating': rating,
      'comment': comment,
      'photoUrl': photoUrl,
      'detectedDish': detectedDish,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return reviewRef.id;
  }

  static Stream<QuerySnapshot> getRestaurantReviews(String restaurantId) {
    return _firestore
        .collection(_reviewsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> addToFavorites(String userId, String restaurantId) async {
    await _firestore.collection(_favoritesCollection).doc(userId).set({
      restaurantId: true,
    }, SetOptions(merge: true));
  }

  static Future<void> removeFromFavorites(
    String userId,
    String restaurantId,
  ) async {
    await _firestore.collection(_favoritesCollection).doc(userId).update({
      restaurantId: FieldValue.delete(),
    });
  }

  static Future<DocumentSnapshot> getUserFavorites(String userId) async {
    return await _firestore.collection(_favoritesCollection).doc(userId).get();
  }

  static Future<bool> isRestaurantFavorited(
    String userId,
    String restaurantId,
  ) async {
    final doc = await _firestore
        .collection(_favoritesCollection)
        .doc(userId)
        .get();
    if (!doc.exists) return false;

    final data = doc.data();
    return data?[restaurantId] == true;
  }

  static Future<List<String>> getUsersWhoFavorited(String restaurantId) async {
    final querySnapshot = await _firestore
        .collection(_favoritesCollection)
        .where(restaurantId, isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  static Future<void> addNotification({
    required String userId,
    required String type,
    required String restaurantId,
    required String message,
  }) async {
    await _firestore
        .collection(_notificationsCollection)
        .doc(userId)
        .collection('user_notifications')
        .add({
          'type': type,
          'restaurantId': restaurantId,
          'message': message,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .doc(userId)
        .collection('user_notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    await _firestore
        .collection(_notificationsCollection)
        .doc(userId)
        .collection('user_notifications')
        .doc(notificationId)
        .update({'read': true});
  }
}
