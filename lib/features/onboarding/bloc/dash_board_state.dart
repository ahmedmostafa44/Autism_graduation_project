// lib/features/dashboard/bloc/dashboard_state.dart
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final List<Map<String, dynamic>> stats;
  final List<String> activities;
  DashboardLoaded(this.stats, this.activities);
}

// lib/features/dashboard/bloc/dashboard_event.dart
abstract class DashboardEvent {}
class LoadDashboardData extends DashboardEvent {}