import 'dart:math' as math;
import 'package:autism_app/core/services/game_result_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import 'package:autism_app/core/services/audio_service.dart';
import 'package:autism_app/core/widgets/game_guide_dialog.dart';

// ── Data ──────────────────────────────────────────────────────────────────────
class _ColorGroup {
  final String name;
  final Color color;
  final String emoji;
  final List<String> items;
  const _ColorGroup({
    required this.name, required this.color,
    required this.emoji, required this.items,
  });
}

const _groups = [
  _ColorGroup(name: 'Red',    color: Color(0xFFEF4444), emoji: '🔴',
    items: ['🍎', '🍓', '🌹', '❤️', '🌶️']),
  _ColorGroup(name: 'Blue',   color: Color(0xFF3B82F6), emoji: '🔵',
    items: ['💙', '🫐', '🐋', '🌊', '💎']),
  _ColorGroup(name: 'Yellow', color: Color(0xFFFBBF24), emoji: '🟡',
    items: ['⭐', '🌻', '🍋', '🌟', '🏆']),
  _ColorGroup(name: 'Green',  color: Color(0xFF10B981), emoji: '🟢',
    items: ['🍀', '🌿', '🥦', '🐢', '🌲']),
  _ColorGroup(name: 'Purple', color: Color(0xFF8B5CF6), emoji: '🟣',
    items: ['🍇', '🔮', '💜', '🦄', '🪀']),
  _ColorGroup(name: 'Orange', color: Color(0xFFF97316), emoji: '🟠',
    items: ['🍊', '🥕', '🎃', '🦊', '🌅']),
];

class _FallingItem {
  final String emoji;
  final _ColorGroup group;
  final String id;
  _FallingItem({required this.emoji, required this.group, required this.id});
}

// ── Game ──────────────────────────────────────────────────────────────────────
class ColorSortingGame extends StatefulWidget {
  const ColorSortingGame({super.key});
  @override
  State<ColorSortingGame> createState() => _ColorSortingGameState();
}

