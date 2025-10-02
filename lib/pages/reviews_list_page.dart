import 'package:flutter/cupertino.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import 'review_input_page.dart';
import 'package:timeago/timeago.dart' as timeago;

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
          // Filter out users own review from the main list
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
                  // User's review section
                  if (_userReview != null)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CupertinoColors.systemBlue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _userReview!.userAvatar,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userReview!.userName,
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'Your Review',
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                              color: CupertinoColors.systemBlue,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
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
                              children: List.generate(5, (index) {
                                return Text(
                                  index < _userReview!.rating ? '⭐' : '☆',
                                  style: const TextStyle(fontSize: 16),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(_userReview!.comment),
                          ],
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final review = _reviews[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
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
                                        timeago.format(review.createdAt),
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
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
                            const SizedBox(height: 12),
                            Row(
                              children: List.generate(5, (index) {
                                return Text(
                                  index < review.rating ? '⭐' : '☆',
                                  style: const TextStyle(fontSize: 16),
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
