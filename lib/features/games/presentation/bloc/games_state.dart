part of 'games_bloc.dart';

abstract class GamesState {}

class GamesInitial extends GamesState {}

class GamesLoading extends GamesState {}

class GamesLoaded extends GamesState {
  final List<GameModel> games;
  final String selectedCategory;

  GamesLoaded({required this.games, required this.selectedCategory});

  List<GameModel> get filteredGames => selectedCategory == 'All'
      ? games
      : games.where((g) => g.category == selectedCategory).toList();
}

class GamesError extends GamesState {
  final String message;
  GamesError(this.message);
}
