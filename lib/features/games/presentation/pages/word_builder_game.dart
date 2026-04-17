import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/services/game_result_service.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import 'package:autism_app/core/services/audio_service.dart';
import 'package:autism_app/core/widgets/game_guide_dialog.dart';

class _WordChallenge {
  final String word;
  final String emoji;
  final String hint;
  const _WordChallenge(this.word, this.emoji, this.hint);
}

const _challenges = [
  _WordChallenge('CAT',    '🐱', 'A fluffy pet that meows'),
  _WordChallenge('DOG',    '🐶', 'A loyal furry friend'),
  _WordChallenge('SUN',    '☀️', 'It shines in the sky'),
  _WordChallenge('TREE',   '🌳', 'It has leaves and branches'),
  _WordChallenge('STAR',   '⭐', 'It twinkles at night'),
  _WordChallenge('BALL',   '⚽', 'You kick or throw it'),
  _WordChallenge('FISH',   '🐟', 'It swims in water'),
  _WordChallenge('BIRD',   '🐦', 'It can fly in the sky'),
];

class WordBuilderGame extends StatefulWidget {
  const WordBuilderGame({super.key});

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame>
    with SingleTickerProviderStateMixin {
  int _challengeIndex = 0;
  List<String> _placed = [];
  List<String> _available = [];
  bool _showSuccess = false;
  int _score = 0;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shake = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _loadChallenge();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showGuide());
  }

  void _showGuide() {
    GameGuideDialog.show(
      context,
      title: 'Word Builder',
      description: 'Tap the letters to spell the word that matches the picture and hint!',
      icon: '✏️',
      isDark: context.read<ThemeBloc>().state.isDark,
    );
  }

  @override
  void dispose() {
    if (_score > 0) {
      GameResultService.instance.save(
        gameId: 'word_builder',
        gameName: 'Word Builder',
        score: _score,
        maxScore: _score,
        durationSeconds: 0,
      );
    }
    _shakeCtrl.dispose();
    super.dispose();
  }

  _WordChallenge get _current => _challenges[_challengeIndex];

  void _loadChallenge() {
    final letters = _current.word.split('')..shuffle(math.Random());
    setState(() {
      _placed = [];
      _available = letters;
      _showSuccess = false;
    });
  }

  void _tapLetter(String letter, int index) {
    if (_placed.length >= _current.word.length) return;
    setState(() {
      _placed.add(letter);
      _available.removeAt(index);
    });
    _checkWord();
  }

  void _removeLetter(int index) {
    setState(() {
      _available.add(_placed[index]);
      _placed.removeAt(index);
    });
  }

  void _checkWord() {
    if (_placed.length != _current.word.length) return;
    final built = _placed.join();
    if (built == _current.word) {
      AudioService.instance.playSuccessSound();
      setState(() {
        _showSuccess = true;
        _score += 10;
      });
    } else if (_placed.length == _current.word.length) {
      AudioService.instance.playFailureSound();
      _shakeCtrl.forward(from: 0);
    }
  }

  void _nextChallenge() {
    setState(() {
      _challengeIndex = (_challengeIndex + 1) % _challenges.length;
    });
    _loadChallenge();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final challenge = _current;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                    child: Text('Word Builder ✏️',
                        style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800,
                          color: GalaxyColors.textPrimary(isDark),
                          fontFamily: 'Nunito',
                        )),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded),
                    color: GalaxyColors.textPrimary(isDark),
                    onPressed: _showGuide,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [GalaxyColors.solarGold, GalaxyColors.cometOrange]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('$_score',
                            style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800,
                              fontFamily: 'Nunito', fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_challenges.length, (i) =>
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _challengeIndex ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: i == _challengeIndex
                                ? const LinearGradient(colors: [
                                    GalaxyColors.nebulaPurple,
                                    GalaxyColors.cosmicBlue,
                                  ])
                                : null,
                            color: i != _challengeIndex
                                ? (i < _challengeIndex
                                    ? GalaxyColors.auroraGreen
                                    : GalaxyColors.border(isDark))
                                : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                  ),
                  const SizedBox(height: 24),

                  // Emoji + hint card
                  GalaxyCard(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    glowing: _showSuccess,
                    child: Column(
                      children: [
                        Text(challenge.emoji,
                            style: const TextStyle(fontSize: 72)),
                        const SizedBox(height: 12),
                        Text(challenge.hint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: GalaxyColors.textSecond(isDark),
                              fontFamily: 'Nunito',
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Answer slots
                  AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) {
                      final offset = math.sin(_shake.value * math.pi * 4) * 6;
                      return Transform.translate(
                        offset: Offset(offset, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(challenge.word.length, (i) {
                        final filled = i < _placed.length;
                        return GestureDetector(
                          onTap: filled ? () => _removeLetter(i) : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 52, height: 58,
                            decoration: BoxDecoration(
                              gradient: filled && _showSuccess
                                  ? const LinearGradient(colors: [
                                      GalaxyColors.auroraGreen,
                                      GalaxyColors.cosmicBlue,
                                    ])
                                  : (filled
                                      ? const LinearGradient(colors: [
                                          GalaxyColors.nebulaPurple,
                                          GalaxyColors.cosmicBlue,
                                        ])
                                      : null),
                              color: filled ? null : GalaxyColors.surface(isDark),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: filled
                                    ? Colors.transparent
                                    : GalaxyColors.border(isDark),
                                width: 2,
                              ),
                              boxShadow: filled && isDark ? [
                                BoxShadow(
                                  color: GalaxyColors.nebulaPurple.withOpacity(0.5),
                                  blurRadius: 12,
                                ),
                              ] : null,
                            ),
                            child: Center(
                              child: filled
                                  ? Text(_placed[i],
                                      style: const TextStyle(
                                        fontSize: 22, fontWeight: FontWeight.w900,
                                        color: Colors.white, fontFamily: 'Nunito',
                                      ))
                                  : Text('_',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: GalaxyColors.textSecond(isDark),
                                        fontFamily: 'Nunito',
                                      )),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const Spacer(),

                  // Letter tiles
                  if (!_showSuccess)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_available.length, (i) {
                        return GestureDetector(
                          onTap: () => _tapLetter(_available[i], i),
                          child: Container(
                            width: 54, height: 60,
                            decoration: BoxDecoration(
                              color: GalaxyColors.surface2(isDark),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: GalaxyColors.nebulaViolet.withOpacity(0.3)),
                              boxShadow: isDark ? [
                                BoxShadow(
                                  color: GalaxyColors.nebulaViolet.withOpacity(0.15),
                                  blurRadius: 8,
                                ),
                              ] : null,
                            ),
                            child: Center(
                              child: Text(_available[i],
                                  style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w900,
                                    color: GalaxyColors.textPrimary(isDark),
                                    fontFamily: 'Nunito',
                                  )),
                            ),
                          ),
                        );
                      }),
                    ),

                  // Success state
                  if (_showSuccess) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          GalaxyColors.auroraGreen,
                          GalaxyColors.cosmicBlue,
                        ]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: GalaxyColors.auroraGreen.withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Correct! +10 ⭐',
                                  style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w900,
                                    color: Colors.white, fontFamily: 'Nunito',
                                  )),
                              Text('You spelled ${challenge.word}!',
                                  style: const TextStyle(
                                    fontSize: 13, color: Colors.white70,
                                    fontFamily: 'Nunito',
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _nextChallenge,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue,
                          ]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Next Word →',
                              style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w800,
                                fontFamily: 'Nunito', fontSize: 15,
                              )),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
