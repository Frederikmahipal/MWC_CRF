import 'package:flutter/cupertino.dart';

class AppState extends ChangeNotifier {
  String _username = '';
  List<String> _preferredCuisines = [];
  bool _isFirstLaunch = true;
  bool _isAuthenticated = false;
  bool _isPinSetup = false;
  bool _isBiometricEnabled = false;

  String get username => _username;
  List<String> get preferredCuisines => _preferredCuisines;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isAuthenticated => _isAuthenticated;
  bool get isPinSetup => _isPinSetup;
  bool get isBiometricEnabled => _isBiometricEnabled;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setPreferredCuisines(List<String> cuisines) {
    _preferredCuisines = cuisines;
    notifyListeners();
  }

  void setFirstLaunch(bool isFirstLaunch) {
    _isFirstLaunch = isFirstLaunch;
    notifyListeners();
  }

  void addPreferredCuisine(String cuisine) {
    if (!_preferredCuisines.contains(cuisine)) {
      _preferredCuisines.add(cuisine);
      notifyListeners();
    }
  }

  void removePreferredCuisine(String cuisine) {
    _preferredCuisines.remove(cuisine);
    notifyListeners();
  }

  void setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  void setPinSetup(bool pinSetup) {
    _isPinSetup = pinSetup;
    notifyListeners();
  }

  void setBiometricEnabled(bool biometricEnabled) {
    _isBiometricEnabled = biometricEnabled;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _username = '';
    _preferredCuisines = [];
    notifyListeners();
  }
}
