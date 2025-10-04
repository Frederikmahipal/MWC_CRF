import 'package:flutter/cupertino.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import 'review_input_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../core/app_settings.dart';

class ReviewsListPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const ReviewsListPage({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  State<ReviewsListPage> createState() => _ReviewsListPageState();
}

class _ReviewsListPageState extends State<ReviewsListPage> {
  List<Review> _reviews = [];
  bool _isLoading = true;
  Review? _userReview;

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
      final reviews = await ReviewService.getRestaurantReviews(
        widget.restaurantId,
      );
      final userReview = await ReviewService.getUserReviewForRestaurant(
        widget.restaurantId,
      );

      if (mounted) {
        setState(() {
          _reviews = reviews
              .where((review) => review.id != userReview?.id)
              .toList();
          _userReview = userReview;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to load reviews: $e');
      }
    }
  }

  void _showError(String message) {
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

  void _addReview() async {
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ReviewInputPage(
          restaurantId: widget.restaurantId,
          restaurantName: widget.restaurantName,
        ),
      ),
    );

    if (result == true) {
      _loadReviews();
    }
  }

  void _editReview() async {
    if (_userReview == null) return;

    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ReviewInputPage(
          restaurantId: widget.restaurantId,
          restaurantName: widget.restaurantName,
          existingRating: _userReview!.rating,
          existingComment: _userReview!.comment,
          reviewId: _userReview!.id,
        ),
      ),
    );

    if (result == true) {
      _loadReviews();
    }
  }

  void _deleteReview() async {
    if (_userReview == null) return;

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete your review?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ReviewService.deleteReview(_userReview!.id);
        _loadReviews();
      } catch (e) {
        _showError('Failed to delete review: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Reviews - ${widget.restaurantName}'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Write Review'),
          onPressed: _addReview,
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final review = _reviews[index];
                      final isUserReview =
                          _userReview != null && review.id == _userReview!.id;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isUserReview
                              ? AppSettings.primaryColor.withOpacity(0.1)
                              : AppSettings.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: isUserReview
                              ? Border.all(
                                  color: AppSettings.primaryColor.withOpacity(
                                    0.3,
                                  ),
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: AppSettings.getShadowColor(context),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  review.userAvatar,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.userName,
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        isUserReview
                                            ? 'Your Review'
                                            : timeago.format(review.createdAt),
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                              color: isUserReview
                                                  ? AppSettings.primaryColor
                                                  : CupertinoColors.systemGrey,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isUserReview)
                                  Row(
                                    children: [
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: const Text('Edit'),
                                        onPressed: _editReview,
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: const Text('Delete'),
                                        onPressed: _deleteReview,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(review.rating, (index) {
                                return const Text(
                                  '⭐',
                                  style: TextStyle(fontSize: 16),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(review.comment),
                          ],
                        ),
                      );
                    }, childCount: _reviews.length),
                  ),
                ],
              ),
      ),
    );
  }
}
