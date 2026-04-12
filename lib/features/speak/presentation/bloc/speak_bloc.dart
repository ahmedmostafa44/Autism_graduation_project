import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../data/models/phrase_model.dart';

part 'speak_event.dart';
part 'speak_state.dart';

class SpeakBloc extends Bloc<SpeakEvent, SpeakState> {
  final FlutterTts _tts = FlutterTts();

  SpeakBloc() : super(SpeakInitial()) {
    _initTts();
    on<SpeakLoadRequested>(_onLoad);
    on<SpeakCategorySelected>(_onCategorySelected);
    on<SpeakPhraseTriggered>(_onPhraseTriggered);
    on<SpeakFavoriteToggled>(_onFavoriteToggled);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5); // slowed down slightly for accessibility
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  static const _allPhrases = [
    PhraseModel(id: '1',  text: 'I am happy',     emoji: '😊', category: 'Feelings',  isFavorite: true),
    PhraseModel(id: '2',  text: 'I am sad',        emoji: '😢', category: 'Feelings'),
    PhraseModel(id: '3',  text: 'I need help',     emoji: '🙋', category: 'Feelings',  isFavorite: true),
    PhraseModel(id: '4',  text: 'I am hungry',     emoji: '🍕', category: 'Food'),
    PhraseModel(id: '5',  text: 'Thank you',       emoji: '🙏', category: 'Greetings', isFavorite: true),
    PhraseModel(id: '6',  text: 'I love you',      emoji: '❤️', category: 'Feelings',  isFavorite: true),
    PhraseModel(id: '7',  text: 'Good morning',    emoji: '🌅', category: 'Greetings'),
    PhraseModel(id: '8',  text: 'Goodbye',         emoji: '👋', category: 'Greetings'),
    PhraseModel(id: '9',  text: 'I want water',    emoji: '💧', category: 'Food'),
    PhraseModel(id: '10', text: 'I am tired',      emoji: '😴', category: 'Feelings'),
    PhraseModel(id: '11', text: 'I am home',       emoji: '🏠', category: 'Home'),
    PhraseModel(id: '12', text: 'I want to play',  emoji: '🎮', category: 'Home'),
  ];

  Future<void> _onLoad(SpeakLoadRequested event, Emitter<SpeakState> emit) async {
    await Future.delayed(const Duration(milliseconds: 200));
    emit(SpeakLoaded(phrases: _allPhrases, selectedCategory: 'Feelings'));
  }

  void _onCategorySelected(SpeakCategorySelected event, Emitter<SpeakState> emit) {
    if (state is SpeakLoaded) {
      emit((state as SpeakLoaded).copyWith(selectedCategory: event.category));
    }
  }

  Future<void> _onPhraseTriggered(SpeakPhraseTriggered event, Emitter<SpeakState> emit) async {
    if (state is SpeakLoaded) {
      final current = state as SpeakLoaded;
      
      // Cancel previous speech if any
      await _tts.stop();
      
      // Update UI to show speaking state for this phrase
      emit(current.copyWith(speakingPhraseId: event.phraseId));
      
      final phrase = current.phrases.firstWhere((p) => p.id == event.phraseId);
      
      // Speak and wait for completion
      await _tts.speak(phrase.text);
       
      // Clear speaking state only if the current phrase is still the one speaking
      if (state is SpeakLoaded && (state as SpeakLoaded).speakingPhraseId == event.phraseId) {
        emit((state as SpeakLoaded).copyWith(clearSpeaking: true));
      }
    }
  }

  void _onFavoriteToggled(SpeakFavoriteToggled event, Emitter<SpeakState> emit) {
    if (state is SpeakLoaded) {
      final current = state as SpeakLoaded;
      final updated = current.phrases.map((p) {
        return p.id == event.phraseId ? p.copyWith(isFavorite: !p.isFavorite) : p;
      }).toList();
      emit(current.copyWith(phrases: updated));
    }
  }
}
