import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/services/game_result_service.dart';
import 'package:autism_app/features/progress/data/repositories/progress_repository.dart';

part 'progress_event.dart';
part 'progress_state.dart';

// Emoji map for games
const _gameEmoji = {
  'emotion_match': '😊',
  'word_builder': '📝',
  'color_match': '🎨',
  'number_fun': '🔢',
  'sequencing': '🔢',
  'color_sorting': '🌈',
};

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final ProgressRepository _repo;
  StreamSubscription? _sub;

  ProgressBloc({ProgressRepository? repo})
      : _repo = repo ?? ProgressRepository(),
        super(ProgressInitial()) {
    on<ProgressLoadRequested>(_onLoad);
    on<ProgressViewSwitched>(_onViewSwitched);
    on<ProgressTabSwitched>(_onTabSwitched);
    on<ProgressGameFilterChanged>(_onGameFilter);

    _sub = GameResultService.instance.onResultSaved.listen((_) {
      add(ProgressLoadRequested());
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> _onLoad(
      ProgressLoadRequested event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    try {
      final results = await _repo.fetchRecentResults(limit: 100);


      // ── Build real state from Firestore results ──
      final weekly = _repo.computeWeekly(results);
      final streak = _repo.computeStreak(results);
      final rawStats = _repo.computeGameStats(results);

      final gameStats = rawStats.map((id, raw) => MapEntry(
          id,
          GameStatSummary(
            gameId: id,
            gameName: raw['gameName'] as String,
            emoji: _gameEmoji[id] ?? '🎮',
            plays: raw['plays'] as int,
            avgAccuracy: raw['avgAccuracy'] as double,
            bestScore: raw['bestScore'] as int,
            lastPlayed: raw['lastPlayed'] as DateTime,
          )));

      final logs = results.take(20).map((r) {
        final acc = (r.accuracy * 10).round();
        final emoji = acc >= 8
            ? '😊'
            : acc >= 5
                ? '😐'
                : '😕';
        final when = _relativeLabel(r.playedAt);
        return DailyLog(
          label: when,
          note: '${r.gameName} — ${r.score}/${r.maxScore} points',
          score: acc,
          emoji: emoji,
          gameName: r.gameName,
          playedAt: r.playedAt,
        );
      }).toList();

      final totalScore = results.map((r) => r.score).fold(0, (a, b) => a + b);
      final awards = (totalScore / 100).floor().clamp(0, 99);

      emit(ProgressLoaded(
        sessions: results.length,
        streakDays: streak,
        awards: awards,
        totalScore: totalScore,
        weeklyData: weekly
            .map((w) => WeeklyData(
                day: w['day'] as String, value: w['value'] as double))
            .toList(),
        dailyLogs: logs,
        gameStats: gameStats,
        selectedView: 'Parent',
        isRealData: _repo.isReal,
      ));
    } catch (e) {
      // On any error (including Firestore not enabled) → mock data
      emit(_mockState());
    }
  }

  void _onViewSwitched(
      ProgressViewSwitched event, Emitter<ProgressState> emit) {
    if (state is ProgressLoaded) {
      emit((state as ProgressLoaded).copyWith(selectedView: event.view));
    }
  }

  void _onTabSwitched(ProgressTabSwitched event, Emitter<ProgressState> emit) {
    if (state is ProgressLoaded) {
      emit((state as ProgressLoaded).copyWith(selectedTab: event.tab));
    }
  }

  void _onGameFilter(
      ProgressGameFilterChanged event, Emitter<ProgressState> emit) {
    if (state is ProgressLoaded) {
      if (event.gameId == null) {
        emit((state as ProgressLoaded).copyWith(clearFilter: true));
      } else {
        emit((state as ProgressLoaded).copyWith(filteredGameId: event.gameId));
      }
    }
  }

  // ── Mock state (no Firebase) ─────────────────────────────────────────────

  ProgressLoaded _mockState() => ProgressLoaded(
        sessions: 0,
        streakDays: 0,
        awards: 0,
        totalScore: 0,
        weeklyData: const [
          WeeklyData(day: 'Sun', value: 0.0),
          WeeklyData(day: 'Mon', value: 0.0),
          WeeklyData(day: 'Tue', value: 0.0),
          WeeklyData(day: 'Wed', value: 0.0),
          WeeklyData(day: 'Thu', value: 0.0),
          WeeklyData(day: 'Fri', value: 0.0),
          WeeklyData(day: 'Sat', value: 0.0),
        ],
        dailyLogs: const [],
        gameStats: const {},
        selectedView: 'Parent',
        isRealData: false,
      );

  String _relativeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24 && dt.day == now.day) return 'Today';
    if (diff.inHours < 48) return 'Yesterday';
    return '${diff.inDays} Days Ago';
  }
}
