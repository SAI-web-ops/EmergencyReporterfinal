import 'package:emergencyreporter/models/incident.dart';
import 'package:emergencyreporter/utils/api_client.dart';

class IncidentRepository {
  final ApiClient apiClient;
  IncidentRepository(this.apiClient);

  Future<Incident> createIncident(Incident incident) async {
    final res = await apiClient.post('/incidents', body: incident.toJson());
    final data = res['data'] as Map<String, dynamic>;
    return Incident.fromJson(data);
  }

  Future<List<Incident>> listIncidents() async {
    final res = await apiClient.get('/incidents');
    final list = (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map((e) => Incident.fromJson(e)).toList();
  }
}
