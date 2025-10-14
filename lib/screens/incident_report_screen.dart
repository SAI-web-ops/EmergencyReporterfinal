import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/incident_provider.dart';
import '../providers/location_provider.dart';
import '../providers/points_provider.dart';
import '../models/incident.dart';
import '../widgets/incident_type_selector.dart';
import '../widgets/priority_selector.dart';
import '../widgets/media_capture_widget.dart';
import '../repositories/incident_repository.dart';
import '../repositories/points_repository.dart';
import '../utils/offline_queue.dart';
import '../repositories/chat_repository.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  IncidentType _selectedType = IncidentType.other;
  IncidentPriority _selectedPriority = IncidentPriority.medium;
  bool _isAnonymous = false;
  List<String> _mediaUrls = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        actions: [
          Consumer<IncidentProvider>(
            builder: (context, incidentProvider, child) {
              return TextButton(
                onPressed: incidentProvider.isUploading ? null : _submitReport,
                child: incidentProvider.isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Submit'),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident Type Selection
              Text(
                'Incident Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              IncidentTypeSelector(
                selectedType: _selectedType,
                onTypeChanged: (type) {
                  setState(() {
                    _selectedType = type;
                    // Auto-set priority based on type
                    _selectedPriority = _getPriorityForType(type);
                  });
                },
              ),
              const SizedBox(height: 24),

              // Priority Selection
              Text(
                'Priority Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              PrioritySelector(
                selectedPriority: _selectedPriority,
                onPriorityChanged: (priority) {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Incident Title',
                  hintText: 'Brief description of the incident',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Provide detailed information about the incident',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Media Capture
              Text(
                'Media Evidence',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              MediaCaptureWidget(
                onMediaCaptured: (urls) {
                  setState(() {
                    _mediaUrls = urls;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Location Information
              Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: locationProvider.currentLocation != null
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Location Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (locationProvider.currentLocation != null)
                            Text(
                              locationProvider.currentLocation!.address,
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            Text(
                              'Location not available. Please enable location services.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Anonymous Reporting Option
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anonymous Reporting',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Your identity will be protected when reporting this incident.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Consumer<IncidentProvider>(
                  builder: (context, incidentProvider, child) {
                    return ElevatedButton.icon(
                      onPressed: incidentProvider.isUploading ? null : _submitReport,
                      icon: incidentProvider.isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(incidentProvider.isUploading ? 'Submitting...' : 'Submit Report'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IncidentPriority _getPriorityForType(IncidentType type) {
    switch (type) {
      case IncidentType.medical:
      case IncidentType.fire:
        return IncidentPriority.critical;
      case IncidentType.violence:
      case IncidentType.crime:
        return IncidentPriority.high;
      case IncidentType.accident:
        return IncidentPriority.medium;
      case IncidentType.suspicious:
        return IncidentPriority.medium;
      case IncidentType.other:
        return IncidentPriority.low;
    }
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final incidentProvider = Provider.of<IncidentProvider>(context, listen: false);
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    final incidentRepo = Provider.of<IncidentRepository>(context, listen: false);
    final pointsRepo = Provider.of<PointsRepository>(context, listen: false);

    if (locationProvider.currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is required to submit a report'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      incidentProvider.setUploading(true);

      // Create incident
      final incident = Incident(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        status: IncidentStatus.reported,
        priority: _selectedPriority,
        title: _titleController.text,
        description: _descriptionController.text,
        latitude: locationProvider.currentLocation!.latitude,
        longitude: locationProvider.currentLocation!.longitude,
        address: locationProvider.currentLocation!.address,
        timestamp: DateTime.now(),
        mediaUrls: _mediaUrls,
        isAnonymous: _isAnonymous,
        pointsAwarded: _calculatePoints(),
      );

      // Send to backend; if it fails, store offline
      Incident created;
      try {
        created = await incidentRepo.createIncident(incident);
        // Update local state
        incidentProvider.addIncident(created);
        // Persist points to backend and local
        await pointsRepo.addPoints(
          created.pointsAwarded,
          'Reported ${created.typeDisplayName}',
        );
        pointsProvider.addPoints(
          created.pointsAwarded,
          'Reported ${created.typeDisplayName}',
        );
      } catch (e) {
        await OfflineQueueService.addPending(incident);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No internet. Saved offline and will retry.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        created = incident;
      }

      if (mounted) {
        if (created != incident) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report submitted successfully! +${created.pointsAwarded} points'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Offer to open chat with dispatcher
        final openChat = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Open Chat?'),
          content: const Text('Would you like to open chat with dispatcher for this incident?'),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: const Text('No')),
            ElevatedButton(onPressed: ()=>Navigator.pop(ctx, true), child: const Text('Open')),
          ],
        ));
        if (openChat == true) {
          Navigator.pop(context);
          // naive chat: send greeting
          final chatRepo = Provider.of<ChatRepository>(context, listen: false);
          await chatRepo.sendMessage(incidentId: created.id, text: 'Reporter available for details.');
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        incidentProvider.setUploading(false);
      }
    }
  }

  int _calculatePoints() {
    int basePoints = 10;
    
    // Priority multiplier
    switch (_selectedPriority) {
      case IncidentPriority.low:
        basePoints = 5;
        break;
      case IncidentPriority.medium:
        basePoints = 10;
        break;
      case IncidentPriority.high:
        basePoints = 20;
        break;
      case IncidentPriority.critical:
        basePoints = 30;
        break;
    }

    // Media bonus
    if (_mediaUrls.isNotEmpty) {
      basePoints += 5;
    }

    // Anonymous reporting bonus
    if (_isAnonymous) {
      basePoints += 5;
    }

    return basePoints;
  }
}
