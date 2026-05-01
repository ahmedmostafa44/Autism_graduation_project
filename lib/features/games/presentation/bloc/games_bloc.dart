import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/game_model.dart';

part 'games_event.dart';
part 'games_state.dart';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  GamesBloc() : super(GamesInitial()) {
    on<GamesLoadRequested>(_onLoad);
    on<GamesCategorySelected>(_onCategorySelected);
  }

  static const _allGames = [
    GameModel(
        id: '1',
        title: 'Emotion Match',
        category: 'Feelings',
        progress: 0.0,
        emoji: '😊'),
    GameModel(
        id: '2',
        title: 'Word Builder',
        category: 'Words',
        progress: 0.0,
        emoji: '📝'),
    GameModel(id: '4', title: 'Number Fun', category: 'Math', emoji: '🔢'),
    GameModel(
        id: '5',
        title: 'Color World',
        category: 'Colors',
        progress: 0.0,
        emoji: '🎨'),
    GameModel(
        id: '7',
        title: 'Sentence Builder',
        category: 'Words',
        progress: 0.0,
        emoji: '✏️'),
    GameModel(
        id: '9',
        title: 'Sequencing',
        category: 'Social',
        progress: 0.00,
        emoji: '📖'),
    GameModel(
        id: '10',
        title: 'Color Sorting',
        category: 'Colors',
        progress: 0.00,
        emoji: '🌈'),
  ];

  Future<void> _onLoad(
      GamesLoadRequested event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(GamesLoaded(games: _allGames, selectedCategory: 'All'));
  }

  void _onCategorySelected(
      GamesCategorySelected event, Emitter<GamesState> emit) {
    if (state is GamesLoaded) {
      final current = state as GamesLoaded;
      emit(GamesLoaded(games: current.games, selectedCategory: event.category));
    }
  }
}
