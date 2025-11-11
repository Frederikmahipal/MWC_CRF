import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app_settings.dart';
import 'core/app_state.dart';
import 'core/theme_controller.dart';
import 'navigation/main_navigation.dart';
import 'pages/onboarding/welcome_page.dart';
import 'pages/onboarding/pin_setup_page.dart';
import 'pages/onboarding/pin_login_page.dart';
import 'services/pin_auth_service.dart';
import 'services/auth_service.dart';
import 'utils/clear_database.dart';
import 'utils/seed_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  await AuthService.initialize();

 // await clearDatabase();

 //  await seedDatabase();

  runApp(const CopenhagenRestaurantFinder());
}

class CopenhagenRestaurantFinder extends StatelessWidget {
  const CopenhagenRestaurantFinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return CupertinoApp(
            debugShowCheckedModeBanner: false,
            title: AppSettings.appName,
            theme: CupertinoThemeData(
              primaryColor: AppSettings.primaryColor,
              brightness: themeController.brightness,
              scaffoldBackgroundColor:
                  themeController.brightness == Brightness.dark
                  ? const Color(0xFF0F1419)
                  : const Color(0xFFF7F3F0),
              barBackgroundColor: themeController.brightness == Brightness.dark
                  ? const Color(0xFF1A2332)
                  : const Color(0xFFFEFCFB),
            ),
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthStatus>(
      future: _checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        final authStatus = snapshot.data ?? AuthStatus.notAuthenticated;

        switch (authStatus) {
          case AuthStatus.authenticated:
            return const MainNavigation();
          case AuthStatus.needsPinLogin:
            return const PinLoginPage(isAppReopen: true);
          case AuthStatus.notAuthenticated:
          default:
            return const WelcomePage();
        }
      },
    );
  }

  Future<AuthStatus> _checkAuthStatus() async {
    try {
      if (AuthService.isAuthenticated && AuthService.currentUser != null) {
        return AuthStatus.authenticated;
      }

      if (AuthService.currentUser != null && !AuthService.isAuthenticated) {
        return AuthStatus.needsPinLogin;
      }

      return AuthStatus.notAuthenticated;
    } catch (e) {
      print('Error checking auth status: $e');
      return AuthStatus.notAuthenticated;
    }
  }
}

enum AuthStatus {
  notAuthenticated,
  needsPinSetup,
  needsPinLogin,
  authenticated,
}
