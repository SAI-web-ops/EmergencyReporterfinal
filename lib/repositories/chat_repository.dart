import 'package:emergencyreporter/utils/api_client.dart';

class ChatRepository {
  final ApiClient apiClient;
  ChatRepository(this.apiClient);

  Future<List<Map<String, dynamic>>> getMessages(String incidentId) async {
    final res = await apiClient.get('/chat/$incidentId');
    final list = (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list;
  }

  Future<Map<String, dynamic>> sendMessage({required String incidentId, required String text}) async {
    final res = await apiClient.post('/chat', body: { 'incidentId': incidentId, 'text': text });
    return res['data'] as Map<String, dynamic>;
  }
}


