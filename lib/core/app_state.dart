import 'package:flutter/cupertino.dart';

class AppState extends ChangeNotifier {
  String _username = 'Guest User';
  List<String> _preferredCuisines = [];
  bool _isFirstLaunch = true;
  
  // Getters
  String get username => _username;
  List<String> get preferredCuisines => _preferredCuisines;
  bool get isFirstLaunch => _isFirstLaunch;
  
  // Setters
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
}
