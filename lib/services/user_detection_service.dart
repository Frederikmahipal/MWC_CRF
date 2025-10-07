import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../repositories/remote/firestore_service.dart';

class UserDetectionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> isUserInFirestore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) return false;

      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if user exists in Firestore: $e');
      return false;
    }
  }

  static Future<User?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) return null;

      return await FirestoreService.getUser(userId);
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}
