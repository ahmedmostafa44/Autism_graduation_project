part of 'progress_bloc.dart';

abstract class ProgressState {}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final int sessions;
  final int streakDays;
  final int awards;
  final List<WeeklyData> weeklyData;
  final List<DailyLog> dailyLogs;
  final String selectedView;

  ProgressLoaded({
    required this.sessions,
    required this.streakDays,
    required this.awards,
    required this.weeklyData,
    required this.dailyLogs,
    required this.selectedView,
  });

  ProgressLoaded copyWith({String? selectedView}) => ProgressLoaded(
        sessions: sessions,
        streakDays: streakDays,
        awards: awards,
        weeklyData: weeklyData,
        dailyLogs: dailyLogs,
        selectedView: selectedView ?? this.selectedView,
      );
}

class ProgressError extends ProgressState {
  final String message;
  ProgressError(this.message);
}

// Data models used by state
class WeeklyData {
  final String day;
  final double value;
  const WeeklyData({required this.day, required this.value});
}

class DailyLog {
  final String label;
  final String note;
  final int score;
  final String emoji;
  const DailyLog({required this.label, required this.note, required this.score, required this.emoji});
}
