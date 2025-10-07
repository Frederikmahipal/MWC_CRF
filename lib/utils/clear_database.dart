import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> clearDatabase() async {
  print('🧹 Starting database clearing...');

  try {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    for (var doc in usersSnapshot.docs) {
      await doc.reference.delete();
    }
    print('✅ Cleared ${usersSnapshot.docs.length} users');

    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .get();
    for (var doc in reviewsSnapshot.docs) {
      await doc.reference.delete();
    }
    print('✅ Cleared ${reviewsSnapshot.docs.length} reviews');

    print('🎉 Database cleared successfully!');
  } catch (e) {
    print('Error clearing database: $e');
    rethrow;
  }
}


