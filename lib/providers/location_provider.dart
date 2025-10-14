import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });
}

class LocationProvider extends ChangeNotifier {
  LocationData? _currentLocation;
  bool _isLocationEnabled = false;
  bool _isLoading = false;
  String? _error;

  LocationData? get currentLocation => _currentLocation;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLocation(LocationData location) {
    _currentLocation = location;
    _error = null;
    _isLocationEnabled = true;
    notifyListeners();
  }

  void setLocationEnabled(bool enabled) {
    _isLocationEnabled = enabled;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearLocation() {
    _currentLocation = null;
    _error = null;
    notifyListeners();
  }

  Future<void> requestPermissionAndFetch() async {
    setLoading(true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setError('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        setError('Location permission denied');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        setError('Location permission permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      final placemark = placemarks.isNotEmpty ? placemarks.first : null;
      final address = placemark == null
          ? '(${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)})'
          : '${placemark.name ?? ''}, ${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}'.replaceAll(RegExp(', +'), ', ').trim().replaceFirst(RegExp(r',\s*$'), '');

      setLocation(LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        timestamp: DateTime.now(),
      ));
      setLoading(false);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
