import 'package:flutter/material.dart';
import '../models/incident.dart';

class IncidentTypeSelector extends StatelessWidget {
  final IncidentType selectedType;
  final ValueChanged<IncidentType> onTypeChanged;

  const IncidentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: IncidentType.values.map((type) {
        final isSelected = selectedType == type;
        return ChoiceChip(
          label: Text(_getTypeDisplayName(type)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onTypeChanged(type);
            }
          },
          selectedColor: _getTypeColor(type).withOpacity(0.2),
          checkmarkColor: _getTypeColor(type),
          avatar: Icon(
            _getTypeIcon(type),
            color: isSelected ? _getTypeColor(type) : Colors.grey,
            size: 20,
          ),
        );
      }).toList(),
    );
  }

  String _getTypeDisplayName(IncidentType type) {
    switch (type) {
      case IncidentType.accident:
        return 'Accident';
      case IncidentType.crime:
        return 'Crime';
      case IncidentType.fire:
        return 'Fire';
      case IncidentType.medical:
        return 'Medical';
      case IncidentType.violence:
        return 'Violence';
      case IncidentType.suspicious:
        return 'Suspicious';
      case IncidentType.other:
        return 'Other';
    }
  }

  Color _getTypeColor(IncidentType type) {
    switch (type) {
      case IncidentType.accident:
        return Colors.orange;
      case IncidentType.crime:
        return Colors.red;
      case IncidentType.fire:
        return Colors.deepOrange;
      case IncidentType.medical:
        return Colors.green;
      case IncidentType.violence:
        return Colors.purple;
      case IncidentType.suspicious:
        return Colors.amber;
      case IncidentType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(IncidentType type) {
    switch (type) {
      case IncidentType.accident:
        return Icons.car_crash;
      case IncidentType.crime:
        return Icons.gavel;
      case IncidentType.fire:
        return Icons.local_fire_department;
      case IncidentType.medical:
        return Icons.medical_services;
      case IncidentType.violence:
        return Icons.warning;
      case IncidentType.suspicious:
        return Icons.visibility;
      case IncidentType.other:
        return Icons.help;
    }
  }
}
