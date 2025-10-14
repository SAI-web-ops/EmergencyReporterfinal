import 'package:flutter/material.dart';
import '../utils/i18n.dart';

class SafetyGuidanceScreen extends StatelessWidget {
  const SafetyGuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Guidance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'First Aid Basics',
              [
                'Check for danger before approaching',
                'Call emergency services immediately',
                'Check breathing and pulse',
                'Apply pressure to stop bleeding',
                'Keep victim warm and comfortable',
                'Do not move victim unless necessary',
              ],
              Icons.medical_services,
              Colors.red,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Fire Safety',
              [
                'Stop, drop, and roll if clothes catch fire',
                'Crawl low under smoke',
                'Feel doors before opening',
                'Use stairs, not elevators',
                'Meet at designated assembly point',
                'Call 101 for fire emergencies',
              ],
              Icons.local_fire_department,
              Colors.orange,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Earthquake Safety',
              [
                'Drop, cover, and hold on',
                'Stay away from windows',
                'Stay indoors if inside',
                'Move to open area if outside',
                'Avoid overpasses and buildings',
                'Be prepared for aftershocks',
              ],
              Icons.warning,
              Colors.yellow[700]!,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Emergency Contacts',
              [
                'Police: 100',
                'Ambulance: 108/102',
                'Fire: 101',
                'Women Helpline: 1091',
                'Child Helpline: 1098',
                'Disaster Management: 108',
              ],
              Icons.phone,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> items, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
