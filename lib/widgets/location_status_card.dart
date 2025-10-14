import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class LocationStatusCard extends StatelessWidget {
  const LocationStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: locationProvider.isLocationEnabled
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    locationProvider.isLocationEnabled
                        ? Icons.location_on
                        : Icons.location_off,
                    color: locationProvider.isLocationEnabled
                        ? Colors.green
                        : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Status',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (locationProvider.isLoading)
                        const Text(
                          'Getting location...',
                          style: TextStyle(color: Colors.orange),
                        )
                      else if (locationProvider.error != null)
                        Text(
                          'Error: ${locationProvider.error}',
                          style: const TextStyle(color: Colors.red),
                        )
                      else if (locationProvider.currentLocation != null)
                        Text(
                          locationProvider.currentLocation!.address,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        const Text(
                          'Location not available',
                          style: TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                if (locationProvider.isLocationEnabled)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      // TODO: Request location permission and get current location
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Requesting location permission...'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
