import 'package:flutter/cupertino.dart';
import '../../../core/app_settings.dart';

class InsightSkeletonWidget extends StatefulWidget {
  const InsightSkeletonWidget({super.key});

  @override
  State<InsightSkeletonWidget> createState() => _InsightSkeletonWidgetState();
}

class _InsightSkeletonWidgetState extends State<InsightSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppSettings.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppSettings.getBorderColor(context),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header skeleton
              Row(
                children: [
                  _buildSkeletonBox(20, 20, 8),
                  const SizedBox(width: 8),
                  _buildSkeletonBox(120, 16, 4),
                  const Spacer(),
                  _buildSkeletonBox(80, 16, 4),
                ],
              ),
              const SizedBox(height: 16),

              // Overall stats skeleton
              _buildOverallStatsSkeleton(),
              const SizedBox(height: 16),

              // Section skeletons
              _buildSectionSkeleton(
                'Highest Rated',
                CupertinoColors.systemPurple,
              ),
              const SizedBox(height: 12),
              _buildSectionSkeleton(
                'Most Reviewed',
                CupertinoColors.systemBlue,
              ),
              const SizedBox(height: 12),
              _buildSectionSkeleton(
                'Most Visited',
                CupertinoColors.systemOrange,
              ),
              const SizedBox(height: 12),
              _buildSectionSkeleton('Most Liked', CupertinoColors.systemRed),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallStatsSkeleton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppSettings.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatSkeleton(),
          _buildStatSkeleton(),
          _buildStatSkeleton(),
        ],
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Column(
      children: [
        _buildSkeletonBox(24, 24, 12),
        const SizedBox(height: 4),
        _buildSkeletonBox(40, 12, 4),
        const SizedBox(height: 2),
        _buildSkeletonBox(60, 10, 4),
      ],
    );
  }

  Widget _buildSectionSkeleton(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              _buildSkeletonBox(20, 20, 8),
              const SizedBox(width: 8),
              _buildSkeletonBox(100, 14, 4),
            ],
          ),
          const SizedBox(height: 8),

          // Section items
          ...List.generate(3, (index) => _buildListItemSkeleton()),
        ],
      ),
    );
  }

  Widget _buildListItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          _buildSkeletonBox(32, 20, 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonBox(120, 15, 4),
                const SizedBox(height: 2),
                _buildSkeletonBox(80, 12, 4),
              ],
            ),
          ),
          _buildSkeletonBox(16, 16, 8),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height, double borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppSettings.getSecondaryTextColor(
          context,
        ).withOpacity(_animation.value * 0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
