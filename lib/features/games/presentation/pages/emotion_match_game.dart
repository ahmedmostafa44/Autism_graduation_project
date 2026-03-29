import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';

// ─── Game State ─────────────────────────────────────────────────────────────

class _EmotionPair {
  final String emoji;
  final String label;
  final Color color;
  const _EmotionPair(this.emoji, this.label, this.color);
}

const _emotions = [
  _EmotionPair('😊', 'Happy',     Color(0xFF10B981)),
  _EmotionPair('😢', 'Sad',       Color(0xFF3B82F6)),
  _EmotionPair('😡', 'Angry',     Color(0xFFEF4444)),
  _EmotionPair('😨', 'Scared',    Color(0xFF8B5CF6)),
  _EmotionPair('😍', 'Loving',    Color(0xFFEC4899)),
  _EmotionPair('😴', 'Tired',     Color(0xFF6B7280)),
  _EmotionPair('🤩', 'Excited',   Color(0xFFF59E0B)),
  _EmotionPair('🤔', 'Confused',  Color(0xFFF97316)),
];

class _GameCard {
  final String id;
  final _EmotionPair emotion;
  final bool isEmoji; // true = shows emoji, false = shows label
  bool isFlipped;
  bool isMatched;

  _GameCard({
    required this.id,
    required this.emotion,
    required this.isEmoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

// ─── Page ────────────────────────────────────────────────────────────────────

class EmotionMatchGame extends StatefulWidget {
  const EmotionMatchGame({super.key});

  @override
  State<EmotionMatchGame> createState() => _EmotionMatchGameState();
}

class _EmotionMatchGameState extends State<EmotionMatchGame>
    with TickerProviderStateMixin {
  List<_GameCard> _cards = [];
  _GameCard? _firstFlipped;
  bool _checking = false;
  int _moves = 0;
  int _matches = 0;
  bool _gameWon = false;

  late final AnimationController _winController;
  late final Animation<double> _winScale;

  @override
  void initState() {
    super.initState();
    _winController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _winScale = CurvedAnimation(parent: _winController, curve: Curves.elasticOut);
    _initGame();
  }

  @override
  void dispose() {
    _winController.dispose();
    super.dispose();
  }

  void _initGame() {
    final rng = math.Random();
    // Pick 6 emotions for a 4×3 grid (12 cards = 6 pairs)
    final picked = List.of(_emotions)..shuffle(rng);
    final chosen = picked.take(6).toList();

    final cards = <_GameCard>[];
    for (final e in chosen) {
      cards.add(_GameCard(id: '${e.label}_emoji', emotion: e, isEmoji: true));
      cards.add(_GameCard(id: '${e.label}_label', emotion: e, isEmoji: false));
    }
    cards.shuffle(rng);

    setState(() {
      _cards = cards;
      _firstFlipped = null;
      _checking = false;
      _moves = 0;
      _matches = 0;
      _gameWon = false;
    });
  }

  Future<void> _onCardTap(_GameCard card) async {
    if (_checking || card.isFlipped || card.isMatched) return;

    setState(() => card.isFlipped = true);

    if (_firstFlipped == null) {
      _firstFlipped = card;
      return;
    }

    // Second card flipped
    _checking = true;
    setState(() => _moves++);

    await Future.delayed(const Duration(milliseconds: 700));

    final first = _firstFlipped!;
    final isMatch = first.emotion.label == card.emotion.label &&
        first.id != card.id;

    if (isMatch) {
      setState(() {
        first.isMatched = true;
        card.isMatched = true;
        _matches++;
        _firstFlipped = null;
        _checking = false;
      });
      if (_matches == _cards.length ~/ 2) {
        setState(() => _gameWon = true);
        _winController.forward(from: 0);
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        first.isFlipped = false;
        card.isFlipped = false;
        _firstFlipped = null;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: GalaxyColors.surface(isDark),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: GalaxyColors.border(isDark)),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 16, color: GalaxyColors.textPrimary(isDark)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Emotion Match 😊',
                            style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800,
                              color: GalaxyColors.textPrimary(isDark),
                              fontFamily: 'Nunito',
                            )),
                      ),
                      GestureDetector(
                        onTap: _initGame,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue
                            ]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.refresh_rounded,
                              size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Score bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _ScorePill(
                        label: 'Moves', value: '$_moves',
                        color: GalaxyColors.cosmicBlue, isDark: isDark),
                    const SizedBox(width: 12),
                    _ScorePill(
                        label: 'Matches',
                        value: '$_matches/${_cards.length ~/ 2}',
                        color: GalaxyColors.auroraGreen, isDark: isDark),
                    const Spacer(),
                    // Progress stars
                    ...List.generate(_cards.length ~/ 2, (i) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        i < _matches ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 18,
                        color: i < _matches
                            ? GalaxyColors.solarGold
                            : GalaxyColors.textSecond(isDark),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Card grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) =>
                        _CardTile(
                          card: _cards[index],
                          isDark: isDark,
                          onTap: () => _onCardTap(_cards[index]),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          // Win overlay
          if (_gameWon)
            GestureDetector(
              onTap: _initGame,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: ScaleTransition(
                    scale: _winScale,
                    child: GalaxyCard(
                      glowing: true,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 12),
                          Text('Amazing!',
                              style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900,
                                color: GalaxyColors.textPrimary(isDark),
                                fontFamily: 'Nunito',
                              )),
                          const SizedBox(height: 8),
                          Text('You matched all emotions\nin $_moves moves!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: GalaxyColors.textSecond(isDark),
                                fontFamily: 'Nunito',
                              )),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [GalaxyColors.nebulaPurple,
                                    GalaxyColors.cosmicBlue]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text('Play Again 🚀',
                                style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700,
                                  fontFamily: 'Nunito',
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final _GameCard card;
  final bool isDark;
  final VoidCallback onTap;

  const _CardTile({required this.card, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final show = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: show
              ? LinearGradient(
                  colors: [
                    card.emotion.color.withOpacity(isDark ? 0.6 : 0.3),
                    card.emotion.color.withOpacity(isDark ? 0.3 : 0.15),
                  ],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1A1250), const Color(0xFF0F0B30)]
                      : [const Color(0xFFEDE9FE), const Color(0xFFDBEAFF)],
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: show
                ? card.emotion.color.withOpacity(0.5)
                : GalaxyColors.border(isDark),
          ),
          boxShadow: (show && isDark) ? [
            BoxShadow(
              color: card.emotion.color.withOpacity(0.35),
              blurRadius: 12, spreadRadius: -4,
            ),
          ] : null,
        ),
        child: Center(
          child: show
              ? (card.isEmoji
                  ? Text(card.emotion.emoji,
                      style: const TextStyle(fontSize: 28))
                  : Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(card.emotion.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800,
                            color: card.emotion.color,
                            fontFamily: 'Nunito',
                          )),
                    ))
              : Icon(Icons.help_outline_rounded,
                  size: 22,
                  color: GalaxyColors.textSecond(isDark).withOpacity(0.4)),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;

  const _ScorePill(
      {required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: TextStyle(
                fontSize: 11, color: GalaxyColors.textSecond(isDark),
                fontFamily: 'Nunito',
              )),
          Text(value,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: color, fontFamily: 'Nunito',
              )),
        ],
      ),
    );
  }
}
