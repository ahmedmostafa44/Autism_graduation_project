// lib/features/dashboard/bloc/dashboard_bloc.dart
import 'package:autism_app/features/onboarding/bloc/dash_board_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      
      final mockStats = [
        {"title": "Revenue", "value": "\$45,231", "trend": "+12%"},
        {"title": "Users", "value": "2,405", "trend": "+5%"},
      ];
      
      emit(DashboardLoaded(mockStats, ["User A logged in", "New sale: \$50"]));
    });
  }
}