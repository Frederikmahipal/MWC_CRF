import 'package:flutter/cupertino.dart';
import '../../../models/insights.dart';
import '../../../core/app_settings.dart';

class OverallStatsWidget extends StatelessWidget {
  final MonthlyInsights insight;

  const OverallStatsWidget({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppSettings.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CupertinoColors.systemGrey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Avg Rating',
            '${insight.averageRating.toStringAsFixed(1)} ⭐',
          ),
          _buildStatItem(
            context,
            '5⭐ Reviews',
            '${insight.ratingDistribution[5] ?? 0}',
          ),
          _buildStatItem(
            context,
            '4⭐ Reviews',
            '${insight.ratingDistribution[4] ?? 0}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            color: CupertinoColors.systemGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
