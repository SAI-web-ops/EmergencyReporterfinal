import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../screens/citizen_points_screen.dart';

class PointsSummaryCard extends StatelessWidget {
  const PointsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToPoints(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Citizen Points',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${pointsProvider.totalPoints} points',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.amber[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Level ${pointsProvider.level}',
                                style: TextStyle(
                                  color: Colors.amber[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (pointsProvider.totalPoints % 100) / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber[600]!,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pointsProvider.pointsToNextLevel} points to next level',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToPoints(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitizenPointsScreen()),
    );
  }
}
