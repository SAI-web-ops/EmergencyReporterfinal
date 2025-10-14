import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/app_state_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/location_provider.dart';
import 'providers/points_provider.dart';
import 'utils/app_theme.dart';
import 'utils/config.dart';
import 'utils/api_client.dart';
import 'repositories/incident_repository.dart';
import 'repositories/points_repository.dart';
import 'repositories/upload_repository.dart';
import 'repositories/alerts_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/chat_repository.dart';
import 'repositories/notifications_repository.dart';

void main() {
  runApp(const EmergencyReporterApp());
}

class EmergencyReporterApp extends StatelessWidget {
  const EmergencyReporterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(baseUrl: AppConfig.apiBaseUrl);
    final incidentRepo = IncidentRepository(apiClient);
    final pointsRepo = PointsRepository(apiClient);
    final uploadRepo = UploadRepository(apiClient);
    final alertsRepo = AlertsRepository(apiClient);
    final authRepo = AuthRepository(apiClient);
    final chatRepo = ChatRepository(apiClient);
    final notifRepo = NotificationsRepository(apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),
        Provider<ApiClient>.value(value: apiClient),
        Provider<IncidentRepository>.value(value: incidentRepo),
        Provider<PointsRepository>.value(value: pointsRepo),
        Provider<UploadRepository>.value(value: uploadRepo),
        Provider<AlertsRepository>.value(value: alertsRepo),
        Provider<AuthRepository>.value(value: authRepo),
        Provider<ChatRepository>.value(value: chatRepo),
        Provider<NotificationsRepository>.value(value: notifRepo),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Emergency Reporter',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            home: const MainNavigationScreen(),
            locale: appState.locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('hi', 'IN'),
              Locale('es', 'ES'),
              Locale('fr', 'FR'),
              Locale('de', 'DE'),
            ],
          );
        },
      ),
    );
  }
}
