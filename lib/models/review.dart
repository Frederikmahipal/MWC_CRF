import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String userName;
  final String userAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Review.fromMap(String id, Map<String, dynamic> map) {
    // Helper function to convert Firestore Timestamp to DateTime
    DateTime _parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is DateTime) return timestamp;
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return DateTime.now();
    }

    return Review(
      id: id,
      userId: map['userId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '👤',
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }
}
