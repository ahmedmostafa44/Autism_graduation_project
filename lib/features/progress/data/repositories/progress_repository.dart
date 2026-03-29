import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/game_result.dart';

class ProgressRepository {
  bool get _ready => Firebase.apps.isNotEmpty;

  FirebaseFirestore get _db   => FirebaseFirestore.instance;
  FirebaseAuth      get _auth => FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ── Save a game result ────────────────────────────────────────────────────

  Future<void> saveResult(GameResult result) async {
    if (!_ready || _uid == null) {
      debugPrint('📊 [Progress] local mode — result not saved: ${result.gameName} ${result.score}/${result.maxScore}');
      return;
    }
    await _db
        .collection('users')
        .doc(_uid)
        .collection('gameResults')
        .add(result.toFirestore());
  }

  // ── Fetch last N results ──────────────────────────────────────────────────

  Future<List<GameResult>> fetchRecentResults({int limit = 50}) async {
    if (!_ready || _uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('gameResults')
        .orderBy('playedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(GameResult.fromFirestore).toList();
  }

  // ── Fetch results for a specific game ────────────────────────────────────

  Future<List<GameResult>> fetchResultsForGame(String gameId, {int limit = 20}) async {
    if (!_ready || _uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('gameResults')
        .where('gameId', isEqualTo: gameId)
        .orderBy('playedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(GameResult.fromFirestore).toList();
  }

  // ── Compute streak (consecutive days with at least 1 game) ───────────────

  int computeStreak(List<GameResult> results) {
    if (results.isEmpty) return 0;
    final days = results
        .map((r) => DateTime(r.playedAt.year, r.playedAt.month, r.playedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    int streak = 0;
    DateTime expected = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    for (final day in days) {
      if (day == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // ── Weekly activity (0.0–1.0 per day for last 7 days) ───────────────────

  List<Map<String, dynamic>> computeWeekly(List<GameResult> results) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final label = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day.weekday % 7];
      final dayResults = results.where((r) =>
          r.playedAt.year  == day.year &&
          r.playedAt.month == day.month &&
          r.playedAt.day   == day.day).toList();
      // value = average accuracy that day (or 0)
      final value = dayResults.isEmpty
          ? 0.0
          : dayResults.map((r) => r.accuracy).reduce((a, b) => a + b) /
              dayResults.length;
      return {'day': label, 'value': value.clamp(0.0, 1.0)};
    });
  }

  // ── Per-game summary ──────────────────────────────────────────────────────

  Map<String, Map<String, dynamic>> computeGameStats(List<GameResult> results) {
    final Map<String, List<GameResult>> grouped = {};
    for (final r in results) {
      grouped.putIfAbsent(r.gameId, () => []).add(r);
    }
    return grouped.map((gameId, list) {
      final avgAcc = list.map((r) => r.accuracy).reduce((a, b) => a + b) / list.length;
      final best   = list.map((r) => r.score).reduce((a, b) => a > b ? a : b);
      return MapEntry(gameId, {
        'gameName':   list.first.gameName,
        'plays':      list.length,
        'avgAccuracy': avgAcc,
        'bestScore':  best,
        'lastPlayed': list.first.playedAt,
      });
    });
  }
}
