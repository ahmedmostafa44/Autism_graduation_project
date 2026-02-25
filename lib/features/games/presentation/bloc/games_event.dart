part of 'games_bloc.dart';

abstract class GamesEvent {}

class GamesLoadRequested extends GamesEvent {}

class GamesCategorySelected extends GamesEvent {
  final String category;
  GamesCategorySelected(this.category);
}
