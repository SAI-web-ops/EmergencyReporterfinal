import 'package:flutter/material.dart';

enum IncidentType {
  accident,
  crime,
  fire,
  medical,
  violence,
  suspicious,
  other,
}

enum IncidentStatus {
  reported,
  acknowledged,
  inProgress,
  resolved,
  cancelled,
}

enum IncidentPriority {
  low,
  medium,
  high,
  critical,
}

class Incident {
  final String id;
  final IncidentType type;
  final IncidentStatus status;
  final IncidentPriority priority;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final List<String> mediaUrls;
  final bool isAnonymous;
  final String? reporterId;
  final String? assignedUnit;
  final String? notes;
  final int pointsAwarded;

  Incident({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    this.mediaUrls = const [],
    this.isAnonymous = false,
    this.reporterId,
    this.assignedUnit,
    this.notes,
    this.pointsAwarded = 0,
  });

  Incident copyWith({
    String? id,
    IncidentType? type,
    IncidentStatus? status,
    IncidentPriority? priority,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? timestamp,
    List<String>? mediaUrls,
    bool? isAnonymous,
    String? reporterId,
    String? assignedUnit,
    String? notes,
    int? pointsAwarded,
  }) {
    return Incident(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      reporterId: reporterId ?? this.reporterId,
      assignedUnit: assignedUnit ?? this.assignedUnit,
      notes: notes ?? this.notes,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
      'mediaUrls': mediaUrls,
      'isAnonymous': isAnonymous,
      'reporterId': reporterId,
      'assignedUnit': assignedUnit,
      'notes': notes,
      'pointsAwarded': pointsAwarded,
    };
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      type: IncidentType.values.firstWhere((e) => e.name == json['type']),
      status: IncidentStatus.values.firstWhere((e) => e.name == json['status']),
      priority: IncidentPriority.values.firstWhere((e) => e.name == json['priority']),
      title: json['title'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      timestamp: DateTime.parse(json['timestamp']),
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      isAnonymous: json['isAnonymous'] ?? false,
      reporterId: json['reporterId'],
      assignedUnit: json['assignedUnit'],
      notes: json['notes'],
      pointsAwarded: json['pointsAwarded'] ?? 0,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case IncidentType.accident:
        return 'Traffic Accident';
      case IncidentType.crime:
        return 'Criminal Activity';
      case IncidentType.fire:
        return 'Fire Emergency';
      case IncidentType.medical:
        return 'Medical Emergency';
      case IncidentType.violence:
        return 'Violence/Assault';
      case IncidentType.suspicious:
        return 'Suspicious Activity';
      case IncidentType.other:
        return 'Other Emergency';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case IncidentPriority.low:
        return Colors.green;
      case IncidentPriority.medium:
        return Colors.orange;
      case IncidentPriority.high:
        return Colors.red;
      case IncidentPriority.critical:
        return Colors.purple;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case IncidentStatus.reported:
        return 'Reported';
      case IncidentStatus.acknowledged:
        return 'Acknowledged';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
