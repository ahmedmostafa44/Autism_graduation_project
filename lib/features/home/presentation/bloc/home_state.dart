part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String parentName;
  final String todayTip;
  final bool hasNotification;
  final bool isOfflineReady;

  HomeLoaded({
    required this.parentName,
    required this.todayTip,
    required this.hasNotification,
    required this.isOfflineReady,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
