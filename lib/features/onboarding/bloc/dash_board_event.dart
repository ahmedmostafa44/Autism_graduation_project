// lib/features/dashboard/bloc/dashboard_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the dashboard is first opened
class DashboardStarted extends DashboardEvent {}

/// Triggered to refresh data (e.g., Pull-to-refresh)
class DashboardRefreshRequested extends DashboardEvent {}

/// Triggered when a specific date range is selected for stats
class DashboardDateRangeChanged extends DashboardEvent {
  final DateTimeRange range;
  const DashboardDateRangeChanged(this.range);

  @override
  List<Object?> get props => [range];
}