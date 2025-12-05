import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../repositories/remote/firestore_service.dart';
import 'pin_auth_service.dart';

class AuthService {
  static const String _keyCurrentUser = 'current_user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyLastAuthTime = 'last_auth_time';

  static User? _currentUser;
  static bool _isAuthenticated = false;

  static User? get currentUser => _currentUser;
  static bool get isAuthenticated => _isAuthenticated;

  static Future<void> initialize() async {
    await _loadStoredUser();
    await _checkSessionValidity();
  }

  static Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyCurrentUser);

      if (userId != null) {
        final userData = await FirestoreService.getUser(userId);
        if (userData != null) {
          _currentUser = userData;
          print('🔍 User loaded from storage: ${userData.fullName}');
        }
      }
    } catch (e) {
      print('Error loading stored user: $e');
      _clearUser();
    }
  }

  static Future<void> _checkSessionValidity() async {
    if (_currentUser != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final lastAuthTime = prefs.getInt(_keyLastAuthTime);
        print('🔍 Session check - Last auth time: $lastAuthTime');

        if (lastAuthTime != null) {
          final sessionDuration =
              DateTime.now().millisecondsSinceEpoch - lastAuthTime;
          const sessionTimeout = 0;
          print(
            '🔍 Session duration: ${sessionDuration}ms, timeout: ${sessionTimeout}ms',
          );

          if (sessionDuration > sessionTimeout) {
            print('🔍 Session expired, requiring re-authentication');
            await _expireSession();
          } else {
            print('🔍 Session valid, staying logged in');
            _isAuthenticated = true;
          }
        } else {
          print('🔍 No last auth time found, logging out');
          await logout();
        }
      } catch (e) {
        print('Error checking session validity: $e');
        await logout();
      }
    } else {
      print('🔍 No user found, not authenticated');
    }
  }

  static Future<bool> loginWithPin(String pin) async {
    try {
      if (_currentUser == null) {
        print('No current user found');
        return false;
      }

      final isValid = await PinAuthService.validatePin(pin);

      if (isValid) {
        await _updateSession();
        return true;
      }

      return false;
    } catch (e) {
      print('Error logging in with PIN: $e');
      return false;
    }
  }

  static Future<bool> loginWithBiometric() async {
    try {
      if (_currentUser == null) {
        print('No current user found');
        return false;
      }

      final isBiometricEnabled = await PinAuthService.isBiometricEnabled();
      if (!isBiometricEnabled) {
        print('Biometric not enabled for user');
        return false;
      }

      final isAuthenticated = await PinAuthService.authenticateWithBiometric();

      if (isAuthenticated) {
        await _updateSession();
        return true;
      }

      return false;
    } catch (e) {
      print('Error logging in with biometric: $e');
      return false;
    }
  }

  static Future<void> loadUserForLogin(User user) async {
    try {
      _currentUser = user;
      _isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentUser, user.id);
      await prefs.setBool(_keyIsAuthenticated, false);
    } catch (e) {
      print('Error loading user for login: $e');
    }
  }

  static Future<void> setCurrentUser(User user) async {
    try {
      _currentUser = user;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentUser, user.id);
      await prefs.setBool(_keyIsAuthenticated, true);
      await _updateSession();
    } catch (e) {
      print('Error setting current user: $e');
    }
  }

  static Future<void> _updateSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _keyLastAuthTime,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error updating session: $e');
    }
  }

  static Future<void> _expireSession() async {
    try {
      _isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsAuthenticated, false);
      await prefs.remove(_keyLastAuthTime);
    } catch (e) {
      print('Error expiring session: $e');
    }
  }

  static Future<void> logout() async {
    try {
      _currentUser = null;
      _isAuthenticated = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCurrentUser);
      await prefs.remove(_keyUserData);
      await prefs.remove(_keyIsAuthenticated);
      await prefs.remove(_keyLastAuthTime);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  static Future<void> _clearUser() async {
    _currentUser = null;
    _isAuthenticated = false;
  }

  static Future<bool> hasPinSetup() async {
    if (_currentUser == null) return false;
    return await PinAuthService.isPinSetup();
  }

  static Future<bool> hasBiometricEnabled() async {
    if (_currentUser == null) return false;
    return await PinAuthService.isBiometricEnabled();
  }

  static Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    try {
      final userData = await FirestoreService.getUser(_currentUser!.id);
      if (userData != null) {
        await setCurrentUser(userData);
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }
}
