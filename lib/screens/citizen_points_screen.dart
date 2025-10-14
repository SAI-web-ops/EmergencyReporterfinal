import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/points_provider.dart';
import '../widgets/points_progress_card.dart';
import '../widgets/rewards_card.dart';
import '../widgets/transaction_item.dart';
import '../repositories/points_repository.dart';

class CitizenPointsScreen extends StatefulWidget {
  const CitizenPointsScreen({super.key});

  @override
  State<CitizenPointsScreen> createState() => _CitizenPointsScreenState();
}

class _CitizenPointsScreenState extends State<CitizenPointsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPoints());
  }

  Future<void> _loadPoints() async {
    setState(() { _loading = true; });
    try {
      final repo = context.read<PointsRepository>();
      final data = await repo.fetchPoints();
      context.read<PointsProvider>().hydrateFromBackend(data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load points: $e')),
        );
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Points'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadPoints,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Rewards', icon: Icon(Icons.card_giftcard)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildRewardsTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points Summary Card
              AnimationLimiter(
                child: AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: PointsProgressCard(
                        totalPoints: pointsProvider.totalPoints,
                        level: pointsProvider.level,
                        pointsToNextLevel: pointsProvider.pointsToNextLevel,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Stats
              Text(
                'Quick Stats',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AnimationLimiter(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimationConfiguration.staggeredList(
                        position: 1,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildStatCard(
                              'Reports',
                              '${pointsProvider.transactions.where((t) => t.type == PointsType.earned).length}',
                              Icons.report_problem,
                              Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimationConfiguration.staggeredList(
                        position: 2,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildStatCard(
                              'Level',
                              '${pointsProvider.level}',
                              Icons.stars,
                              Colors.amber,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AnimationLimiter(
                child: Column(
                  children: pointsProvider.transactions.take(3).toList().asMap().entries.map((entry) {
                    int index = entry.key;
                    var transaction = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index + 3,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: TransactionItem(transaction: transaction),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardsTab() {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: context.read<PointsRepository>().fetchPoints().then((_) async {
            // fetch rewards catalog
            final res = await context.read<PointsRepository>().apiClient.get('/points/rewards');
            return { 'rewards': (res['data'] as List<dynamic>) };
          }),
          builder: (context, snap) {
            final rewards = (snap.data?['rewards'] as List<dynamic>? ?? []).map((m) {
              final id = (m as Map<String, dynamic>)['id'] as String;
              final title = m['title'] as String? ?? id;
              final pts = (m['pointsRequired'] as num?)?.toInt() ?? 0;
              return Reward(title: title, description: '', pointsRequired: pts, icon: Icons.card_giftcard, color: Colors.green, isAvailable: true);
            }).toList();
            if (!snap.hasData) {
              return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AnimationLimiter(
                child: Column(
                  children: rewards.asMap().entries.map((entry) {
                    int index = entry.key;
                    Reward reward = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: RewardsCard(
                            reward: reward,
                            userPoints: pointsProvider.totalPoints,
                            onRedeem: () => _redeemReward(reward),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        if (pointsProvider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start reporting incidents to earn points!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pointsProvider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = pointsProvider.transactions[index];
            return AnimationLimiter(
              child: AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: TransactionItem(transaction: transaction),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _redeemReward(Reward reward) async {
    final pointsProvider = context.read<PointsProvider>();
    if (pointsProvider.totalPoints < reward.pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough points. You need ${reward.pointsRequired} points.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem ${reward.title}?'),
        content: Text(
          'This will cost ${reward.pointsRequired} points. '
          'Are you sure you want to redeem this reward?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final repo = context.read<PointsRepository>();
      // call backend rewards redemption for code
      final res = await repo.apiClient.post('/points/rewards/redeem', body: { 'rewardId': reward.title.toLowerCase().replaceAll(' ', '-') });
      final code = (res['data'] as Map<String, dynamic>)['code'];
      pointsProvider.redeemPoints(reward.pointsRequired, 'Redeemed: ${reward.title}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reward.title} redeemed! Code: $code'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to redeem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class Reward {
  final String title;
  final String description;
  final int pointsRequired;
  final IconData icon;
  final Color color;
  final bool isAvailable;

  Reward({
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.icon,
    required this.color,
    required this.isAvailable,
  });
}
