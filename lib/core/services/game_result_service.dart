import 'package:autism_app/features/progress/data/models/game_result.dart';
import 'package:autism_app/features/progress/data/repositories/progress_repository.dart';
import 'package:flutter/foundation.dart';


/// Singleton service — call GameResultService.instance.save(...) from any game
/// to persist the result to Firestore (or log it locally in dev mode).
class GameResultService {
  GameResultService._();
  static final instance = GameResultService._();

  final _repo = ProgressRepository();

  Future<void> save({
    required String gameId,
    required String gameName,
    required int score,
    required int maxScore,
    required int durationSeconds,
    Map<String, dynamic> extras = const {},
  }) async {
    final result = GameResult(
      id:              '',
      gameId:          gameId,
      gameName:        gameName,
      score:           score,
      maxScore:        maxScore,
      durationSeconds: durationSeconds,
      playedAt:        DateTime.now(),
      extras:          extras,
    );
    try {
      await _repo.saveResult(result);
    } catch (e) {
      debugPrint('⚠️  GameResultService.save failed: $e');
    }
  }
}
