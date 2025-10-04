import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../repositories/remote/firestore_service.dart';

class PinAuthService {
  static const String _keyPinHash = 'user_pin_hash';
  static const String _keyPinSalt = 'user_pin_salt';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keySessionToken = 'session_token';
  static const String _keyLastAuthTime = 'last_auth_time';
  static const String _keyAuthAttempts = 'auth_attempts';

  static const int _maxAttempts = 5;
  static const int _sessionTimeoutMinutes = 30;

  static final LocalAuthentication _localAuth = LocalAuthentication();

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  static String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> setupPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salt = _generateSalt();
      final hashedPin = _hashPin(pin, salt);

      await prefs.setString(_keyPinHash, hashedPin);
      await prefs.setString(_keyPinSalt, salt);
      await prefs.setInt(_keyAuthAttempts, 0);

      final currentUser = await _getCurrentUserId();
      if (currentUser != null) {
        await FirestoreService.updateUserAuth(
          userId: currentUser,
          pinHash: hashedPin,
          salt: salt,
        );
      }

      return true;
    } catch (e) {
      print('Error setting up PIN: $e');
      return false;
    }
  }

  static Future<bool> validatePin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_keyPinHash);
      final storedSalt = prefs.getString(_keyPinSalt);
      final attempts = prefs.getInt(_keyAuthAttempts) ?? 0;

      if (storedHash == null || storedSalt == null) {
        return false;
      }

      if (attempts >= _maxAttempts) {
        print('Too many PIN attempts');
        return false;
      }

      final hashedPin = _hashPin(pin, storedSalt);
      final isValid = hashedPin == storedHash;

      if (isValid) {
        await _resetAttempts();
        await _updateSession();
        return true;
      } else {
        await _incrementAttempts();
        return false;
      }
    } catch (e) {
      print('Error validating PIN: $e');
      return false;
    }
  }

  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  static Future<bool> enableBiometric() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricEnabled, true);

      final currentUser = await _getCurrentUserId();
      if (currentUser != null) {
        await FirestoreService.updateUserBiometric(
          userId: currentUser,
          biometricEnabled: true,
        );
      }

      return true;
    } catch (e) {
      print('Error enabling biometric: $e');
      return false;
    }
  }

  static Future<bool> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricEnabled, false);

      final currentUser = await _getCurrentUserId();
      if (currentUser != null) {
        await FirestoreService.updateUserBiometric(
          userId: currentUser,
          biometricEnabled: false,
        );
      }

      return true;
    } catch (e) {
      print('Error disabling biometric: $e');
      return false;
    }
  }

  static Future<bool> authenticateWithBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final biometricEnabled = prefs.getBool(_keyBiometricEnabled) ?? false;

      if (!biometricEnabled) return false;

      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (result) {
        await _updateSession();
      }

      return result;
    } catch (e) {
      print('Error with biometric authentication: $e');
      return false;
    }
  }

  static Future<bool> authenticateWithBiometricForSetup() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable Face ID',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return result;
    } catch (e) {
      print('Error authenticating with biometric for setup: $e');
      return false;
    }
  }

  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAuthTime = prefs.getInt(_keyLastAuthTime);

      if (lastAuthTime == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      final timeDiff = now - lastAuthTime;
      final sessionTimeoutMs = _sessionTimeoutMinutes * 60 * 1000;

      return timeDiff < sessionTimeoutMs;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySessionToken);
      await prefs.remove(_keyLastAuthTime);
      await prefs.setInt(_keyAuthAttempts, 0);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  static Future<void> _resetAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAuthAttempts, 0);
  }

  static Future<void> _incrementAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_keyAuthAttempts) ?? 0;
    await prefs.setInt(_keyAuthAttempts, attempts + 1);
  }

  static Future<void> _updateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_keyLastAuthTime, now);
    await prefs.setString(_keySessionToken, _generateSessionToken());
  }

  static String _generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  static Future<String?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('current_user_id');
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyBiometricEnabled) ?? false;
    } catch (e) {
      print('Error checking biometric status: $e');
      return false;
    }
  }

  static Future<bool> isPinSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinHash = prefs.getString(_keyPinHash);
      return pinHash != null;
    } catch (e) {
      print('Error checking PIN setup: $e');
      return false;
    }
  }

  static Future<int> getRemainingAttempts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = prefs.getInt(_keyAuthAttempts) ?? 0;
      return _maxAttempts - attempts;
    } catch (e) {
      print('Error getting remaining attempts: $e');
      return 0;
    }
  }

  static Future<bool> loadPinFromFirestore(String userId) async {
    try {
      final authData = await FirestoreService.getUserAuth(userId);
      if (authData == null || authData['pinHash'] == null) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPinHash, authData['pinHash']);
      await prefs.setString(_keyPinSalt, authData['pinSalt']);
      await prefs.setBool(
        _keyBiometricEnabled,
        authData['biometricEnabled'] ?? false,
      );

      return true;
    } catch (e) {
      print('Error loading PIN from Firestore: $e');
      return false;
    }
  }

  static Future<void> clearAllAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPinHash);
      await prefs.remove(_keyPinSalt);
      await prefs.remove(_keyBiometricEnabled);
      await prefs.remove(_keyLastAuthTime);
      await prefs.remove(_keyAuthAttempts);
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  static Future<bool> resetPin(String newPin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salt = _generateSalt();
      final hashedPin = _hashPin(newPin, salt);

      await prefs.setString(_keyPinHash, hashedPin);
      await prefs.setString(_keyPinSalt, salt);
      await prefs.setInt(_keyAuthAttempts, 0);

      final currentUser = await _getCurrentUserId();
      if (currentUser != null) {
        await FirestoreService.updateUserAuth(
          userId: currentUser,
          pinHash: hashedPin,
          salt: salt,
        );
      }

      return true;
    } catch (e) {
      print('Error resetting PIN: $e');
      return false;
    }
  }
}
