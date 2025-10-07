import 'package:flutter/cupertino.dart';

class InsightsEmptyStateWidget extends StatelessWidget {
  const InsightsEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chart_bar,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 24),
          Text(
            'No insights available',
            style: CupertinoTheme.of(
              context,
            ).textTheme.navTitleTextStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Reviews are needed to generate insights!',
            style: CupertinoTheme.of(
              context,
            ).textTheme.textStyle.copyWith(color: CupertinoColors.systemGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
