import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import '../models/user.dart';
import '../models/review.dart';
import '../repositories/remote/firestore_service.dart';
import '../services/restaurant_service.dart';

class DatabaseSeeder {
  static final Random _random = Random();

  static final List<String> _avatars = [
    '👨',
    '👩',
    '👨‍💼',
    '👩‍💼',
    '👨‍🎓',
    '👩‍🎓',
    '👨‍🍳',
    '👩‍🍳',
    '🧑',
    '🧑‍💻',
    '🧑‍🎨',
    '🧑‍🚀',
    '👨‍🎨',
    '👩‍🎨',
    '👨‍🚀',
    '👩‍🚀',
  ];

  static Future<void> seedDatabase() async {
    print('Starting database seeding...');

    try {
      final users = await _seedUsers();
      print('Seeded ${users.length} users');

      await _seedReviews(users);
      print('Seeded reviews for all users');
    } catch (e) {
      print('Error seeding database: $e');
      rethrow;
    }
  }

  static Future<List<User>> _seedUsers() async {
    final List<User> users = [];

    for (int i = 0; i < 50; i++) {
      final firstName = faker.person.firstName();
      final lastName = faker.person.lastName();
      final phoneNumber = faker.phoneNumber.random.numberOfLength(8).toString();
      final avatar = _avatars[_random.nextInt(_avatars.length)];

      final user = User.create(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}_$i',
        firstName: firstName,
        lastName: lastName,
        avatarEmoji: avatar,
        phoneNumber: phoneNumber,
      );

      await FirestoreService.createOrUpdateUser(
        userId: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        avatarEmoji: user.avatarEmoji,
        phoneNumber: user.phoneNumber,
      );
      users.add(user);

      print('👤 Created user: $firstName $lastName ($phoneNumber)');
    }

