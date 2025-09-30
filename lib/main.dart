import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'core/app_settings.dart';
import 'core/app_state.dart';
import 'navigation/main_navigation.dart';

void main() {
  runApp(const CopenhagenRestaurantFinder());
}

class CopenhagenRestaurantFinder extends StatelessWidget {
  const CopenhagenRestaurantFinder({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: CupertinoApp(
        title: AppSettings.appName,
        theme: CupertinoThemeData(
          primaryColor: AppSettings.primaryColor,
          brightness: Brightness.light,
        ),
        home: const MainNavigation(),
      ),
    );
  }
}
