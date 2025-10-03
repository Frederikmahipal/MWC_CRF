import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String avatarEmoji;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatarEmoji,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter for full name
  String get fullName => '$firstName $lastName';

  // Factory constructor to create a User from a Firestore document
  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      avatarEmoji: data['avatarEmoji'] ?? '👤',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  // Method to convert a User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'avatarEmoji': avatarEmoji,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Factory constructor for creating a new user (with server timestamps)
  factory User.create({
    required String id,
    required String firstName,
    required String lastName,
    required String avatarEmoji,
    required String phoneNumber,
  }) {
    final now = DateTime.now();
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      avatarEmoji: avatarEmoji,
      phoneNumber: phoneNumber,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Method to create a copy with updated fields
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? avatarEmoji,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, phone: $phoneNumber, avatar: $avatarEmoji)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
