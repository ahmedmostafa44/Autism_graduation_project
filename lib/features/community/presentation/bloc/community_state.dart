part of 'community_bloc.dart';

abstract class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<ResourceModel> resources;
  final String selectedTab;
  final String searchQuery;

  CommunityLoaded({
    required this.resources,
    required this.selectedTab,
    this.searchQuery = '',
  });

  List<ResourceModel> get filteredResources {
    if (searchQuery.isEmpty) return resources;
    return resources
        .where((r) => r.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  CommunityLoaded copyWith({
    List<ResourceModel>? resources,
    String? selectedTab,
    String? searchQuery,
  }) =>
      CommunityLoaded(
        resources: resources ?? this.resources,
        selectedTab: selectedTab ?? this.selectedTab,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

class CommunityError extends CommunityState {
  final String message;
  CommunityError(this.message);
}
