import 'package:cloud_firestore/cloud_firestore.dart';

/// One completed game session — saved to Firestore under users/{uid}/gameResults
class GameResult {
  final String id;
  final String gameId;
  final String gameName;
  final int score;
  final int maxScore;
  final int durationSeconds;
  final DateTime playedAt;
  final Map<String, dynamic> extras; // game-specific data

  const GameResult({
    required this.id,
    required this.gameId,
    required this.gameName,
    required this.score,
    required this.maxScore,
    required this.durationSeconds,
    required this.playedAt,
    this.extras = const {},
  });

  double get accuracy => maxScore > 0 ? score / maxScore : 0;

  // ── Firestore ─────────────────────────────────────────────────────────────

  factory GameResult.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GameResult(
      id:              doc.id,
      gameId:          d['gameId']          as String,
      gameName:        d['gameName']        as String,
      score:           d['score']           as int,
      maxScore:        d['maxScore']        as int,
      durationSeconds: d['durationSeconds'] as int? ?? 0,
      playedAt:        (d['playedAt']       as Timestamp).toDate(),
      extras:          (d['extras']         as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toFirestore() => {
    'gameId':          gameId,
    'gameName':        gameName,
    'score':           score,
    'maxScore':        maxScore,
    'durationSeconds': durationSeconds,
    'playedAt':        Timestamp.fromDate(playedAt),
    'extras':          extras,
  };
}
