import 'package:flutter/material.dart';
import '../models/incident.dart';

class IncidentProvider extends ChangeNotifier {
  final List<Incident> _incidents = [];
  Incident? _currentIncident;
  bool _isRecording = false;
  bool _isUploading = false;

  List<Incident> get incidents => _incidents;
  Incident? get currentIncident => _currentIncident;
  bool get isRecording => _isRecording;
  bool get isUploading => _isUploading;

  void addIncident(Incident incident) {
    _incidents.insert(0, incident);
    notifyListeners();
  }

  void setCurrentIncident(Incident? incident) {
    _currentIncident = incident;
    notifyListeners();
  }

  void setRecording(bool recording) {
    _isRecording = recording;
    notifyListeners();
  }

  void setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void updateIncidentStatus(String incidentId, IncidentStatus status) {
    final index = _incidents.indexWhere(
      (incident) => incident.id == incidentId,
    );
    if (index != -1) {
      _incidents[index] = _incidents[index].copyWith(status: status);
      notifyListeners();
    }
  }

  void clearIncidents() {
    _incidents.clear();
    notifyListeners();
  }
}
