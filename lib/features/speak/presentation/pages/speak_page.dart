import 'package:autism_app/core/utils/contansts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/speak_bloc.dart';

class SpeakPage extends StatelessWidget {
  const SpeakPage({super.key});

  static const _categories = ['Feelings', 'Greetings', 'Home', 'Food'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border)),
                      child: const Icon(Icons.arrow_back, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('Text to Speech', style: AppTextStyles.heading2),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tap to Speak button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                    color: AppColors.gamesCardBg, borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up, color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Text('Tap to Speak',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category chips
            BlocBuilder<SpeakBloc, SpeakState>(
              builder: (context, state) {
                final selected =
                    state is SpeakLoaded ? state.selectedCategory : 'Feelings';
                return SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == selected;
                      return GestureDetector(
                        // Dispatch event instead of calling cubit method
                        onTap: () =>
                            context.read<SpeakBloc>().add(SpeakCategorySelected(cat)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_categoryEmoji(cat),
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(cat,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
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
            const SizedBox(height: 16),

            // Phrases grid
            Expanded(
              child: BlocBuilder<SpeakBloc, SpeakState>(
                builder: (context, state) {
                  if (state is! SpeakLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final phrases = state.filteredPhrases;
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1),
                    itemCount: phrases.length,
                    itemBuilder: (context, index) {
                      final phrase = phrases[index];
                      final isSpeaking = state.speakingPhraseId == phrase.id;
                      return _PhraseCard(
                        emoji: phrase.emoji,
                        text: phrase.text,
                        isFavorite: phrase.isFavorite,
                        isSpeaking: isSpeaking,
                        // Dispatch events
                        onTap: () => context
                            .read<SpeakBloc>()
                            .add(SpeakPhraseTriggered(phrase.id)),
                        onFavorite: () => context
                            .read<SpeakBloc>()
                            .add(SpeakFavoriteToggled(phrase.id)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryEmoji(String cat) {
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
  final String emoji;
  final String text;
  final bool isFavorite;
  final bool isSpeaking;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _PhraseCard({
    required this.emoji,
    required this.text,
    required this.isFavorite,
    required this.isSpeaking,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSpeaking ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSpeaking ? AppColors.primary : AppColors.border,
              width: isSpeaking ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(text,
                style: AppTextStyles.heading3.copyWith(fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                  size: 16,
                  color: isSpeaking ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isFavorite ? AppColors.error : AppColors.textSecondary,
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
