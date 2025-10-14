import 'package:flutter/material.dart';

class PointsTransaction {
  final String id;
  final int points;
  final String description;
  final DateTime timestamp;
  final PointsType type;

  PointsTransaction({
    required this.id,
    required this.points,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}

enum PointsType {
  earned,
  redeemed,
  bonus,
  penalty,
}

class PointsProvider extends ChangeNotifier {
  int _totalPoints = 0;
  List<PointsTransaction> _transactions = [];
  int _level = 1;
  int _pointsToNextLevel = 100;

  int get totalPoints => _totalPoints;
  List<PointsTransaction> get transactions => _transactions;
  int get level => _level;
  int get pointsToNextLevel => _pointsToNextLevel;

  void addPoints(int points, String description, {PointsType type = PointsType.earned}) {
    _totalPoints += points;
    _transactions.insert(0, PointsTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: points,
      description: description,
      timestamp: DateTime.now(),
      type: type,
    ));
    _updateLevel();
    notifyListeners();
  }

  void redeemPoints(int points, String description) {
    if (_totalPoints >= points) {
      _totalPoints -= points;
      _transactions.insert(0, PointsTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: -points,
        description: description,
        timestamp: DateTime.now(),
        type: PointsType.redeemed,
      ));
      notifyListeners();
    }
  }

  void hydrateFromBackend(Map<String, dynamic> snapshot) {
    _totalPoints = snapshot['totalPoints'] as int? ?? 0;
    final list = (snapshot['transactions'] as List<dynamic>? ?? []);
    _transactions = list.map((e) {
      final m = e as Map<String, dynamic>;
      return PointsTransaction(
        id: m['id'].toString(),
        points: (m['points'] as num).toInt(),
        description: m['description'] as String? ?? '',
        timestamp: DateTime.parse(m['timestamp'] as String),
        type: _parseType(m['type'] as String? ?? 'earned'),
      );
    }).toList();
    _updateLevel();
    notifyListeners();
  }

  PointsType _parseType(String t) {
    switch (t) {
      case 'redeemed':
        return PointsType.redeemed;
      case 'bonus':
        return PointsType.bonus;
      case 'penalty':
        return PointsType.penalty;
      case 'earned':
      default:
        return PointsType.earned;
    }
  }

  void _updateLevel() {
    int newLevel = (_totalPoints ~/ 100) + 1;
    if (newLevel != _level) {
      _level = newLevel;
      _pointsToNextLevel = (_level * 100) - _totalPoints;
    } else {
      _pointsToNextLevel = (_level * 100) - _totalPoints;
    }
  }

  void clearPoints() {
    _totalPoints = 0;
    _transactions.clear();
    _level = 1;
    _pointsToNextLevel = 100;
    notifyListeners();
  }
}
