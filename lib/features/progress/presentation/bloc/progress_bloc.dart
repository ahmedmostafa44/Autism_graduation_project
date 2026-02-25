import 'package:flutter_bloc/flutter_bloc.dart';

part 'progress_event.dart';
part 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  ProgressBloc() : super(ProgressInitial()) {
    on<ProgressLoadRequested>(_onLoad);
    on<ProgressViewSwitched>(_onViewSwitched);
  }

  Future<void> _onLoad(ProgressLoadRequested event, Emitter<ProgressState> emit) async {
    emit(ProgressLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(ProgressLoaded(
      sessions: 24,
      streakDays: 7,
      awards: 3,
      weeklyData: const [
        WeeklyData(day: 'Mon', value: 0.60),
        WeeklyData(day: 'Tue', value: 0.75),
        WeeklyData(day: 'Wed', value: 0.45),
        WeeklyData(day: 'Thu', value: 0.85),
        WeeklyData(day: 'Fri', value: 0.65),
        WeeklyData(day: 'Sat', value: 0.70),
        WeeklyData(day: 'Sun', value: 0.90),
      ],
      dailyLogs: const [
        DailyLog(label: 'Today',      note: 'Great session with word games, responded well', score: 9, emoji: '😊'),
        DailyLog(label: 'Yesterday',  note: 'Quiet day, preferred visual activities',         score: 6, emoji: '😐'),
        DailyLog(label: '2 Days Ago', note: 'Excellent focus on color matching',              score: 8, emoji: '😊'),
      ],
      selectedView: 'Parent',
    ));
  }

  void _onViewSwitched(ProgressViewSwitched event, Emitter<ProgressState> emit) {
    if (state is ProgressLoaded) {
      emit((state as ProgressLoaded).copyWith(selectedView: event.view));
    }
  }
}
