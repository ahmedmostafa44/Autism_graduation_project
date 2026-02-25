part of 'speak_bloc.dart';

abstract class SpeakState {}

class SpeakInitial extends SpeakState {}

class SpeakLoaded extends SpeakState {
  final List<PhraseModel> phrases;
  final String selectedCategory;
  final String? speakingPhraseId;

  SpeakLoaded({
    required this.phrases,
    required this.selectedCategory,
    this.speakingPhraseId,
  });

  List<PhraseModel> get filteredPhrases => selectedCategory == 'All'
      ? phrases
      : phrases.where((p) => p.category == selectedCategory).toList();

  SpeakLoaded copyWith({
    List<PhraseModel>? phrases,
    String? selectedCategory,
    String? speakingPhraseId,
    bool clearSpeaking = false,
  }) =>
      SpeakLoaded(
        phrases: phrases ?? this.phrases,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        speakingPhraseId: clearSpeaking ? null : (speakingPhraseId ?? this.speakingPhraseId),
      );
}
