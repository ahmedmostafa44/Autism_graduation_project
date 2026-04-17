import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/services/game_result_service.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import 'package:autism_app/core/services/audio_service.dart';
import 'package:autism_app/core/widgets/game_guide_dialog.dart';

const _objects = [
  ('⭐', 'Stars'),   ('🍎', 'Apples'),  ('🐸', 'Frogs'),
  ('🌸', 'Flowers'), ('🐶', 'Dogs'),    ('🎈', 'Balloons'),
  ('🍕', 'Pizza'),   ('🦋', 'Butterflies'),
];

class NumberFunGame extends StatefulWidget {
  const NumberFunGame({super.key});

  @override
  State<NumberFunGame> createState() => _NumberFunGameState();
}

class _NumberFunGameState extends State<NumberFunGame>
    with SingleTickerProviderStateMixin {
  final _rng = math.Random();

  late String _emoji;
  late String _label;
  late int _count;
  late List<int> _choices;

  int _score      = 0;
  int _streak     = 0;
  int _round      = 0;
  bool? _feedback; // null=none, true=correct, false=wrong

  late final AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _nextRound();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showGuide());
  }

  void _showGuide() {
    GameGuideDialog.show(
      context,
      title: 'Number Fun',
      description: 'Count the items on the screen and tap the correct number below!',
      icon: '🔢',
      isDark: context.read<ThemeBloc>().state.isDark,
    );
  }

  @override
  void dispose() {
    if (_score > 0) {
      GameResultService.instance.save(
        gameId: 'number_fun',
        gameName: 'Number Fun',
        score: _score,
        maxScore: _score,
        durationSeconds: 0,
      );
    }
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _nextRound() {
    final obj   = _objects[_rng.nextInt(_objects.length)];
    _emoji      = obj.$1;
    _label      = obj.$2;
    _count      = _rng.nextInt(9) + 1; // 1–9
    _choices    = _generateChoices(_count);

    setState(() {
      _feedback = null;
      _round++;
    });
  }

  List<int> _generateChoices(int correct) {
    final Set<int> choices = {correct};
    while (choices.length < 4) {
      int v = correct + _rng.nextInt(5) - 2;
      if (v < 1) v = correct + _rng.nextInt(3) + 1;
      choices.add(v);
    }
    return choices.toList()..shuffle(_rng);
  }

  void _answer(int choice) {
    if (_feedback != null) return;
    final correct = choice == _count;

    if (correct) {
      AudioService.instance.playSuccessSound();
    } else {
      AudioService.instance.playFailureSound();
    }

    setState(() {
      _feedback = correct;
      if (correct) {
        _streak++;
        _score += 5 + (_streak > 2 ? 5 : 0); // streak bonus
      } else {
        _streak = 0;
      }
    });
    _bounceCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 900), _nextRound);
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
                  Expanded(
                    child: Text('Number Fun 🔢',
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
                  // Streak badge
                  if (_streak >= 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          GalaxyColors.cometOrange, GalaxyColors.solarGold,
                        ]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('🔥 $_streak',
                          style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito', fontSize: 12,
                          )),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue,
                      ]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('⭐ $_score',
                        style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito', fontSize: 12,
                        )),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  // Round counter
                  Text('Round $_round',
                      style: TextStyle(
                        fontSize: 13,
                        color: GalaxyColors.textSecond(isDark),
                        fontFamily: 'Nunito',
                      )),
                  const SizedBox(height: 12),

                  // Question card
                  Expanded(
                    child: GalaxyCard(
                      glowing: _feedback == true,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('How many $_label?',
                              style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: GalaxyColors.textPrimary(isDark),
                                fontFamily: 'Nunito',
                              )),
                          const SizedBox(height: 16),
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _bounceCtrl,
                              builder: (_, __) {
                                return Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: List.generate(_count, (i) {
                                    // Staggered bounce on answer
                                    final delay = i / _count;
                                    final t = (_bounceCtrl.value - delay)
                                        .clamp(0.0, 1.0);
                                    final scale = _feedback != null
                                        ? (1 + math.sin(t * math.pi) * 0.3)
                                        : 1.0;
                                    return Transform.scale(
                                      scale: scale,
                                      child: Text(_emoji,
                                          style: TextStyle(
                                            fontSize: _count > 6 ? 28 : 38,
                                          )),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feedback
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _feedback == null
                        ? Text('Tap the correct number!',
                            key: const ValueKey('hint'),
                            style: TextStyle(
                              fontSize: 13,
                              color: GalaxyColors.textSecond(isDark),
                              fontFamily: 'Nunito',
                            ))
                        : Text(
                            _feedback!
                                ? (_streak >= 3
                                    ? '🔥 Amazing streak! +${5 + 5}'
                                    : '✅ Correct! +5')
                                : '❌ The answer was $_count',
                            key: ValueKey(_feedback),
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: _feedback!
                                  ? GalaxyColors.auroraGreen
                                  : GalaxyColors.supernovaRed,
                              fontFamily: 'Nunito',
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Answer choices
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _choices.map((n) {
                      Color? feedColor;
                      if (_feedback != null) {
                        if (n == _count) feedColor = GalaxyColors.auroraGreen;
                        else if (_feedback == false) feedColor = null;
                      }

                      return GestureDetector(
                        onTap: () => _answer(n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: feedColor != null
                                ? LinearGradient(
                                    colors: [feedColor, feedColor.withOpacity(0.7)])
                                : const LinearGradient(colors: [
                                    GalaxyColors.nebulaPurple,
                                    GalaxyColors.cosmicBlue,
                                  ]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isDark ? [
                              BoxShadow(
                                color: (feedColor ?? GalaxyColors.nebulaPurple)
                                    .withOpacity(0.45),
                                blurRadius: 12, spreadRadius: -4,
                              ),
                            ] : null,
                          ),
                          child: Center(
                            child: Text('$n',
                                style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.w900,
                                  color: Colors.white, fontFamily: 'Nunito',
                                )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
