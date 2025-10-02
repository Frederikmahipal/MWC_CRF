import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/restaurant.dart';
import '../core/app_settings.dart';
import '../services/restaurant_service.dart';
import '../services/favorites_service.dart';
import '../services/review_service.dart';
import '../models/review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'reviews_list_page.dart';
import 'review_input_page.dart';

class RestaurantMainPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantMainPage({super.key, required this.restaurant});

  @override
  State<RestaurantMainPage> createState() => _RestaurantMainPageState();
}

class _RestaurantMainPageState extends State<RestaurantMainPage> {
  final RestaurantService _restaurantService = RestaurantService();
  String? _address;
  bool _isLoadingAddress = true;
  bool _isFavorited = false;
  bool _isLoadingFavorite = true;
  List<Review> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadAddress();
    _checkFavoriteStatus();
    _loadReviews();
  }

  Future<void> _loadAddress() async {
    try {
      final address = await _restaurantService.convertToAddress(
        widget.restaurant.location.latitude,
        widget.restaurant.location.longitude,
      );
      setState(() {
        _address = address;
        _isLoadingAddress = false;
      });
    } catch (e) {
      setState(() {
        _address = 'Address not available';
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final isFavorited = await FavoritesService.isFavorited(
        widget.restaurant.id,
      );
      if (mounted) {
        setState(() {
          _isFavorited = isFavorited;
          _isLoadingFavorite = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorited = false;
          _isLoadingFavorite = false;
        });
      }
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await ReviewService.getRestaurantReviews(
        widget.restaurant.id,
      );
      if (mounted) {
        setState(() {
          _reviews = reviews.take(2).toList(); // Only show latest 2 reviews
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviews = [];
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) return;

    if (!mounted) return;
    setState(() {
      _isLoadingFavorite = true;
    });

    try {
      if (_isFavorited) {
        final success = await FavoritesService.removeFromFavorites(
          widget.restaurant.id,
        );
        if (success && mounted) {
          setState(() {
            _isFavorited = false;
          });
        }
      } else {
        final success = await FavoritesService.addToFavorites(
          widget.restaurant.id,
        );
        if (success && mounted) {
          setState(() {
            _isFavorited = true;
          });
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Show error message to user
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to update favorite. Please try again.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.restaurant.name, overflow: TextOverflow.ellipsis),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildHeaderSection(),
            _buildInfoSection(),
            _buildFeaturesSection(),
            _buildContactSection(),
            _buildMapSection(),
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(AppSettings.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.restaurant.name,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navTitleTextStyle
                        .copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                _buildFavoriteButton(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.restaurant.cuisines.join(' • '),
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 16,
                color: CupertinoColors.systemBlue,
              ),
            ),
            if (widget.restaurant.neighborhood != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.restaurant.neighborhood!,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isLoadingFavorite ? null : _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isFavorited
              ? CupertinoColors.systemRed.withOpacity(0.1)
              : CupertinoColors.systemGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isFavorited
                ? CupertinoColors.systemRed.withOpacity(0.3)
                : CupertinoColors.systemGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: _isLoadingFavorite
            ? const CupertinoActivityIndicator(radius: 8)
            : Icon(
                _isFavorited ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                color: _isFavorited
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey,
                size: 20,
              ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSettings.defaultPadding,
        ),
        padding: const EdgeInsets.all(AppSettings.defaultPadding),
        decoration: BoxDecoration(
          color: AppSettings.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurant Information',
              style: CupertinoTheme.of(
                context,
              ).textTheme.navTitleTextStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (widget.restaurant.openingHours != null) ...[
              _buildInfoRow(
                CupertinoIcons.clock,
                'Opening Hours',
                widget.restaurant.openingHours!,
              ),
              const SizedBox(height: 8),
            ],
            _buildInfoRow(
              CupertinoIcons.location,
              'Address',
              _isLoadingAddress
                  ? 'Loading address...'
                  : _address ?? 'Address not available',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: CupertinoColors.systemGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: CupertinoTheme.of(
                  context,
                ).textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                value,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    final features = <Widget>[];

    if (widget.restaurant.features.hasOutdoorSeating) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.leaf_arrow_circlepath,
          'Outdoor Seating',
          CupertinoColors.systemGreen,
        ),
      );
    }

    if (widget.restaurant.features.isWheelchairAccessible) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.checkmark_circle,
          'Wheelchair Accessible',
          CupertinoColors.systemBlue,
        ),
      );
    }

    if (widget.restaurant.features.hasTakeaway) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.bag,
          'Takeaway',
          CupertinoColors.systemOrange,
        ),
      );
    }

    if (widget.restaurant.features.hasDelivery) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.car,
          'Delivery',
          CupertinoColors.systemPurple,
        ),
      );
    }

    if (widget.restaurant.features.hasWifi) {
      features.add(
        _buildFeatureChip(
          CupertinoIcons.wifi,
          'WiFi',
          CupertinoColors.systemIndigo,
        ),
      );
    }

    if (features.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSettings.defaultPadding),
        padding: const EdgeInsets.all(AppSettings.defaultPadding),
        decoration: BoxDecoration(
          color: AppSettings.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features',
              style: CupertinoTheme.of(
                context,
              ).textTheme.navTitleTextStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: features),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSettings.defaultPadding,
        ),
        padding: const EdgeInsets.all(AppSettings.defaultPadding),
        decoration: BoxDecoration(
          color: AppSettings.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: CupertinoTheme.of(
                context,
              ).textTheme.navTitleTextStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (widget.restaurant.phone != null) ...[
              _buildContactButton(
                CupertinoIcons.phone,
                'Call',
                widget.restaurant.phone!,
                () => _makePhoneCall(widget.restaurant.phone!),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.restaurant.website != null) ...[
              _buildContactButton(
                CupertinoIcons.globe,
                'Visit Website',
                widget.restaurant.website!,
                () => _openWebsite(widget.restaurant.website!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: CupertinoColors.systemBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: CupertinoTheme.of(
                    context,
                  ).textTheme.textStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  value,
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSettings.defaultPadding),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: widget.restaurant.location,
                  initialZoom: 16.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: isDark
                        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.crf',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: widget.restaurant.location,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemRed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CupertinoColors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.location_solid,
                            color: CupertinoColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              //invisible layer that covers map
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _openInMapsApp(),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSettings.defaultPadding),
        padding: const EdgeInsets.all(AppSettings.defaultPadding),
        decoration: BoxDecoration(
          color: AppSettings.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(AppSettings.defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Reviews',
                  style: CupertinoTheme.of(
                    context,
                  ).textTheme.navTitleTextStyle.copyWith(fontSize: 18),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text('View All'),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => ReviewsListPage(
                          restaurantId: widget.restaurant.id,
                          restaurantName: widget.restaurant.name,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Show latest reviews or "no reviews" message
            if (_isLoadingReviews)
              const Center(child: CupertinoActivityIndicator())
            else if (_reviews.isEmpty)
              const Text(
                'No reviews yet. Be the first to review this restaurant!',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Column(
                children: _reviews
                    .map((review) => _buildReviewCard(review))
                    .toList(),
              ),

            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => ReviewInputPage(
                      restaurantId: widget.restaurant.id,
                      restaurantName: widget.restaurant.name,
                    ),
                  ),
                );
              },
              child: const Text('Write Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.userAvatar, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      timeago.format(review.createdAt),
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            color: CupertinoColors.systemGrey,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Text(
                index < review.rating ? '⭐' : '☆',
                style: const TextStyle(fontSize: 14),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // TODO: Implement phone call functionality
    print('Calling: $phoneNumber');
  }

  void _openWebsite(String website) async {
    try {
      final Uri url = Uri.parse(website);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: const Text('Could not open website'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening website: $e');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Invalid URL: $website'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _openInMapsApp() async {
    try {
      final lat = widget.restaurant.location.latitude;
      final long = widget.restaurant.location.longitude;
      final restaurantName = widget.restaurant.name;

      final appleMapsUrl =
          'https://maps.apple.com/?q=$restaurantName&ll=$lat,$long';
      final appleMapsUri = Uri.parse(appleMapsUrl);

      if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        final googleMapsUrl =
            'https://maps.google.com/?q=$restaurantName&ll=$lat,$long';
        final googleMapsUri = Uri.parse(googleMapsUrl);

        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Error'),
                content: Text('Could not open maps app'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error opening maps app: $e');
    }
  }
}