class _ColorSortingGameState extends State<ColorSortingGame>
    with TickerProviderStateMixin {
  final _rng = math.Random();

  // Active buckets (3 random color groups per round)
  late List<_ColorGroup> _buckets;
  // Items waiting to be sorted
  late List<_FallingItem> _queue;
  // Current draggable item (top of queue)
  _FallingItem? _current;

  int _score       = 0;
  int _correct     = 0;
  int _wrong       = 0;
  int _round       = 0;
  bool _showResult = false;
  bool? _lastCorrect;

  late final AnimationController _feedbackCtrl;
  late final AnimationController _itemEnterCtrl;
  final _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _itemEnterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _startRound();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showGuide());
  }

  void _showGuide() {
    GameGuideDialog.show(
      context,
      title: 'Color Sorting',
      description: 'Sort the items by dropping them onto the matching color bucket!',
      icon: '🌈',
      isDark: context.read<ThemeBloc>().state.isDark,
    );
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    _itemEnterCtrl.dispose();
    super.dispose();
  }

  void _startRound() {
    // Pick 3 random color groups
    final shuffledGroups = List.of(_groups)..shuffle(_rng);
    _buckets = shuffledGroups.take(3).toList();

    // Build a queue of 9 items (3 per bucket, shuffled)
    final items = <_FallingItem>[];
    for (final g in _buckets) {
      final picked = List.of(g.items)..shuffle(_rng);
      for (int i = 0; i < 3; i++) {
        items.add(_FallingItem(
          emoji: picked[i],
          group: g,
          id:    '${g.name}_$i',
        ));
      }
    }
    items.shuffle(_rng);

    setState(() {
      _queue       = items;
      _current     = items.isNotEmpty ? items.first : null;
      _showResult  = false;
      _lastCorrect = null;
      _round++;
    });
    _itemEnterCtrl.forward(from: 0);
  }

  void _drop(_ColorGroup bucket) {
    if (_current == null || _lastCorrect != null) return;
    final correct = _current!.group.name == bucket.name;

    if (correct) {
      AudioService.instance.playSuccessSound();
    } else {
      AudioService.instance.playFailureSound();
    }

    setState(() {
      _lastCorrect = correct;
      if (correct) {
        _score   += 5;
        _correct++;
      } else {
        _wrong++;
      }
    });

    _feedbackCtrl.forward(from: 0).then((_) {
      if (!mounted) return;
      // Advance queue
      setState(() {
        _queue.removeAt(0);
        _lastCorrect = null;
        if (_queue.isEmpty) {
          _showResult = true;
        } else {
          _current = _queue.first;
          _itemEnterCtrl.forward(from: 0);
        }
      });
    });
  }

  Future<void> _endGame() async {
    final secs  = DateTime.now().difference(_startTime).inSeconds;
    final total = _correct + _wrong;
    await GameResultService.instance.save(
      gameId:          'color_sorting',
      gameName:        'Color Sorting',
      score:           _score,
      maxScore:        total * 5,
      durationSeconds: secs,
      extras:          {'correct': _correct, 'wrong': _wrong},
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: SafeArea(bottom: false, child: Row(children: [
            GestureDetector(
              onTap: _endGame,
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
            Expanded(child: Text('Color Sorting 🌈', style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800,
              color: GalaxyColors.textPrimary(isDark), fontFamily: 'Nunito',
            ))),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded),
              color: GalaxyColors.textPrimary(isDark),
              onPressed: _showGuide,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            // Stats
            Row(children: [
              _MiniStat(icon: '✅', value: '$_correct', color: GalaxyColors.auroraGreen),
              const SizedBox(width: 8),
              _MiniStat(icon: '❌', value: '$_wrong', color: GalaxyColors.supernovaRed),
              const SizedBox(width: 8),
              _MiniStat(icon: '⭐', value: '$_score', color: GalaxyColors.solarGold),
            ]),
          ])),
        ),

        Expanded(
          child: _showResult
              ? _ResultScreen(
                  correct: _correct, wrong: _wrong, score: _score,
                  isDark: isDark,
                  onPlayAgain: () { setState(() { _correct = 0; _wrong = 0; _score = 0; }); _startRound(); },
                  onFinish: _endGame,
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(children: [
                    // Progress
                    Row(children: [
                      Text('${_queue.length} items left', style: TextStyle(
                        fontSize: 12, color: GalaxyColors.textSecond(isDark), fontFamily: 'Nunito',
                      )),
                      const Spacer(),
                      Text('Round $_round', style: TextStyle(
                        fontSize: 12, color: GalaxyColors.textSecond(isDark), fontFamily: 'Nunito',
                      )),
                    ]),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _queue.isEmpty ? 0 : 1 - (_queue.length / 9),
                        backgroundColor: GalaxyColors.border(isDark),
                        valueColor: const AlwaysStoppedAnimation(GalaxyColors.auroraGreen),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current item to sort
                    _CurrentItem(
                      item: _current,
                      lastCorrect: _lastCorrect,
                      enterCtrl: _itemEnterCtrl,
                      feedbackCtrl: _feedbackCtrl,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 8),
                    Text('Drop it in the matching bucket!', style: TextStyle(
                      fontSize: 12, color: GalaxyColors.textSecond(isDark), fontFamily: 'Nunito',
                    )),
                    const SizedBox(height: 16),

                    // Buckets
                    Expanded(
                      child: Row(
                        children: _buckets.map((bucket) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: _Bucket(
                                group: bucket,
                                isDark: isDark,
                                onDrop: () => _drop(bucket),
                                isActive: _lastCorrect == null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ]),
                ),
        ),
      ]),
    );
  }
}

