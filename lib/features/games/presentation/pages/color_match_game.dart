import 'dart:async';
import 'dart:math' as math;
import 'package:autism_app/core/services/game_result_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import 'package:autism_app/core/services/audio_service.dart';
import 'package:autism_app/core/widgets/game_guide_dialog.dart';

class _ColorEntry {
  final String name;
  final Color color;
  const _ColorEntry(this.name, this.color);
}

const _palette = [
  _ColorEntry('Red', Color(0xFFEF4444)),
  _ColorEntry('Blue', Color(0xFF3B82F6)),
  _ColorEntry('Green', Color(0xFF10B981)),
  _ColorEntry('Yellow', Color(0xFFFBBF24)),
  _ColorEntry('Purple', Color(0xFF8B5CF6)),
  _ColorEntry('Orange', Color(0xFFF97316)),
  _ColorEntry('Pink', Color(0xFFEC4899)),
  _ColorEntry('Teal', Color(0xFF14B8A6)),
];

class ColorMatchGame extends StatefulWidget {
  const ColorMatchGame({super.key});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame>
    with SingleTickerProviderStateMixin {
  final _rng = math.Random();

  late _ColorEntry _target; // the color name to match
  late _ColorEntry
      _nameColor; // the ink color of the word (could be different!)
  late List<_ColorEntry> _choices; // 4 choice buttons

  int _score = 0;
  int _lives = 3;
  int _timeLeft = 10;
  bool _gameOver = false;
  Timer? _timer;

  late final AnimationController _feedbackCtrl;
  bool? _lastCorrect;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _nextRound();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showGuide());
  }

  void _showGuide() {
    GameGuideDialog.show(
      context,
      title: 'Color Match',
      description: 'Tap the color block that matches the meaning of the word! Try not to be tricked by the ink color.',
      icon: '🎨',
      isDark: context.read<ThemeBloc>().state.isDark,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _nextRound() {
    _timer?.cancel();
    final shuffled = List.of(_palette)..shuffle(_rng);
    _target = shuffled[0];
    _nameColor = shuffled[1 % shuffled.length]; // misleading ink color
    _choices = shuffled.take(4).toList()..shuffle(_rng);

    setState(() {
      _timeLeft = 10;
      _lastCorrect = null;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _timer?.cancel();
        _onWrong();
      }
    });
  }

  void _onCorrect() {
    _timer?.cancel();
    AudioService.instance.playSuccessSound();
    setState(() {
      _score += _timeLeft * 2;
      _lastCorrect = true;
    });
    _feedbackCtrl.forward(from: 0).then((_) => _nextRound());
  }

  void _onWrong() {
    AudioService.instance.playFailureSound();
    setState(() {
      _lives--;
      _lastCorrect = false;
      if (_lives <= 0) {
        _gameOver = true;
        GameResultService.instance.save(
            gameId: 'color_match',
            gameName: 'Color Match',
            score: _score,
            maxScore: _score + 10,
            durationSeconds: 0,
            extras: {'rounds': 1});
      }
    });
    if (!_gameOver) {
      _feedbackCtrl.forward(from: 0).then((_) => _nextRound());
    }
  }

  void _tap(_ColorEntry choice) {
    if (_lastCorrect != null || _gameOver) return;
    if (choice.name == _target.name) {
      _onCorrect();
    } else {
      _onWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;

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
                      width: 36,
                      height: 36,
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
                    child: Text('Color Match 🎨',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: GalaxyColors.textPrimary(isDark),
                          fontFamily: 'Nunito',
                        )),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline_rounded),
                    color: GalaxyColors.textPrimary(isDark),
                    onPressed: _showGuide,
                  ),
                  // Lives
                  Row(
                    children: List.generate(
                        3,
                        (i) => Icon(
                              i < _lives
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: i < _lives
                                  ? GalaxyColors.supernovaRed
                                  : GalaxyColors.textSecond(isDark),
                              size: 22,
                            )),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _gameOver
                ? _GameOverScreen(
                    score: _score,
                    isDark: isDark,
                    onRestart: () {
                      setState(() {
                        _score = 0;
                        _lives = 3;
                        _gameOver = false;
                      });
                      _nextRound();
                    })
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Score + timer
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  GalaxyColors.solarGold,
                                  GalaxyColors.cometOrange
                                ]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('⭐ $_score',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Nunito',
                                  )),
                            ),
                            const Spacer(),
                            // Countdown ring
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: _timeLeft / 10,
                                    backgroundColor:
                                        GalaxyColors.border(isDark),
                                    valueColor: AlwaysStoppedAnimation(
                                      _timeLeft > 5
                                          ? GalaxyColors.auroraGreen
                                          : GalaxyColors.supernovaRed,
                                    ),
                                    strokeWidth: 4,
                                  ),
                                  Text('$_timeLeft',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: GalaxyColors.textPrimary(isDark),
                                        fontFamily: 'Nunito',
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Instruction
                        Text('Tap the COLOR, not the word!',
                            style: TextStyle(
                              fontSize: 13,
                              color: GalaxyColors.textSecond(isDark),
                              fontFamily: 'Nunito',
                            )),
                        const SizedBox(height: 16),

                        // The challenge word (shown in misleading color)
                        GalaxyCard(
                          padding: const EdgeInsets.symmetric(
                              vertical: 32, horizontal: 20),
                          child: Center(
                            child: Text(_target.name,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  // intentionally mismatch ink and target color
                                  color: _nameColor.color,
                                  fontFamily: 'Nunito',
                                )),
                          ),
                        ),

                        // Feedback flash
                        AnimatedBuilder(
                          animation: _feedbackCtrl,
                          builder: (_, __) {
                            if (_lastCorrect == null)
                              return const SizedBox(height: 16);
                            final opacity = 1 - _feedbackCtrl.value;
                            return Opacity(
                              opacity: opacity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  _lastCorrect!
                                      ? '✅ Correct! +${_timeLeft * 2}'
                                      : '❌ Wrong!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _lastCorrect!
                                        ? GalaxyColors.auroraGreen
                                        : GalaxyColors.supernovaRed,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        // Color buttons
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.4,
                          physics: const NeverScrollableScrollPhysics(),
                          children: _choices.map((c) {
                            return GestureDetector(
                              onTap: () => _tap(c),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: c.color,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isDark
                                      ? [
                                          BoxShadow(
                                            color: c.color.withOpacity(0.5),
                                            blurRadius: 12,
                                            spreadRadius: -4,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(c.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        fontFamily: 'Nunito',
                                        shadows: [
                                          Shadow(
                                              color: Colors.black26,
                                              blurRadius: 4)
                                        ],
                                      )),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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

class _GameOverScreen extends StatelessWidget {
  final int score;
  final bool isDark;
  final VoidCallback onRestart;

  const _GameOverScreen(
      {required this.score, required this.isDark, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GalaxyCard(
          glowing: true,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎮', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('Game Over!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: GalaxyColors.textPrimary(isDark),
                    fontFamily: 'Nunito',
                  )),
              const SizedBox(height: 8),
              Text('Your score: $score ⭐',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GalaxyColors.solarGold,
                    fontFamily: 'Nunito',
                  )),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onRestart,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      GalaxyColors.nebulaPurple,
                      GalaxyColors.cosmicBlue
                    ]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('Play Again 🚀',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Nunito',
                        fontSize: 15,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
