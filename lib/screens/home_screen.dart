import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/location_provider.dart';
import '../providers/points_provider.dart';
import '../widgets/emergency_button.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/location_status_card.dart';
import '../widgets/points_summary_card.dart';
import 'incident_report_screen.dart';
import 'emergency_contacts_screen.dart';
import 'panic_button_screen.dart';
import 'citizen_points_screen.dart';
import 'settings_screen.dart';
import 'safety_guidance_screen.dart';
import '../utils/phone.dart';
import '../repositories/incident_repository.dart';
import '../models/incident.dart';
import '../utils/offline_queue.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  List<Incident> _recent = [];
  bool _loadingIncidents = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Kick off location fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().requestPermissionAndFetch();
      _loadIncidents();
        _refreshPendingCount();
    });
  }

  Future<void> _loadIncidents() async {
    setState(() { _loadingIncidents = true; });
    try {
      final repo = context.read<IncidentRepository>();
      final list = await repo.listIncidents();
      if (mounted) setState(() { _recent = list.take(5).toList(); });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load incidents: $e')),
        );
      }
    } finally {
      if (mounted) setState(() { _loadingIncidents = false; });
    }
  }

  Future<void> _refreshPendingCount() async {
    final c = await OfflineQueueService.countPending();
    if (mounted) setState(() { _pendingCount = c; });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Reporter'),
        actions: [
          if (_pendingCount > 0)
            TextButton(
              onPressed: () async {
                final ok = await OfflineQueueService.submitAll(context);
                await _refreshPendingCount();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Submitted $ok pending report(s)')),
                );
                _loadIncidents();
              },
              child: Text('Retry (${_pendingCount})', style: const TextStyle(color: Colors.amber)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LocationProvider>().requestPermissionAndFetch();
              _loadIncidents();
              _refreshPendingCount();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Status Card
            const LocationStatusCard(),
            const SizedBox(height: 16),

            // Points Summary Card
            const PointsSummaryCard(),
            const SizedBox(height: 24),

            // Emergency Buttons Section
            Text(
              'Emergency Response',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            AnimationLimiter(
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  AnimationConfiguration.staggeredGrid(
                    position: 0,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: EmergencyButton(
                          title: 'Police',
                          subtitle: '100',
                          icon: Icons.local_police,
                          color: Colors.blue,
                          onPressed: () => _handleEmergencyCall('100'),
                        ),
                      ),
                    ),
                  ),
                  AnimationConfiguration.staggeredGrid(
                    position: 1,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: EmergencyButton(
                          title: 'Ambulance',
                          subtitle: '108/102',
                          icon: Icons.medical_services,
                          color: Colors.red,
                          onPressed: () => _handleEmergencyCall('108'),
                        ),
                      ),
                    ),
                  ),
                  AnimationConfiguration.staggeredGrid(
                    position: 2,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: EmergencyButton(
                          title: 'Fire',
                          subtitle: '101',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                          onPressed: () => _handleEmergencyCall('101'),
                        ),
                      ),
                    ),
                  ),
                  AnimationConfiguration.staggeredGrid(
                    position: 3,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: EmergencyButton(
                          title: 'Panic',
                          subtitle: 'Shake Phone',
                          icon: Icons.warning,
                          color: Colors.purple,
                          onPressed: () => _navigateToScreen(context, const PanicButtonScreen()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            AnimationLimiter(
              child: Column(
                children: [
                  AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: QuickActionCard(
                          title: 'Report Incident',
                          subtitle: 'Report accidents, crimes, emergencies',
                          icon: Icons.report_problem,
                          color: Colors.red,
                          onTap: () => _navigateToScreen(context, const IncidentReportScreen()),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimationConfiguration.staggeredList(
                    position: 1,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: QuickActionCard(
                          title: 'Emergency Contacts',
                          subtitle: 'Quick dial emergency services',
                          icon: Icons.contacts,
                          color: Colors.blue,
                          onTap: () => _navigateToScreen(context, const EmergencyContactsScreen()),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimationConfiguration.staggeredList(
                    position: 2,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: QuickActionCard(
                          title: 'Safety Guidance',
                          subtitle: 'First aid and emergency procedures',
                          icon: Icons.school,
                          color: Colors.green,
                          onTap: () => _navigateToScreen(context, const SafetyGuidanceScreen()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Incidents Section
            Text(
              'Recent Incidents',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _loadingIncidents
                ? const Center(child: CircularProgressIndicator())
                : _buildRecentIncidents(),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToScreen(context, const IncidentReportScreen()),
              icon: const Icon(Icons.add),
              label: const Text('Report'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentIncidents() {
    if (_recent.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.map,
                size: 48,
                color: Colors.green[400],
              ),
              const SizedBox(height: 8),
              Text(
                'No recent incidents',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Stay safe! No incidents reported in your area recently.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _recent.map((inc) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.report, color: inc.priorityColor),
            title: Text(inc.title),
            subtitle: Text('${inc.typeDisplayName} • ${inc.address}'),
            trailing: Text(inc.statusDisplayName),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(incidentId: inc.id))),
          ),
        );
      }).toList(),
    );
  }

  void _handleEmergencyCall(String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call $number?'),
        content: const Text('This will dial the emergency number immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final ok = await PhoneUtils.callNumber(number);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unable to place call to $number')),
                );
              }
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
