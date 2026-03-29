import 'package:flutter_bloc/flutter_bloc.dart';
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

  ProgressBloc({ProgressRepository? repo})
      : _repo = repo ?? ProgressRepository(),
        super(ProgressInitial()) {
    on<ProgressLoadRequested>(_onLoad);
    on<ProgressViewSwitched>(_onViewSwitched);
    on<ProgressTabSwitched>(_onTabSwitched);
    on<ProgressGameFilterChanged>(_onGameFilter);
  }

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> _onLoad(
      ProgressLoadRequested event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    try {
      final results = await _repo.fetchRecentResults(limit: 100);

      if (results.isEmpty) {
        // No Firebase data → show rich mock data so the page looks alive
        emit(_mockState());
        return;
      }

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
        isRealData: true,
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
        sessions: 24,
        streakDays: 7,
        awards: 3,
        totalScore: 480,
        weeklyData: const [
          WeeklyData(day: 'Sun', value: 0.60),
          WeeklyData(day: 'Mon', value: 0.75),
          WeeklyData(day: 'Tue', value: 0.45),
          WeeklyData(day: 'Wed', value: 0.85),
          WeeklyData(day: 'Thu', value: 0.65),
          WeeklyData(day: 'Fri', value: 0.70),
          WeeklyData(day: 'Sat', value: 0.90),
        ],
        dailyLogs: [
          DailyLog(
              label: 'Today',
              note: 'Color Sorting — 9/10 rounds',
              score: 9,
              emoji: '😊',
              gameName: 'Color Sorting',
              playedAt: DateTime.now()),
          DailyLog(
              label: 'Today',
              note: 'Sequencing — arranged 8 stories',
              score: 8,
              emoji: '😊',
              gameName: 'Sequencing',
              playedAt: DateTime.now().subtract(const Duration(hours: 2))),
          DailyLog(
              label: 'Yesterday',
              note: 'Word Builder — spelled 6 words',
              score: 6,
              emoji: '😐',
              gameName: 'Word Builder',
              playedAt: DateTime.now().subtract(const Duration(days: 1))),
          DailyLog(
              label: '2 Days Ago',
              note: 'Color Match — quick reactions',
              score: 8,
              emoji: '😊',
              gameName: 'Color Match',
              playedAt: DateTime.now().subtract(const Duration(days: 2))),
          DailyLog(
              label: '3 Days Ago',
              note: 'Number Fun — streak of 5',
              score: 7,
              emoji: '😊',
              gameName: 'Number Fun',
              playedAt: DateTime.now().subtract(const Duration(days: 3))),
        ],
        gameStats: {
          'emotion_match': GameStatSummary(
              gameId: 'emotion_match',
              gameName: 'Emotion Match',
              emoji: '😊',
              plays: 6,
              avgAccuracy: 0.82,
              bestScore: 60,
              lastPlayed: _kYesterday),
          'word_builder': GameStatSummary(
              gameId: 'word_builder',
              gameName: 'Word Builder',
              emoji: '📝',
              plays: 5,
              avgAccuracy: 0.74,
              bestScore: 50,
              lastPlayed: _kYesterday),
          'color_match': GameStatSummary(
              gameId: 'color_match',
              gameName: 'Color Match',
              emoji: '🎨',
              plays: 4,
              avgAccuracy: 0.70,
              bestScore: 80,
              lastPlayed: _k2DaysAgo),
          'number_fun': GameStatSummary(
              gameId: 'number_fun',
              gameName: 'Number Fun',
              emoji: '🔢',
              plays: 4,
              avgAccuracy: 0.78,
              bestScore: 55,
              lastPlayed: _k2DaysAgo),
          'sequencing': GameStatSummary(
              gameId: 'sequencing',
              gameName: 'Sequencing',
              emoji: '🔢',
              plays: 3,
              avgAccuracy: 0.88,
              bestScore: 30,
              lastPlayed: _kToday),
          'color_sorting': GameStatSummary(
              gameId: 'color_sorting',
              gameName: 'Color Sorting',
              emoji: '🌈',
              plays: 2,
              avgAccuracy: 0.90,
              bestScore: 20,
              lastPlayed: _kToday),
        },
        selectedView: 'Parent',
        isRealData: false,
      );

  static final _kToday = DateTime.now();
  static final _kYesterday = DateTime.now().subtract(const Duration(days: 1));
  static final _k2DaysAgo = DateTime.now().subtract(const Duration(days: 2));

  String _relativeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24 && dt.day == now.day) return 'Today';
    if (diff.inHours < 48) return 'Yesterday';
    return '${diff.inDays} Days Ago';
  }
}
