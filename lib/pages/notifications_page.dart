import 'package:flutter/cupertino.dart';
import '../core/app_settings.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notifications'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.bell,
                size: 64,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 24),
              Text(
                'No notifications yet',
                style: CupertinoTheme.of(
                  context,
                ).textTheme.navTitleTextStyle.copyWith(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
