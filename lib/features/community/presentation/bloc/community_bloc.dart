import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/resource_model.dart';

part 'community_event.dart';
part 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc() : super(CommunityInitial()) {
    on<CommunityLoadRequested>(_onLoad);
    on<CommunityTabSelected>(_onTabSelected);
    on<CommunitySearchChanged>(_onSearchChanged);
    on<CommunityResourceLiked>(_onResourceLiked);
  }

  static const _resources = [
    ResourceModel(id: '1', title: 'Understanding Sensory Processing', author: 'Dr. Smith',    tag: 'Sensory',       type: ResourceType.article),
    ResourceModel(id: '2', title: 'Visual Schedule Templates',        author: 'Therapy Hub',  tag: 'Visual Aids',   type: ResourceType.document),
    ResourceModel(id: '3', title: 'Social Stories Collection',        author: 'Dr. Johnson',  tag: 'Social Skills', type: ResourceType.guide),
    ResourceModel(id: '4', title: 'Communication Board Printables',   author: 'AAC Center',   tag: 'Communication', type: ResourceType.resource),
    ResourceModel(id: '5', title: 'Daily Routine Strategies',         author: 'Therapy Hub',  tag: 'Routines',      type: ResourceType.article),
    ResourceModel(id: '6', title: 'Emotion Regulation Guide',         author: 'Dr. Lee',      tag: 'Feelings',      type: ResourceType.guide),
  ];

  Future<void> _onLoad(CommunityLoadRequested event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(CommunityLoaded(resources: _resources, selectedTab: 'Resources'));
  }

  void _onTabSelected(CommunityTabSelected event, Emitter<CommunityState> emit) {
    if (state is CommunityLoaded) {
      emit((state as CommunityLoaded).copyWith(selectedTab: event.tab));
    }
  }

  void _onSearchChanged(CommunitySearchChanged event, Emitter<CommunityState> emit) {
    if (state is CommunityLoaded) {
      emit((state as CommunityLoaded).copyWith(searchQuery: event.query));
    }
  }

  void _onResourceLiked(CommunityResourceLiked event, Emitter<CommunityState> emit) {
    if (state is CommunityLoaded) {
      final current = state as CommunityLoaded;
      final updated = current.resources.map((r) {
        return r.id == event.resourceId ? r.copyWith(isLiked: !r.isLiked) : r;
      }).toList();
      emit(current.copyWith(resources: updated));
    }
  }
}
