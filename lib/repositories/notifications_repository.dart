import 'package:emergencyreporter/utils/api_client.dart';

class NotificationsRepository {
  final ApiClient apiClient;
  NotificationsRepository(this.apiClient);

  Future<void> registerDevice({required String token, String platform = 'android'}) async {
    await apiClient.post('/notifications/register', body: {
      'token': token,
      'platform': platform,
    });
  }
}


