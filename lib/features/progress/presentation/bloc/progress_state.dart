part of 'progress_bloc.dart';

abstract class ProgressState {}

class ProgressInitial  extends ProgressState {}
class ProgressLoading  extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final int     sessions;
  final int     streakDays;
  final int     awards;
  final int     totalScore;
  final List<WeeklyData>              weeklyData;
  final List<DailyLog>                dailyLogs;
  final Map<String, GameStatSummary>  gameStats;
  final String  selectedView;   // 'Parent' | 'Doctor'
  final String  selectedTab;    // 'overview' | 'games' | 'logs'
  final String? filteredGameId; // null = all
  final bool    isRealData;     // false = mock data

  ProgressLoaded({
    required this.sessions,
    required this.streakDays,
    required this.awards,
    required this.totalScore,
    required this.weeklyData,
    required this.dailyLogs,
    required this.gameStats,
    required this.selectedView,
    this.selectedTab    = 'overview',
    this.filteredGameId,
    this.isRealData     = false,
  });

  ProgressLoaded copyWith({
    int?    sessions,
    int?    streakDays,
    int?    awards,
    int?    totalScore,
    List<WeeklyData>?             weeklyData,
    List<DailyLog>?               dailyLogs,
    Map<String, GameStatSummary>? gameStats,
    String? selectedView,
    String? selectedTab,
    String? filteredGameId,
    bool    clearFilter = false,
    bool?   isRealData,
  }) => ProgressLoaded(
    sessions:       sessions       ?? this.sessions,
    streakDays:     streakDays     ?? this.streakDays,
    awards:         awards         ?? this.awards,
    totalScore:     totalScore     ?? this.totalScore,
    weeklyData:     weeklyData     ?? this.weeklyData,
    dailyLogs:      dailyLogs      ?? this.dailyLogs,
    gameStats:      gameStats      ?? this.gameStats,
    selectedView:   selectedView   ?? this.selectedView,
    selectedTab:    selectedTab    ?? this.selectedTab,
    filteredGameId: clearFilter ? null : (filteredGameId ?? this.filteredGameId),
    isRealData:     isRealData     ?? this.isRealData,
  );
}

class ProgressError extends ProgressState {
  final String message;
  ProgressError(this.message);
}

// ── Data models ──────────────────────────────────────────────────────────────

class WeeklyData {
  final String day;
  final double value;
  const WeeklyData({required this.day, required this.value});
}

class DailyLog {
  final String label;
  final String note;
  final int    score;
  final String emoji;
  final String gameName;
  final DateTime playedAt;
  const DailyLog({
    required this.label,
    required this.note,
    required this.score,
    required this.emoji,
    this.gameName = '',
    required this.playedAt,
  });
}

class GameStatSummary {
  final String gameId;
  final String gameName;
  final String emoji;
  final int    plays;
  final double avgAccuracy;
  final int    bestScore;
  final DateTime lastPlayed;

  const GameStatSummary({
    required this.gameId,
    required this.gameName,
    required this.emoji,
    required this.plays,
    required this.avgAccuracy,
    required this.bestScore,
    required this.lastPlayed,
  });
}
