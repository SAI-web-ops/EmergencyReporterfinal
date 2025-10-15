// lib/utils/config.dart
import 'dart:io' show Platform;

class AppConfig {
  static const String _androidApiBaseUrl = 'http://10.0.2.2:4000';
  static const String _iosApiBaseUrl = 'http://localhost:4000';

  static String get apiBaseUrl {
    if (Platform.isAndroid) {
      return _androidApiBaseUrl;
    }
    // For iOS simulator, web, and desktop, localhost should work.
    return _iosApiBaseUrl;
  }
}
