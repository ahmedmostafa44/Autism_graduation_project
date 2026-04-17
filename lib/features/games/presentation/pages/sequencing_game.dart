import 'dart:math' as math;
import 'package:autism_app/core/services/game_result_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/services/audio_service.dart';
import 'package:autism_app/core/widgets/game_guide_dialog.dart';

// ── Story data ────────────────────────────────────────────────────────────────
class _StoryStep {
  final String emoji;
  final String label;
  const _StoryStep(this.emoji, this.label);
}

class _Story {
  final String title;
  final List<_StoryStep> steps;
  const _Story(this.title, this.steps);
}

const _stories = [
  _Story('Morning Routine 🌅', [
    _StoryStep('😴', 'Wake up'),
    _StoryStep('🦷', 'Brush teeth'),
    _StoryStep('👕', 'Get dressed'),
    _StoryStep('🥣', 'Eat breakfast'),
    _StoryStep('🎒', 'Pack bag'),
    _StoryStep('🚌', 'Go to school'),
  ]),
  _Story('Making a Sandwich 🥪', [
    _StoryStep('🍞', 'Get bread'),
    _StoryStep('🧈', 'Spread butter'),
    _StoryStep('🧀', 'Add cheese'),
    _StoryStep('🥬', 'Add lettuce'),
    _StoryStep('🍞', 'Top with bread'),
    _StoryStep('✂️', 'Cut in half'),
  ]),
  _Story('Planting a Seed 🌱', [
    _StoryStep('🪣', 'Get a pot'),
    _StoryStep('🪨', 'Add soil'),
    _StoryStep('🌰', 'Plant the seed'),
    _StoryStep('💧', 'Water the seed'),
    _StoryStep('☀️', 'Give it sunlight'),
    _StoryStep('🌱', 'Watch it grow'),
  ]),
  _Story('Washing Hands 🤲', [
    _StoryStep('🚿', 'Turn on water'),
    _StoryStep('🤲', 'Wet your hands'),
    _StoryStep('🧼', 'Apply soap'),
    _StoryStep('🫧', 'Scrub for 20s'),
    _StoryStep('💧', 'Rinse off soap'),
    _StoryStep('🧻', 'Dry your hands'),
  ]),
  _Story('Baking Cookies 🍪', [
    _StoryStep('📋', 'Read the recipe'),
    _StoryStep('🥚', 'Crack the eggs'),
    _StoryStep('🥄', 'Mix ingredients'),
    _StoryStep('🫙', 'Shape the dough'),
    _StoryStep('🔥', 'Bake in oven'),
    _StoryStep('🍪', 'Let them cool'),
  ]),
];

// ── Game widget ───────────────────────────────────────────────────────────────
class SequencingGame extends StatefulWidget {
  const SequencingGame({super.key});
  @override
  State<SequencingGame> createState() => _SequencingGameState();
}

