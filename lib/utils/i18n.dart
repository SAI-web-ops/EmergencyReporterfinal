import 'package:flutter/widgets.dart';

class I18n {
  static const Map<String, Map<String, String>> _t = {
    'en': {
      'app_title': 'Emergency Reporter',
      'report_incident': 'Report Incident',
      'emergency_contacts': 'Emergency Contacts',
      'panic_button': 'Panic Button',
      'citizen_points': 'Citizen Points',
    },
    'hi': {
      'app_title': 'आपातकालीन रिपोर्टर',
      'report_incident': 'घटना रिपोर्ट करें',
      'emergency_contacts': 'आपातकालीन संपर्क',
      'panic_button': 'पैनिक बटन',
      'citizen_points': 'नागरिक अंक',
    },
    'es': {
      'app_title': 'Reportero de Emergencias',
      'report_incident': 'Reportar Incidente',
      'emergency_contacts': 'Contactos de Emergencia',
      'panic_button': 'Botón de Pánico',
      'citizen_points': 'Puntos Ciudadanos',
    },
  };

  static String t(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    return _t[code]?[key] ?? _t['en']![key] ?? key;
  }
}


