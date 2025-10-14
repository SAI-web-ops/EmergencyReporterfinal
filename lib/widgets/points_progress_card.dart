import 'package:flutter/material.dart';

class PointsProgressCard extends StatelessWidget {
  final int totalPoints;
  final int level;
  final int pointsToNextLevel;

  const PointsProgressCard({
    super.key,
    required this.totalPoints,
    required this.level,
    required this.pointsToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (totalPoints % 100) / 100;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber[100]!,
              Colors.amber[50]!,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Level Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Level $level',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Points Display
            Text(
              '$totalPoints',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.amber[800],
                fontWeight: FontWeight.bold,
                fontSize: 48,
              ),
            ),
            Text(
              'Citizen Points',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.amber[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to Level ${level + 1}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$pointsToNextLevel points to go',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.amber[600]!,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}% complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Achievement Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: Colors.amber[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getAchievementMessage(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAchievementMessage() {
    if (level >= 10) {
      return 'Community Hero! You\'re making a real difference.';
    } else if (level >= 5) {
      return 'Safety Champion! Keep up the great work.';
    } else if (level >= 2) {
      return 'Active Citizen! Every report matters.';
    } else {
      return 'Getting started! Report incidents to earn more points.';
    }
  }
}
