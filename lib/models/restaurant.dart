import 'package:latlong2/latlong.dart';

class Restaurant {
  final String id;
  final String name;
  final List<String> cuisines;
  final LatLng location;
  final String? phone;
  final String? website;
  final String? openingHours;
  final String? address;
  final String? neighborhood;
  final RestaurantFeatures features;
  final double averageRating;
  final int totalReviews;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisines,
    required this.location,
    this.phone,
    this.website,
    this.openingHours,
    this.address,
    this.neighborhood,
    required this.features,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Restaurant',
      cuisines: _parseCuisines(json['cuisine']),
      location: LatLng(
        double.parse(json['lat'].toString()),
        double.parse(json['lon'].toString()),
      ),
      phone: json['phone'],
      website: json['website'],
      openingHours: json['opening_hours'],
      address: json['addr:street'],
      neighborhood: json['branch'],
      features: RestaurantFeatures.fromJson(json),
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  static List<String> _parseCuisines(dynamic cuisineData) {
    if (cuisineData == null) return [''];

    final cuisineString = cuisineData.toString();
    return cuisineString.split(';').map((c) => c.trim()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cuisines': cuisines,
      'lat': location.latitude,
      'lon': location.longitude,
      'phone': phone,
      'website': website,
      'opening_hours': openingHours,
      'address': address,
      'neighborhood': neighborhood,
      'features': features.toJson(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }

  Restaurant copyWith({
    String? id,
    String? name,
    List<String>? cuisines,
    LatLng? location,
    String? phone,
    String? website,
    String? openingHours,
    String? address,
    String? neighborhood,
    RestaurantFeatures? features,
    double? averageRating,
    int? totalReviews,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisines: cuisines ?? this.cuisines,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      features: features ?? this.features,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, cuisines: $cuisines, location: $location, averageRating: $averageRating, totalReviews: $totalReviews)';
  }
}

class RestaurantFeatures {
  final bool hasIndoorSeating;
  final bool hasOutdoorSeating;
  final bool isWheelchairAccessible;
  final bool hasTakeaway;
  final bool hasDelivery;
  final bool hasWifi;
  final bool hasDriveThrough;

  const RestaurantFeatures({
    this.hasIndoorSeating = false,
    this.hasOutdoorSeating = false,
    this.isWheelchairAccessible = false,
    this.hasTakeaway = false,
    this.hasDelivery = false,
    this.hasWifi = false,
    this.hasDriveThrough = false,
  });

  factory RestaurantFeatures.fromJson(Map<String, dynamic> json) {
    return RestaurantFeatures(
      hasIndoorSeating: _parseBoolean(json['indoor_seating']),
      hasOutdoorSeating: _parseBoolean(json['outdoor_seating']),
      isWheelchairAccessible: _parseBoolean(json['wheelchair']),
      hasTakeaway: _parseBoolean(json['takeaway']),
      hasDelivery: _parseBoolean(json['delivery']),
      hasWifi: _parseBoolean(json['wifi']),
      hasDriveThrough: _parseBoolean(json['drive_through']),
    );
  }

  static bool _parseBoolean(dynamic value) {
    if (value == null) return false;
    final stringValue = value.toString().toLowerCase();
    return stringValue == 'yes' || stringValue == 'true';
  }

  Map<String, dynamic> toJson() {
    return {
      'hasIndoorSeating': hasIndoorSeating,
      'hasOutdoorSeating': hasOutdoorSeating,
      'isWheelchairAccessible': isWheelchairAccessible,
      'hasTakeaway': hasTakeaway,
      'hasDelivery': hasDelivery,
      'hasWifi': hasWifi,
      'hasDriveThrough': hasDriveThrough,
    };
  }
}
