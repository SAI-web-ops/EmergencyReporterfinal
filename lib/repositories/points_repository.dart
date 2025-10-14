import 'package:emergencyreporter/utils/api_client.dart';

class PointsRepository {
  final ApiClient apiClient;
  PointsRepository(this.apiClient);

  Future<Map<String, dynamic>> fetchPoints() async {
    final res = await apiClient.get('/points');
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addPoints(int points, String description, {String type = 'earned'}) async {
    final res = await apiClient.post('/points/add', body: {
      'points': points,
      'description': description,
      'type': type,
    });
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> redeemPoints(int points, String description) async {
    final res = await apiClient.post('/points/redeem', body: {
      'points': points,
      'description': description,
    });
    return res['data'] as Map<String, dynamic>;
  }
}
