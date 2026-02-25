part of 'progress_bloc.dart';

abstract class ProgressEvent {}

class ProgressLoadRequested extends ProgressEvent {}

class ProgressViewSwitched extends ProgressEvent {
  final String view; // 'Parent' or 'Doctor'
  ProgressViewSwitched(this.view);
}
