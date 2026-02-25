part of 'community_bloc.dart';

abstract class CommunityEvent {}

class CommunityLoadRequested extends CommunityEvent {}

class CommunityTabSelected extends CommunityEvent {
  final String tab;
  CommunityTabSelected(this.tab);
}

class CommunitySearchChanged extends CommunityEvent {
  final String query;
  CommunitySearchChanged(this.query);
}

class CommunityResourceLiked extends CommunityEvent {
  final String resourceId;
  CommunityResourceLiked(this.resourceId);
}
