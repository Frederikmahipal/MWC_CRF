import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> clearDatabase() async {
  print('🧹 Starting database clearing...');

  try {
    // Clear users
    await _clearCollection('users');

    // Clear reviews
    await _clearCollection('reviews');

    // Clear user visits
    await _clearCollection('user_visits');

    // Clear favorites
    await _clearCollection('favorites');

    print('🎉 Database cleared successfully!');
  } catch (e) {
    print('Error clearing database: $e');
    rethrow;
  }
}

Future<void> _clearCollection(String collectionName) async {
  print('🧹 Clearing $collectionName...');

  // Get all documents in batches
  const int batchSize = 100;
  bool hasMore = true;
  int totalDeleted = 0;

  while (hasMore) {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .limit(batchSize)
        .get();

    if (snapshot.docs.isEmpty) {
      hasMore = false;
      break;
    }

    // Delete in batches
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    totalDeleted += snapshot.docs.length;
    print(
      '✅ Deleted ${snapshot.docs.length} $collectionName documents (total: $totalDeleted)',
    );

    // If we got less than batchSize, we're done
    if (snapshot.docs.length < batchSize) {
      hasMore = false;
    }
  }

  print('✅ Cleared $totalDeleted $collectionName documents');
}
