import 'dart:io';
import 'package:emergencyreporter/utils/api_client.dart';

class UploadRepository {
  final ApiClient apiClient;
  UploadRepository(this.apiClient);

  Future<String> uploadFile(File file) async {
    final res = await apiClient.uploadFile('/uploads', file);
    final data = res['data'] as Map<String, dynamic>;
    // Return absolute URL if baseUrl provided without trailing slash logic
    final path = data['url'] as String;
    final base = apiClient.baseUrl.endsWith('/') ? apiClient.baseUrl.substring(0, apiClient.baseUrl.length - 1) : apiClient.baseUrl;
    return '$base$path';
  }

  Future<List<Map<String, dynamic>>> listEvidence() async {
    final res = await apiClient.get('/uploads/list');
    final list = (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list;
  }
}
