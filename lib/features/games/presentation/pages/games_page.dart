import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import '../bloc/games_bloc.dart';
import '../../data/models/game_model.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  static const _categories = [
    'All',
    'Feelings',
    'Words',
    'Social',
    'Math',
    'Colors'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          GalaxyAppBar(title: 'Educational Games'),
          const SizedBox(height: 4),
          // Category chips
          BlocBuilder<GamesBloc, GamesState>(
            builder: (context, state) {
              final selected =
                  state is GamesLoaded ? state.selectedCategory : 'All';
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
                      onTap: () => context
                          .read<GamesBloc>()
                          .add(GamesCategorySelected(cat)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(colors: [
                                  GalaxyColors.nebulaPurple,
                                  GalaxyColors.cosmicBlue,
                                ])
                              : null,
                          color:
                              isSelected ? null : GalaxyColors.surface(isDark),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : GalaxyColors.border(isDark),
                          ),
                          boxShadow: isSelected && isDark
                              ? [
                                  BoxShadow(
                                      color: GalaxyColors.nebulaPurple
                                          .withOpacity(0.4),
                                      blurRadius: 10)
                                ]
                              : null,
                        ),
                        child: Text(cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : GalaxyColors.textSecond(isDark),
                              fontFamily: 'Nunito',
                            )),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<GamesBloc, GamesState>(
              builder: (context, state) {
                if (state is GamesLoading || state is GamesInitial) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: GalaxyColors.nebulaViolet));
                }
                if (state is GamesLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.filteredGames.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _GameCard(
                        game: state.filteredGames[index], isDark: isDark),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Route mapping: gameId → router path
const _gameRoutes = {
  '1': '/games/emotion-match',
  '2': '/games/word-builder',
  '5': '/games/color-match',
  '4': '/games/number-fun',
  '9': '/games/sequencing',
  '10': '/games/color-sorting',
};

class _GameCard extends StatelessWidget {
  final GameModel game;
  final bool isDark;
  const _GameCard({required this.game, required this.isDark});

  static const _catGradients = {
    'Feelings': [Color(0xFF7C3AED), Color(0xFFEC4899)],
    'Words': [Color(0xFF2563EB), Color(0xFF7C3AED)],
    'Social': [Color(0xFF059669), Color(0xFF0EA5E9)],
    'Math': [Color(0xFFF97316), Color(0xFFEF4444)],
    'Colors': [Color(0xFFEC4899), Color(0xFFF97316)],
  };

  List<Color> get _gradient => (_catGradients[game.category] ??
          [GalaxyColors.nebulaViolet, GalaxyColors.cosmicBlue])
      .cast<Color>();

  bool get _hasRoute => _gameRoutes.containsKey(game.id) && !game.isLocked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hasRoute ? () => context.push(_gameRoutes[game.id]!) : null,
      child: GalaxyCard(
        padding: const EdgeInsets.all(16),
        glowing: game.progress != null && game.progress! > 0.7,
        child: Row(
          children: [
            // Icon
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: game.isLocked
                      ? [Colors.grey.shade600, Colors.grey.shade700]
                      : _gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: !game.isLocked
                    ? [
                        BoxShadow(
                          color:
                              _gradient.first.withOpacity(isDark ? 0.5 : 0.25),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(game.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(game.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: game.isLocked
                                ? GalaxyColors.textSecond(isDark)
                                : GalaxyColors.textPrimary(isDark),
                            fontFamily: 'Nunito',
                          )),
                      if (game.isLocked) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.lock_rounded,
                            size: 13, color: GalaxyColors.textSecond(isDark)),
                      ],
                      if (_hasRoute) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: GalaxyColors.auroraGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color:
                                    GalaxyColors.auroraGreen.withOpacity(0.3)),
                          ),
                          child: const Text('PLAY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: GalaxyColors.auroraGreen,
                                fontFamily: 'Nunito',
                              )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(game.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: GalaxyColors.textSecond(isDark),
                        fontFamily: 'Nunito',
                      )),
                  if (game.progress != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: game.progress,
                        backgroundColor: GalaxyColors.border(isDark),
                        valueColor: AlwaysStoppedAnimation(_gradient.first),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (game.progress != null) ...[
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(game.progress! * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _gradient.first,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  Icon(Icons.star_rounded,
                      size: 14, color: GalaxyColors.solarGold),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
