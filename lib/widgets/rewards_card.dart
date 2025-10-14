import 'package:flutter/material.dart';
import '../screens/citizen_points_screen.dart';

class RewardsCard extends StatelessWidget {
  final Reward reward;
  final int userPoints;
  final VoidCallback onRedeem;

  const RewardsCard({
    super.key,
    required this.reward,
    required this.userPoints,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final canRedeem = userPoints >= reward.pointsRequired && reward.isAvailable;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: canRedeem ? onRedeem : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: reward.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  reward.icon,
                  color: reward.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: Colors.amber[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.pointsRequired} points',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.amber[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Button
              Column(
                children: [
                  if (canRedeem)
                    ElevatedButton(
                      onPressed: onRedeem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: reward.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Redeem'),
                    )
                  else if (!reward.isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Need ${reward.pointsRequired - userPoints} more',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (canRedeem)
                    Text(
                      'Tap to redeem',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
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
