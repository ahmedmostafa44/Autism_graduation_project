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
    GameModel(id: '1', title: 'Emotion Match',    category: 'Feelings', progress: 0.75, emoji: '😊'),
    GameModel(id: '2', title: 'Word Builder',     category: 'Words',    progress: 0.40, emoji: '📝'),
    GameModel(id: '3', title: 'Social Stories',   category: 'Social',   progress: 0.20, emoji: '🤝'),
    GameModel(id: '4', title: 'Number Fun',       category: 'Math',                     emoji: '🔢'),
    GameModel(id: '5', title: 'Color World',      category: 'Colors',   progress: 0.60, emoji: '🎨'),
    GameModel(id: '6', title: 'Feeling Faces',    category: 'Feelings', isLocked: true, emoji: '🎭'),
    GameModel(id: '7', title: 'Sentence Builder', category: 'Words',    progress: 0.15, emoji: '✏️'),
    GameModel(id: '8', title: 'Friends & Places', category: 'Social',   isLocked: true, emoji: '🏫'),
  ];

  Future<void> _onLoad(GamesLoadRequested event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(GamesLoaded(games: _allGames, selectedCategory: 'All'));
  }

  void _onCategorySelected(GamesCategorySelected event, Emitter<GamesState> emit) {
    if (state is GamesLoaded) {
      final current = state as GamesLoaded;
      emit(GamesLoaded(games: current.games, selectedCategory: event.category));
    }
  }
}
