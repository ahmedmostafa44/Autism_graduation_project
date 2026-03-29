import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import '../bloc/speak_bloc.dart';

class SpeakPage extends StatelessWidget {
  const SpeakPage({super.key});

  static const _categories = ['Feelings', 'Greetings', 'Home', 'Food'];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          GalaxyAppBar(title: 'Text to Speech'),
          const SizedBox(height: 8),
          // Tap to Speak banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: isDark ? [
                  BoxShadow(
                      color: GalaxyColors.nebulaPurple.withOpacity(0.5),
                      blurRadius: 20, spreadRadius: -4),
                ] : null,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('Tap to Speak',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: Colors.white, fontFamily: 'Nunito')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Category tabs
          BlocBuilder<SpeakBloc, SpeakState>(
            builder: (context, state) {
              final selected = state is SpeakLoaded ? state.selectedCategory : 'Feelings';
              return SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == selected;
                    return GestureDetector(
                      onTap: () =>
                          context.read<SpeakBloc>().add(SpeakCategorySelected(cat)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue])
                              : null,
                          color: isSelected ? null : GalaxyColors.surface(isDark),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : GalaxyColors.border(isDark)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_emoji(cat), style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : GalaxyColors.textSecond(isDark),
                                  fontFamily: 'Nunito',
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<SpeakBloc, SpeakState>(
              builder: (context, state) {
                if (state is! SpeakLoaded) {
                  return Center(
                      child: CircularProgressIndicator(color: GalaxyColors.nebulaViolet));
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12,
                    mainAxisSpacing: 12, childAspectRatio: 1.05,
                  ),
                  itemCount: state.filteredPhrases.length,
                  itemBuilder: (context, index) {
                    final phrase = state.filteredPhrases[index];
                    final isSpeaking = state.speakingPhraseId == phrase.id;
                    return _PhraseCard(
                      emoji: phrase.emoji,
                      text: phrase.text,
                      isFavorite: phrase.isFavorite,
                      isSpeaking: isSpeaking,
                      isDark: isDark,
                      onTap: () =>
                          context.read<SpeakBloc>().add(SpeakPhraseTriggered(phrase.id)),
                      onFavorite: () =>
                          context.read<SpeakBloc>().add(SpeakFavoriteToggled(phrase.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _emoji(String cat) {
    switch (cat) {
      case 'Feelings':  return '😊';
      case 'Greetings': return '⭐';
      case 'Home':      return '🏠';
      case 'Food':      return '🍴';
      default:          return '';
    }
  }
}

class _PhraseCard extends StatelessWidget {
  final String emoji, text;
  final bool isFavorite, isSpeaking, isDark;
  final VoidCallback onTap, onFavorite;

  const _PhraseCard({
    required this.emoji, required this.text, required this.isFavorite,
    required this.isSpeaking, required this.isDark,
    required this.onTap, required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSpeaking
              ? const LinearGradient(
                  colors: [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                )
              : null,
          color: isSpeaking ? null : GalaxyColors.surface(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSpeaking
                ? Colors.transparent
                : GalaxyColors.border(isDark),
            width: isSpeaking ? 0 : 1,
          ),
          boxShadow: isSpeaking && isDark ? [
            BoxShadow(
              color: GalaxyColors.nebulaPurple.withOpacity(0.6),
              blurRadius: 20, spreadRadius: -4,
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(text,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: isSpeaking ? Colors.white : GalaxyColors.textPrimary(isDark),
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                  size: 16,
                  color: isSpeaking ? Colors.white : GalaxyColors.textSecond(isDark),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 16,
                    color: isFavorite
                        ? GalaxyColors.stardustPink
                        : (isSpeaking ? Colors.white70 : GalaxyColors.textSecond(isDark)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
