import 'package:flutter/material.dart';

class AppStateProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en', 'US');
  bool _isFirstLaunch = true;
  bool _isLocationEnabled = false;
  bool _isNotificationsEnabled = true;
  String? _accessToken;
  String? _refreshToken;
  String? _userRole; // citizen | dispatcher | responder

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isNotificationsEnabled => _isNotificationsEnabled;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userRole => _userRole;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void setFirstLaunch(bool isFirstLaunch) {
    _isFirstLaunch = isFirstLaunch;
    notifyListeners();
  }

  void setLocationEnabled(bool enabled) {
    _isLocationEnabled = enabled;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _isNotificationsEnabled = enabled;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setAuth({String? accessToken, String? refreshToken, String? role}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userRole = role;
    notifyListeners();
  }

  void clearAuth() {
    _accessToken = null;
    _refreshToken = null;
    _userRole = null;
    notifyListeners();
  }
}