class _SequencingGameState extends State<SequencingGame>
    with SingleTickerProviderStateMixin {
  final _rng   = math.Random();
  late _Story  _story = _stories[0];
  late List<_StoryStep> _shuffled;
  late List<_StoryStep?> _answer; // placed slots
  int  _score  = 0;
  int  _round  = 0;
  bool _showSuccess = false;
  bool _showError   = false;
  int? _wrongIdx;
  final _startTime = DateTime.now();
  int  _totalRounds = 0;

  late final AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _loadStory();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showGuide());
  }

  void _showGuide() {
    GameGuideDialog.show(
      context,
      title: 'Sequencing',
      description: 'Put the steps in the correct order to complete the story!',
      icon: '📖',
      isDark: context.read<ThemeBloc>().state.isDark,
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _loadStory() {
    final remaining = _stories.where((s) => s.title != _story.title).toList();
    if (remaining.isEmpty) {
      // All stories done, loop from full list
      _story = _stories[_rng.nextInt(_stories.length)];
    } else {
      _story = remaining[_rng.nextInt(remaining.length)];
    }
    _shuffled = List.of(_story.steps)..shuffle(_rng);
    setState(() {
      _answer       = List.filled(_story.steps.length, null);
      _showSuccess  = false;
      _showError    = false;
      _wrongIdx     = null;
      _totalRounds++;
    });
  }

  void _tapCard(_StoryStep step) {
    if (_showSuccess) return;
    // Find first empty slot
    final emptyIdx = _answer.indexWhere((s) => s == null);
    if (emptyIdx == -1) return;
    setState(() {
      _answer[emptyIdx] = step;
      _shuffled.remove(step);
    });
    if (_answer.every((s) => s != null)) _checkAnswer();
  }

  void _removeFromSlot(int idx) {
    if (_showSuccess || _answer[idx] == null) return;
    setState(() {
      _shuffled.add(_answer[idx]!);
      _answer[idx] = null;
      _showError = false;
      _wrongIdx  = null;
    });
  }

  void _checkAnswer() {
    bool correct = true;
    int? firstWrong;
    for (int i = 0; i < _answer.length; i++) {
      if (_answer[i]?.label != _story.steps[i].label) {
        correct = false;
        firstWrong ??= i;
      }
    }
    if (correct) {
      AudioService.instance.playSuccessSound();
      setState(() {
        _showSuccess = true;
        _score += 10;
        _round++;
      });
      _bounceCtrl.forward(from: 0);
    } else {
      AudioService.instance.playFailureSound();
      setState(() {
        _showError = true;
        _wrongIdx  = firstWrong;
      });
      // Return wrong items to tray after short delay
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          for (int i = 0; i < _answer.length; i++) {
            if (_answer[i]?.label != _story.steps[i].label) {
              _shuffled.add(_answer[i]!);
              _answer[i] = null;
            }
          }
          _showError = false;
          _wrongIdx  = null;
        });
      });
    }
  }

  Future<void> _finishGame() async {
    final secs = DateTime.now().difference(_startTime).inSeconds;
    await GameResultService.instance.save(
      gameId:          'sequencing',
      gameName:        'Sequencing',
      score:           _score,
      maxScore:        _totalRounds * 10,
      durationSeconds: secs,
      extras:          {'rounds': _round},
    );
    if (mounted) Navigator.pop(context);
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
            child: SafeArea(bottom: false, child: Row(children: [
              GestureDetector(
                onTap: _finishGame,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: GalaxyColors.surface(isDark),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GalaxyColors.border(isDark)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 16,
                      color: GalaxyColors.textPrimary(isDark)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sequencing 📖', style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800,
                    color: GalaxyColors.textPrimary(isDark), fontFamily: 'Nunito',
                  )),
                  Text(_story.title, style: TextStyle(
                    fontSize: 11, color: GalaxyColors.textSecond(isDark), fontFamily: 'Nunito',
                  )),
                ],
              )),
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
                      colors: [GalaxyColors.auroraGreen, GalaxyColors.cosmicBlue]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('$_score', style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito', fontSize: 13,
                  )),
                ]),
              ),
            ])),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Put the steps in the correct order!',
                    style: TextStyle(fontSize: 13, color: GalaxyColors.textSecond(isDark), fontFamily: 'Nunito'),
                  ),
                  const SizedBox(height: 14),

                  // Answer slots
                  Expanded(
                    flex: 5,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _story.steps.length,
                      itemBuilder: (context, i) {
                        final placed = _answer[i];
                        final isWrong = _showError && _wrongIdx == i;
                        return GestureDetector(
                          onTap: () => _removeFromSlot(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: placed != null
                                  ? (_showSuccess
                                      ? const LinearGradient(colors: [GalaxyColors.auroraGreen, GalaxyColors.cosmicBlue])
                                      : isWrong
                                          ? LinearGradient(colors: [GalaxyColors.supernovaRed, GalaxyColors.supernovaRed.withOpacity(0.7)])
                                          : const LinearGradient(colors: [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue]))
                                  : null,
                              color: placed == null ? GalaxyColors.surface2(isDark) : null,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: placed != null
                                    ? Colors.transparent
                                    : GalaxyColors.border(isDark),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                if (placed == null)
                                  Center(child: Text('${i + 1}', style: TextStyle(
                                    fontSize: 24, color: GalaxyColors.textSecond(isDark).withOpacity(0.3),
                                    fontWeight: FontWeight.w900, fontFamily: 'Nunito',
                                  ))),
                                if (placed != null)
                                  Center(child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(placed.emoji, style: const TextStyle(fontSize: 28)),
                                      const SizedBox(height: 3),
                                      Text(placed.label, textAlign: TextAlign.center, style: const TextStyle(
                                        fontSize: 10, color: Colors.white,
                                        fontWeight: FontWeight.w700, fontFamily: 'Nunito',
                                      )),
                                    ],
                                  )),
                                Positioned(top: 4, left: 4,
                                  child: Container(
                                    width: 18, height: 18,
                                    decoration: BoxDecoration(
                                      color: placed != null ? Colors.white24 : GalaxyColors.border(isDark),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(child: Text('${i + 1}', style: TextStyle(
                                      fontSize: 9, fontWeight: FontWeight.w900,
                                      color: placed != null ? Colors.white : GalaxyColors.textSecond(isDark),
                                      fontFamily: 'Nunito',
                                    ))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Success overlay or card tray
                  if (_showSuccess)
                    _SuccessBanner(score: _score, round: _round, isDark: isDark, onNext: _loadStory, onFinish: _finishGame)
                  else ...[
                    if (_showError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('Some steps are wrong! Try again 🔄', style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: GalaxyColors.supernovaRed, fontFamily: 'Nunito',
                        )),
                      ),
                    Text('Tap a card to place it:', style: TextStyle(
                      fontSize: 12, color: GalaxyColors.textSecond(isDark), fontFamily: 'Nunito',
                    )),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 3,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.1,
                        ),
                        itemCount: _shuffled.length,
                        itemBuilder: (context, i) {
                          final step = _shuffled[i];
                          return GestureDetector(
                            onTap: () => _tapCard(step),
                            child: Container(
                              decoration: BoxDecoration(
                                color: GalaxyColors.surface2(isDark),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: GalaxyColors.nebulaViolet.withOpacity(0.35)),
                                boxShadow: isDark ? [
                                  BoxShadow(color: GalaxyColors.nebulaViolet.withOpacity(0.15), blurRadius: 8)
                                ] : null,
                              ),
                              child: Center(child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(step.emoji, style: const TextStyle(fontSize: 26)),
                                  const SizedBox(height: 3),
                                  Text(step.label, textAlign: TextAlign.center, style: TextStyle(
                                    fontSize: 10, color: GalaxyColors.textPrimary(isDark),
                                    fontWeight: FontWeight.w600, fontFamily: 'Nunito',
                                  )),
                                ],
                              )),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final int score, round;
  final bool isDark;
  final VoidCallback onNext, onFinish;
  const _SuccessBanner({required this.score, required this.round,
      required this.isDark, required this.onNext, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [GalaxyColors.auroraGreen, GalaxyColors.cosmicBlue]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: GalaxyColors.auroraGreen.withOpacity(0.4), blurRadius: 20)],
      ),
      child: Column(children: [
        Row(children: [
          const Text('🎉', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Perfect Order! +10 ⭐', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Nunito',
            )),
            Text('Round $round complete  •  Score: $score', style: const TextStyle(
              fontSize: 12, color: Colors.white70, fontFamily: 'Nunito',
            )),
          ])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: onFinish,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('Finish 🏁', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Nunito',
                ))),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onNext,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('Next Story →', style: TextStyle(
                  color: GalaxyColors.auroraGreen, fontWeight: FontWeight.w800, fontFamily: 'Nunito',
                ))),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