    return users;
  }

  static Future<void> _seedReviews(List<User> users) async {
    final restaurants = await _getRestaurants();

    if (restaurants.isEmpty) {
      return;
    }

    for (int i = 0; i < restaurants.length; i++) {
      final restaurant = restaurants[i];

      for (int j = 0; j < 5; j++) {
        final user = users[_random.nextInt(users.length)];
        final rating = _generateRating();
        final comment = _generateReviewComment(rating);

        final review = Review(
          id: 'review_${DateTime.now().millisecondsSinceEpoch}_${restaurant.id}_$j',
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
          userId: user.id,
          userName: '${user.firstName} ${user.lastName}',
          userAvatar: user.avatarEmoji,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now().subtract(
            Duration(days: _random.nextInt(730)),
          ),
          updatedAt: DateTime.now().subtract(
            Duration(days: _random.nextInt(730)),
          ),
        );

        await FirebaseFirestore.instance
            .collection('reviews')
            .add(review.toMap());

        print(
          '⭐ Created review by ${user.firstName}: $rating stars for ${restaurant.name}',
        );
      }
    }

    for (final user in users) {
      final numAdditionalReviews = 3 + _random.nextInt(6);

      for (int i = 0; i < numAdditionalReviews; i++) {
        final restaurant = restaurants[_random.nextInt(restaurants.length)];
        final rating = _generateRating();
        final comment = _generateReviewComment(rating);

        final review = Review(
          id: 'review_${DateTime.now().millisecondsSinceEpoch}_${user.id}_$i',
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
          userId: user.id,
          userName: '${user.firstName} ${user.lastName}',
          userAvatar: user.avatarEmoji,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now().subtract(
            Duration(days: _random.nextInt(730)),
          ),
          updatedAt: DateTime.now().subtract(
            Duration(days: _random.nextInt(730)),
          ),
        );

        await FirebaseFirestore.instance
            .collection('reviews')
            .add(review.toMap());

        print(
          '⭐ Created additional review by ${user.firstName}: $rating stars for ${restaurant.name}',
        );
      }
    }
  }

  static Future<List<dynamic>> _getRestaurants() async {
    try {
      final restaurantService = RestaurantService();
      final restaurants = restaurantService.getCachedRestaurants();
      if (restaurants != null) {
        print('🍽️ Found ${restaurants.length} cached restaurants');
        return restaurants;
      } else {
        print('⚠️ No cached restaurants found, trying to load...');
        final loadedRestaurants = await restaurantService.getAllRestaurants();
        print('🍽️ Loaded ${loadedRestaurants.length} restaurants');
        return loadedRestaurants;
      }
    } catch (e) {
      print('⚠️ Could not load restaurants: $e');
      return [];
    }
  }

  static int _generateRating() {
    final weights = [0.1, 0.1, 0.2, 0.3, 0.3]; // 1,2,3,4,5 stars
    final random = _random.nextDouble();

    if (random < weights[0]) return 1;
    if (random < weights[0] + weights[1]) return 2;
    if (random < weights[0] + weights[1] + weights[2]) return 3;
    if (random < weights[0] + weights[1] + weights[2] + weights[3]) return 4;
    return 5;
  }

  static String _generateReviewComment(int rating) {
    final isDanish = _random.nextDouble() < 0.7;

    if (isDanish) {
      return _generateDanishReview(rating);
    } else {
      return _generateEnglishReview(rating);
    }
  }

  static String _generateDanishReview(int rating) {
    final positiveComments = [
      "Fantastisk mad og service!",
      "Rigtig god oplevelse, kan varmt anbefales.",
      "Perfekt til en særlig aften.",
      "Utrolig lækker mad og hyggelig stemning.",
      "Bedste restaurant i byen!",
      "Fantastisk smag og præsentation.",
      "Kan kun anbefales - fantastisk!",
      "Rigtig god kvalitet og service.",
      "Perfekt til en romantisk aften.",
      "Utrolig god oplevelse, kommer gerne igen.",
      "Fremragende mad og hyggelig atmosfære.",
      "Kan varmt anbefales - fantastisk kvalitet!",
      "Perfekt til en date eller særlig begivenhed.",
      "Utrolig lækker mad og professionel service.",
      "Bedste restaurant jeg har besøgt i lang tid!",
      "Fantastisk oplevelse, kommer helt sikkert igen.",
      "Rigtig god mad og hyggelig stemning.",
      "Perfekt til en romantisk aften for to.",
      "Utrolig god kvalitet og smag.",
      "Kan kun anbefales - fantastisk oplevelse!",
      "Fremragende service og lækker mad.",
      "Perfekt til en særlig aften med familien.",
      "Utrolig god oplevelse, kan varmt anbefales.",
      "Bedste restaurant i området!",
      "Fantastisk mad og hyggelig atmosfære.",
    ];

    final neutralComments = [
      "Okay oplevelse, intet særligt.",
      "Middelmådig mad og service.",
      "Ikke dårligt, men heller ikke fantastisk.",
      "Acceptabel kvalitet.",
      "Gennemsnitlig oplevelse.",
      "Ikke imponerende, men heller ikke dårligt.",
      "Middelmådig oplevelse.",
      "Acceptabelt, men intet særligt.",
      "Gennemsnitlig kvalitet og service.",
      "Ikke fantastisk, men heller ikke skuffende.",
    ];

    final negativeComments = [
      "Skuffende oplevelse, forventede mere.",
      "Ikke imponeret over kvaliteten.",
      "For dyrt for hvad man får.",
      "Service kunne være bedre.",
      "Mad var ikke som forventet.",
      "Ikke værd at besøge igen.",
      "Skuffende kvalitet og service.",
      "For dyrt for den kvalitet man får.",
      "Service var langsom og uvenlig.",
      "Mad var kold og smagløs.",
      "Ikke imponerende oplevelse.",
      "Forventede mere for prisen.",
      "Service kunne være meget bedre.",
      "Mad var ikke som beskrevet.",
      "Skuffende oplevelse overordnet.",
    ];

    if (rating >= 4) {
      return positiveComments[_random.nextInt(positiveComments.length)];
    } else if (rating == 3) {
      return neutralComments[_random.nextInt(neutralComments.length)];
    } else {
      return negativeComments[_random.nextInt(negativeComments.length)];
    }
  }

  static String _generateEnglishReview(int rating) {
    final positiveComments = [
      "Amazing food and service!",
      "Really great experience, highly recommended.",
      "Perfect for a special evening.",
      "Incredibly delicious food and cozy atmosphere.",
      "Best restaurant in town!",
      "Fantastic taste and presentation.",
      "Can only recommend - fantastic!",
      "Really good quality and service.",
      "Perfect for a romantic evening.",
      "Incredible experience, will definitely come back.",
      "Excellent food and wonderful atmosphere.",
      "Highly recommended - fantastic quality!",
      "Perfect for a date or special occasion.",
      "Incredibly delicious food and professional service.",
      "Best restaurant I've visited in a long time!",
      "Fantastic experience, will definitely return.",
      "Really good food and cozy atmosphere.",
      "Perfect for a romantic evening for two.",
      "Incredibly good quality and taste.",
      "Can only recommend - fantastic experience!",
      "Excellent service and delicious food.",
      "Perfect for a special evening with family.",
      "Incredibly good experience, highly recommended.",
      "Best restaurant in the area!",
      "Fantastic food and cozy atmosphere.",
    ];

    final neutralComments = [
      "Okay experience, nothing special.",
      "Average food and service.",
      "Not bad, but not fantastic either.",
      "Acceptable quality.",
      "Average experience.",
      "Not impressive, but not bad either.",
      "Average experience.",
      "Acceptable, but nothing special.",
      "Average quality and service.",
      "Not fantastic, but not disappointing either.",
    ];

    final negativeComments = [
      "Disappointing experience, expected more.",
      "Not impressed with the quality.",
      "Too expensive for what you get.",
      "Service could be better.",
      "Food wasn't as expected.",
      "Not worth visiting again.",
      "Disappointing quality and service.",
      "Too expensive for the quality you get.",
      "Service was slow and unfriendly.",
      "Food was cold and tasteless.",
      "Not impressive experience.",
      "Expected more for the price.",
      "Service could be much better.",
      "Food wasn't as described.",
      "Disappointing experience overall.",
    ];

    if (rating >= 4) {
      return positiveComments[_random.nextInt(positiveComments.length)];
    } else if (rating == 3) {
      return neutralComments[_random.nextInt(neutralComments.length)];
    } else {
      return negativeComments[_random.nextInt(negativeComments.length)];
    }
  }
}
