import 'package:flutter/cupertino.dart';
import '../services/review_service.dart';

class ReviewInputPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final int? existingRating;
  final String? existingComment;
  final String? reviewId;

  const ReviewInputPage({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
    this.existingRating,
    this.existingComment,
    this.reviewId,
  }) : super(key: key);

  @override
  State<ReviewInputPage> createState() => _ReviewInputPageState();
}

class _ReviewInputPageState extends State<ReviewInputPage> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRating != null) {
      _selectedRating = widget.existingRating!;
    }
    if (widget.existingComment != null) {
      _commentController.text = widget.existingComment!;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      _showError('Please write a comment');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.reviewId != null) {
        // Update existing review
        await ReviewService.updateReview(
          reviewId: widget.reviewId!,
          rating: _selectedRating,
          comment: _commentController.text.trim(),
        );
      } else {
        // Add new review
        await ReviewService.addReview(
          restaurantId: widget.restaurantId,
          restaurantName: widget.restaurantName,
          rating: _selectedRating,
          comment: _commentController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true); // return true for success
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Failed to submit review: $e');
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Review ${widget.restaurantName}'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Submit'),
          onPressed: _isLoading ? null : _submitReview,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                'Rating',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
              const SizedBox(height: 16),

              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        index < _selectedRating ? '⭐' : '☆',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Text(
                'Comment',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _commentController,
                placeholder: 'Write your review...',
                maxLines: 6,
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _isLoading ? null : _submitReview,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : Text(
                          widget.reviewId != null
                              ? 'Update Review'
                              : 'Submit Review',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
