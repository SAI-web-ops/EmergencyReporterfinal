import 'package:flutter/material.dart';
import '../screens/emergency_contacts_screen.dart';

class EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onCall;
  final VoidCallback onInfo;

  const EmergencyContactCard({
    super.key,
    required this.contact,
    required this.onCall,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onCall,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: contact.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  contact.icon,
                  color: contact.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.number,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: contact.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: onCall,
                    icon: Icon(
                      Icons.phone,
                      color: contact.color,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: contact.color.withOpacity(0.1),
                    ),
                  ),
                  IconButton(
                    onPressed: onInfo,
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
