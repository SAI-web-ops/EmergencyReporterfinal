import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/upload_repository.dart';
import '../providers/points_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/stats_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.video_library),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenceScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            const ProfileHeader(),
            const SizedBox(height: 24),

            // Stats Cards
            Consumer<PointsProvider>(
              builder: (context, pointsProvider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Total Points',
                        value: '${pointsProvider.totalPoints}',
                        icon: Icons.stars,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Current Level',
                        value: '${pointsProvider.level}',
                        icon: Icons.trending_up,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Achievements Section
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const AchievementBadge(
              title: 'First Report',
              description: 'Submitted your first incident report',
              icon: Icons.flag,
              color: Colors.green,
              isUnlocked: true,
            ),
            const SizedBox(height: 12),
            const AchievementBadge(
              title: 'Safety Champion',
              description: 'Submitted 10 incident reports',
              icon: Icons.shield,
              color: Colors.blue,
              isUnlocked: true,
            ),
            const SizedBox(height: 12),
            const AchievementBadge(
              title: 'Community Hero',
              description: 'Reached level 5',
              icon: Icons.emoji_events,
              color: Colors.purple,
              isUnlocked: false,
            ),
            const SizedBox(height: 12),
            const AchievementBadge(
              title: 'Anonymous Helper',
              description: 'Submitted 5 anonymous reports',
              icon: Icons.visibility_off,
              color: Colors.orange,
              isUnlocked: false,
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Name', 'John Doe'),
                    _buildInfoRow('Email', 'john.doe@example.com'),
                    _buildInfoRow('Phone', '+1 234 567 8900'),
                    _buildInfoRow('Location', 'New York, NY'),
                    _buildInfoRow('Member Since', 'January 2024'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Emergency Contact', 'Jane Doe (+1 234 567 8901)'),
                    _buildInfoRow('Medical Info', 'No known allergies'),
                    _buildInfoRow('Blood Type', 'O+'),
                    _buildInfoRow('Insurance', 'ABC Health Insurance'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportData(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Export Data'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareProfile(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Share Profile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    // TODO: Implement edit profile functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon!')),
    );
  }

  void _exportData(BuildContext context) {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon!')),
    );
  }

  void _shareProfile(BuildContext context) {
    // TODO: Implement profile sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile sharing feature coming soon!')),
    );
  }
}

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});
  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; });
    try {
      final repo = context.read<UploadRepository>();
      final list = await repo.listEvidence();
      if (mounted) setState(() { _items = list; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final it = _items[index];
                return ListTile(
                  leading: const Icon(Icons.attachment),
                  title: Text(it['filename'] as String? ?? ''),
                  subtitle: Text(it['url'] as String? ?? ''),
                  onTap: () async {
                    final filename = (it['filename'] as String).split('/').last;
                    final uri = Uri.parse('${context.read<UploadRepository>().apiClient.baseUrl}/uploads/decrypt/$filename');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${uri.toString()}')));
                  },
                );
              },
            ),
    );
  }
}
