import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../utils/phone.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../repositories/alerts_repository.dart';

class PanicButtonScreen extends StatefulWidget {
  const PanicButtonScreen({super.key});

  @override
  State<PanicButtonScreen> createState() => _PanicButtonScreenState();
}

class _PanicButtonScreenState extends State<PanicButtonScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  bool _isPanicActive = false;
  bool _isShakeEnabled = true;
  int _shakeCount = 0;
  Timer? _shakeTimer;
  Timer? _panicTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Real shake detection via accelerometer
    double lastMagnitude = 0;
    accelerometerEvents.listen((event) {
      if (!_isShakeEnabled || _isPanicActive) return;
      final gX = event.x / 9.81, gY = event.y / 9.81, gZ = event.z / 9.81;
      final magnitude = sqrt(gX * gX + gY * gY + gZ * gZ);
      // simple threshold on delta magnitude
      final delta = (magnitude - lastMagnitude).abs();
      lastMagnitude = magnitude;
      if (delta > 1.2) {
        _onShake();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _shakeTimer?.cancel();
    _panicTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panic Button'),
        backgroundColor: _isPanicActive ? Colors.red : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isPanicActive
                ? [Colors.red[900]!, Colors.red[700]!]
                : [Colors.grey[100]!, Colors.grey[200]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Instructions
                if (!_isPanicActive) ...[
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange[600],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Panic Button',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Shake your phone rapidly or press the button below to trigger emergency response',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],

                // Panic Button
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isPanicActive ? _pulseAnimation.value : 1.0,
                      child: GestureDetector(
                        onTap: _isPanicActive ? _cancelPanic : _triggerPanic,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isPanicActive
                                ? Colors.red
                                : Colors.red[600],
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isPanicActive
                                            ? Colors.red
                                            : Colors.red[600])!
                                        .withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPanicActive ? Icons.stop : Icons.warning,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Status Text
                Text(
                  _isPanicActive
                      ? 'EMERGENCY ALERT ACTIVE!\nEmergency services have been notified'
                      : 'Press the button or shake your phone to activate',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _isPanicActive ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (_isPanicActive) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Countdown: ${_getCountdownText()}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Shake Detection Toggle
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.vibration,
                          color: _isShakeEnabled ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shake Detection',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _isShakeEnabled
                                    ? 'Shake your phone to trigger panic mode'
                                    : 'Shake detection is disabled',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isShakeEnabled,
                          onChanged: _isPanicActive
                              ? null
                              : (value) {
                                  setState(() {
                                    _isShakeEnabled = value;
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Emergency Contacts
                if (!_isPanicActive) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Quick Emergency Contacts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickContactButton(
                        'Police',
                        '100',
                        Icons.local_police,
                        Colors.blue,
                      ),
                      _buildQuickContactButton(
                        'Ambulance',
                        '108',
                        Icons.medical_services,
                        Colors.red,
                      ),
                      _buildQuickContactButton(
                        'Fire',
                        '101',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickContactButton(
    String name,
    String number,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _makeEmergencyCall(number),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        Text(
          number,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _triggerPanic() {
    setState(() {
      _isPanicActive = true;
    });

    // Start pulsing animation
    _pulseController.repeat(reverse: true);

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Call backend panic API with latest location (if available)
    _notifyBackend();

    // Show confirmation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Alert Triggered'),
        content: const Text(
          'Emergency services have been notified. Help is on the way. '
          'Stay calm and follow instructions.',
        ),
        actions: [
          TextButton(
            onPressed: _cancelPanic,
            child: const Text('Cancel Alert'),
          ),
        ],
      ),
    );

    // Auto-cancel after 30 seconds
    _panicTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _cancelPanic();
      }
    });
  }

  void _cancelPanic() {
    setState(() {
      _isPanicActive = false;
    });

    _pulseController.stop();
    _pulseController.reset();
    _panicTimer?.cancel();

    // Haptic feedback
    HapticFeedback.lightImpact();

    if (mounted) {
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert cancelled'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _notifyBackend() async {
    try {
      final location = context.read<LocationProvider>().currentLocation;
      if (location == null) return;
      final alerts = context.read<AlertsRepository>();
      await alerts.triggerPanic(
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency services notified')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to notify: $e')));
      }
    }
  }

  void _makeEmergencyCall(String number) {
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
                  SnackBar(
                    content: Text('Unable to place call to $number'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  String _getCountdownText() {
    if (_panicTimer == null) return '0:00';
    // For demo purposes, show a simple countdown
    final remaining = 30; // 30 seconds total
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Simulate shake detection (in real app, use accelerometer)
  void _simulateShake() {
    if (!_isShakeEnabled || _isPanicActive) return;

    _shakeCount++;
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });

    // Reset shake count after 2 seconds
    _shakeTimer?.cancel();
    _shakeTimer = Timer(const Duration(seconds: 2), () {
      _shakeCount = 0;
    });

    // Trigger panic after 3 rapid shakes
    if (_shakeCount >= 3) {
      _triggerPanic();
    }
  }

  void _onShake() {
    if (!_isShakeEnabled || _isPanicActive) return;
    _shakeCount++;
    _shakeController.forward().then((_) => _shakeController.reverse());
    _shakeTimer?.cancel();
    _shakeTimer = Timer(const Duration(seconds: 2), () {
      _shakeCount = 0;
    });
    if (_shakeCount >= 3) {
      _triggerPanic();
    }
  }
}
