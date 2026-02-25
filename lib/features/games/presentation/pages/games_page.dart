import 'package:autism_app/core/utils/contansts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/games_bloc.dart';
import '../../data/models/game_model.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  static const _categories = ['All', 'Feelings', 'Words', 'Social', 'Math', 'Colors'];

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
                  const Text('Educational Games', style: AppTextStyles.heading2),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category filter
            BlocBuilder<GamesBloc, GamesState>(
              builder: (context, state) {
                final selected = state is GamesLoaded ? state.selectedCategory : 'All';
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
                        onTap: () =>
                            context.read<GamesBloc>().add(GamesCategorySelected(cat)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Games list
            Expanded(
              child: BlocBuilder<GamesBloc, GamesState>(
                builder: (context, state) {
                  if (state is GamesLoading || state is GamesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is GamesLoaded) {
                    final games = state.filteredGames;
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: games.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _GameCard(game: games[index]),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameModel game;
  const _GameCard({required this.game});

  Color get _bgColor {
    switch (game.category) {
      case 'Feelings': return AppColors.gamesCardBg;
      case 'Social':   return AppColors.speakCardBg;
      case 'Words':    return AppColors.subscriptionCardBg;
      default:         return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(game.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(game.title, style: AppTextStyles.heading3),
                    if (game.isLocked) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.lock, size: 14, color: AppColors.textSecondary),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(game.category, style: AppTextStyles.caption),
                if (game.progress != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: game.progress,
                      backgroundColor: AppColors.progressBg,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressBar),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (game.progress != null)
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.warning),
                const SizedBox(width: 3),
                Text('${(game.progress! * 100).toInt()}%',
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
        ],
      ),
    );
  }
}
