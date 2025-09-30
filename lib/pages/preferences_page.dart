import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../core/app_settings.dart';
import '../core/theme_controller.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Preferences'),
        backgroundColor: AppSettings.getBackgroundColor(context),
      ),
      child: SafeArea(
        child: Container(
          color: AppSettings.getBackgroundColor(context),
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppSettings.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Consumer<ThemeController>(
                      builder: (context, themeController, child) {
                        return CupertinoListTile(
                          title: const Text('Theme'),
                          subtitle: Text(themeController.themeModeName),
                          trailing: const Icon(CupertinoIcons.chevron_right),
                          onTap: () {
                            _showThemeSelector(context, themeController);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(
    BuildContext context,
    ThemeController themeController,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Light'),
                if (themeController.themeMode == AppThemeMode.light)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 16),
                  ),
              ],
            ),
            onPressed: () {
              themeController.setThemeMode(AppThemeMode.light);
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Dark'),
                if (themeController.themeMode == AppThemeMode.dark)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 16),
                  ),
              ],
            ),
            onPressed: () {
              themeController.setThemeMode(AppThemeMode.dark);
              Navigator.of(context).pop();
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('System'),
                if (themeController.themeMode == AppThemeMode.system)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(CupertinoIcons.checkmark, size: 16),
                  ),
              ],
            ),
            onPressed: () {
              themeController.setThemeMode(AppThemeMode.system);
              Navigator.of(context).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
