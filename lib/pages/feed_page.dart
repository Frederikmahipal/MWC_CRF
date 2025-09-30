import 'package:flutter/cupertino.dart';
import '../core/app_settings.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Restaurant Feed'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSettings.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Closest Restaurants',
                      style: CupertinoTheme.of(
                        context,
                      ).textTheme.navTitleTextStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on your preferences',
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSettings.defaultPadding,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppSettings.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(
                        AppSettings.defaultBorderRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CupertinoListTile(
                      title: Text('Restaurant ${index + 1}'),
                      subtitle: const Text('Cuisine type • Distance'),
                      trailing: const Icon(CupertinoIcons.chevron_right),
                      onTap: () {
                        // TODO implement restaurant details
                      },
                    ),
                  );
                },
                childCount: 10, 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