// ── Current item card ─────────────────────────────────────────────────────────
class _CurrentItem extends StatelessWidget {
  final _FallingItem? item;
  final bool? lastCorrect;
  final AnimationController enterCtrl, feedbackCtrl;
  final bool isDark;
  const _CurrentItem({
    required this.item, required this.lastCorrect,
    required this.enterCtrl, required this.feedbackCtrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (item == null) return const SizedBox(height: 120);

    return ScaleTransition(
      scale: Tween(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: enterCtrl, curve: Curves.elasticOut)),
      child: AnimatedBuilder(
        animation: feedbackCtrl,
        builder: (_, child) {
          Color? border;
          if (lastCorrect == true)  border = GalaxyColors.auroraGreen;
          if (lastCorrect == false) border = GalaxyColors.supernovaRed;
          return Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: GalaxyColors.surface2(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: border ?? GalaxyColors.nebulaViolet.withOpacity(0.4),
                width: border != null ? 3 : 2,
              ),
              boxShadow: isDark ? [
                BoxShadow(
                  color: (border ?? GalaxyColors.nebulaViolet).withOpacity(0.35),
                  blurRadius: 20, spreadRadius: -4,
                ),
              ] : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(item!.emoji, style: const TextStyle(fontSize: 52)),
                if (lastCorrect != null)
                  Positioned(
                    bottom: 6, right: 6,
                    child: FadeTransition(
                      opacity: Tween(begin: 1.0, end: 0.0).animate(feedbackCtrl),
                      child: Text(
                        lastCorrect! ? '✅' : '❌',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Bucket ────────────────────────────────────────────────────────────────────
class _Bucket extends StatefulWidget {
  final _ColorGroup group;
  final bool isDark, isActive;
  final VoidCallback onDrop;
  const _Bucket({required this.group, required this.isDark,
      required this.onDrop, required this.isActive});
  @override
  State<_Bucket> createState() => _BucketState();
}

class _BucketState extends State<_Bucket> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isActive ? widget.onDrop : null,
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: widget.group.color.withOpacity(_hovered ? 0.35 : 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.group.color.withOpacity(_hovered ? 0.9 : 0.5),
            width: _hovered ? 3 : 2,
          ),
          boxShadow: _hovered ? [
            BoxShadow(color: widget.group.color.withOpacity(0.5), blurRadius: 16),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.group.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.group.color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(widget.group.name, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800,
                color: widget.group.color, fontFamily: 'Nunito',
              )),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _hovered ? widget.group.color : widget.group.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _hovered ? 'DROP!' : 'Tap',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'Nunito',
                  color: _hovered ? Colors.white : widget.group.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result Screen ─────────────────────────────────────────────────────────────
class _ResultScreen extends StatelessWidget {
  final int correct, wrong, score;
  final bool isDark;
  final VoidCallback onPlayAgain, onFinish;
  const _ResultScreen({
    required this.correct, required this.wrong, required this.score,
    required this.isDark, required this.onPlayAgain, required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final total    = correct + wrong;
    final accuracy = total > 0 ? (correct / total * 100).round() : 0;
    final emoji    = accuracy >= 90 ? '🏆' : accuracy >= 70 ? '🌟' : accuracy >= 50 ? '😊' : '💪';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GalaxyCard(
          glowing: true,
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(accuracy >= 90 ? 'Amazing!' : accuracy >= 70 ? 'Great Job!' : 'Keep Going!',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                  color: GalaxyColors.textPrimary(isDark), fontFamily: 'Nunito'),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _ResultStat('✅', '$correct', 'Correct', GalaxyColors.auroraGreen),
              _ResultStat('❌', '$wrong',   'Wrong',   GalaxyColors.supernovaRed),
              _ResultStat('⭐', '$score',   'Score',   GalaxyColors.solarGold),
            ]),
            const SizedBox(height: 20),
            // Accuracy bar
            Row(children: [
              Text('Accuracy: $accuracy%', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: GalaxyColors.textPrimary(isDark), fontFamily: 'Nunito',
              )),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: accuracy / 100,
                backgroundColor: GalaxyColors.border(isDark),
                valueColor: AlwaysStoppedAnimation(
                  accuracy >= 70 ? GalaxyColors.auroraGreen : GalaxyColors.solarGold),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: onFinish,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: GalaxyColors.surface2(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: GalaxyColors.border(isDark)),
                    ),
                    child: Center(child: Text('Finish 🏁', style: TextStyle(
                      color: GalaxyColors.textPrimary(isDark),
                      fontWeight: FontWeight.w700, fontFamily: 'Nunito',
                    ))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onPlayAgain,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [GalaxyColors.auroraGreen, GalaxyColors.cosmicBlue]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: GalaxyColors.auroraGreen.withOpacity(0.4), blurRadius: 12),
                      ],
                    ),
                    child: const Center(child: Text('Play Again 🚀', style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontFamily: 'Nunito',
                    ))),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String icon, value, label;
  final Color color;
  const _ResultStat(this.icon, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 24)),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color, fontFamily: 'Nunito')),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Nunito')),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String icon, value;
  final Color color;
  const _MiniStat({required this.icon, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 2),
      Text(value, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w800, color: color, fontFamily: 'Nunito',
      )),
    ]);
  }
}
