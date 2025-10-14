import 'package:emergencyreporter/utils/api_client.dart';

class AlertsRepository {
  final ApiClient apiClient;
  AlertsRepository(this.apiClient);

  Future<Map<String, dynamic>> triggerPanic({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final res = await apiClient.post('/alerts/panic', body: {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
      'triggeredAt': DateTime.now().toIso8601String(),
    });
    return res['data'] as Map<String, dynamic>;
  }
}


