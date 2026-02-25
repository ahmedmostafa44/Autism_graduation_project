part of 'speak_bloc.dart';

abstract class SpeakEvent {}

class SpeakLoadRequested extends SpeakEvent {}

class SpeakCategorySelected extends SpeakEvent {
  final String category;
  SpeakCategorySelected(this.category);
}

class SpeakPhraseTriggered extends SpeakEvent {
  final String phraseId;
  SpeakPhraseTriggered(this.phraseId);
}

class SpeakFavoriteToggled extends SpeakEvent {
  final String phraseId;
  SpeakFavoriteToggled(this.phraseId);
}
