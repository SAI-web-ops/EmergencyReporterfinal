import 'package:url_launcher/url_launcher.dart';

class PhoneUtils {
  static Future<bool> callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
