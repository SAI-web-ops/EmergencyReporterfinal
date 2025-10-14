import 'package:flutter/material.dart';
import '../models/incident.dart';

class PrioritySelector extends StatelessWidget {
  final IncidentPriority selectedPriority;
  final ValueChanged<IncidentPriority> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: IncidentPriority.values.map((priority) {
        final isSelected = selectedPriority == priority;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                _getPriorityDisplayName(priority),
                style: TextStyle(
                  color: isSelected ? Colors.white : _getPriorityColor(priority),
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onPriorityChanged(priority);
                }
              },
              selectedColor: _getPriorityColor(priority),
              backgroundColor: _getPriorityColor(priority).withOpacity(0.1),
              side: BorderSide(
                color: _getPriorityColor(priority),
                width: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getPriorityDisplayName(IncidentPriority priority) {
    switch (priority) {
      case IncidentPriority.low:
        return 'Low';
      case IncidentPriority.medium:
        return 'Medium';
      case IncidentPriority.high:
        return 'High';
      case IncidentPriority.critical:
        return 'Critical';
    }
  }

  Color _getPriorityColor(IncidentPriority priority) {
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
}
