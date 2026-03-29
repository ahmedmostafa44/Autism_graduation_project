part of 'progress_bloc.dart';

abstract class ProgressEvent {}

class ProgressLoadRequested extends ProgressEvent {}

class ProgressViewSwitched extends ProgressEvent {
  final String view; // 'Parent' or 'Doctor'
  ProgressViewSwitched(this.view);
}

class ProgressTabSwitched extends ProgressEvent {
  final String tab; // 'overview' | 'games' | 'logs'
  ProgressTabSwitched(this.tab);
}

class ProgressGameFilterChanged extends ProgressEvent {
  final String? gameId; // null = all games
  ProgressGameFilterChanged(this.gameId);
}
