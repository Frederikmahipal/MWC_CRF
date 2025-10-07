import 'package:flutter/cupertino.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../core/app_settings.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'restaurants/restaurant_main_page.dart';
import '../services/restaurant_service.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  final RestaurantService _restaurantService = RestaurantService();

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reviews = await ReviewService.getUserReviews();
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user reviews: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load your reviews. Please try again.');
      }
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _isLoading = true;
              });
              try {
                await ReviewService.deleteReview(reviewId);
                _showSuccess('Review deleted successfully!');
                _loadReviews();
              } catch (e) {
                _showError('Failed to delete review: $e');
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('My Reviews'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _reviews.isEmpty
            ? _buildEmptyState()
            : _buildReviewsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.star,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 24),
          Text(
            'No reviews yet',
            style: CupertinoTheme.of(
              context,
            ).textTheme.navTitleTextStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Start reviewing restaurants to see them here!',
            style: CupertinoTheme.of(
              context,
            ).textTheme.textStyle.copyWith(color: CupertinoColors.systemGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final review = _reviews[index];
            return _buildReviewCard(review);
          }, childCount: _reviews.length),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.restaurantName,
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _deleteReview(review.id),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: CupertinoColors.systemRed,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Text(
                index < review.rating ? '⭐' : '☆',
                style: const TextStyle(fontSize: 16),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                timeago.format(review.createdAt),
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _navigateToRestaurant(review.restaurantId),
                child: const Text(
                  'View Restaurant',
                  style: TextStyle(
                    color: CupertinoColors.systemBlue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToRestaurant(String restaurantId) async {
    try {
      final restaurants = await _restaurantService.getAllRestaurants();
      final restaurant = restaurants.firstWhere(
        (r) => r.id == restaurantId,
        orElse: () => throw Exception('Restaurant not found'),
      );

      if (mounted) {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => RestaurantMainPage(restaurant: restaurant),
          ),
        );
      }
    } catch (e) {
      _showError('Could not find restaurant: $e');
    }
  }
}
