import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';
import '../repositories/points_repository.dart';
import '../providers/incident_provider.dart';
import '../providers/points_provider.dart';

class OfflineQueueService {
  static const String _pendingKey = 'pending_incidents_v1';

  static Future<List<Incident>> loadPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_pendingKey) ?? <String>[];
    return raw.map((s) => Incident.fromJson(json.decode(s) as Map<String, dynamic>)).toList();
  }

  static Future<void> addPending(Incident incident) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingKey) ?? <String>[];
    list.insert(0, json.encode(incident.toJson()));
    await prefs.setStringList(_pendingKey, list);
  }

  static Future<void> removePending(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_pendingKey) ?? <String>[];
    list.removeWhere((s) {
      try {
        final m = json.decode(s) as Map<String, dynamic>;
        return m['id'] == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_pendingKey, list);
  }

  static Future<int> countPending() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_pendingKey) ?? <String>[]).length;
  }

  static Future<int> submitAll(context) async {
    final incidentRepo = context.read<IncidentRepository>();
    final pointsRepo = context.read<PointsRepository>();
    final incidentProvider = context.read<IncidentProvider>();
    final pointsProvider = context.read<PointsProvider>();

    final pending = await loadPending();
    int success = 0;
    for (final inc in List<Incident>.from(pending)) {
      try {
        final created = await incidentRepo.createIncident(inc);
        incidentProvider.addIncident(created);
        await pointsRepo.addPoints(
          created.pointsAwarded,
          'Reported ${created.typeDisplayName}',
        );
        pointsProvider.addPoints(
          created.pointsAwarded,
          'Reported ${created.typeDisplayName}',
        );
        await removePending(inc.id);
        success++;
      } catch (_) {
        // keep for next retry
      }
    }
    return success;
  }
}


