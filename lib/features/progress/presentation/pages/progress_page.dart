import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import '../bloc/progress_bloc.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<ProgressBloc, ProgressState>(
        builder: (context, state) {
          if (state is ProgressLoading || state is ProgressInitial) {
            return Center(
                child: CircularProgressIndicator(
                    color: GalaxyColors.nebulaViolet));
          }
          if (state is ProgressLoaded) {
            return Column(
              children: [
                GalaxyAppBar(title: 'Track Progress'),
                // Parent Dashboard button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: GestureDetector(
                    onTap: () => context.push('/parent-dashboard'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          GalaxyColors.nebulaPurple.withOpacity(0.15),
                          GalaxyColors.cosmicBlue.withOpacity(0.15),
                        ]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: GalaxyColors.nebulaViolet.withOpacity(0.4)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              GalaxyColors.nebulaPurple,
                              GalaxyColors.cosmicBlue,
                            ]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shield_outlined,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Parent Dashboard',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: GalaxyColors.textPrimary(isDark),
                                      fontFamily: 'Nunito',
                                    )),
                                Text('Full report + PDF export',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: GalaxyColors.textSecond(isDark),
                                      fontFamily: 'Nunito',
                                    )),
                              ]),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: GalaxyColors.textSecond(isDark)),
                      ]),
                    ),
                  ),
                ),
                // View toggle (Parent / Doctor)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: _ViewToggle(state: state, isDark: isDark),
                ),
                const SizedBox(height: 8),
                // Tab bar (Overview / Games / Logs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _TabBar(state: state, isDark: isDark),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: _TabContent(
                        key: ValueKey(state.selectedTab),
                        state: state,
                        isDark: isDark),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ── View Toggle ───────────────────────────────────────────────────────────────
class _ViewToggle extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _ViewToggle({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GalaxyColors.surface2(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GalaxyColors.border(isDark), width: 0.5),
      ),
      child: Row(
        children: ['Parent', 'Doctor'].map((view) {
          final selected = state.selectedView == view;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<ProgressBloc>().add(ProgressViewSwitched(view)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(colors: [
                          GalaxyColors.nebulaPurple,
                          GalaxyColors.cosmicBlue
                        ])
                      : null,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected && isDark
                      ? [
                          BoxShadow(
                              color: GalaxyColors.nebulaPurple.withOpacity(0.4),
                              blurRadius: 8)
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(view == 'Parent' ? '👨‍👩‍👧' : '🩺',
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text('$view View',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.normal,
                          color: selected
                              ? Colors.white
                              : GalaxyColors.textSecond(isDark),
                          fontFamily: 'Nunito',
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _TabBar({required this.state, required this.isDark});

  static const _tabs = [
    ('overview', '📊', 'Overview'),
    ('games', '🎮', 'Games'),
    ('logs', '📋', 'Logs'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _tabs.map((tab) {
        final selected = state.selectedTab == tab.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                context.read<ProgressBloc>().add(ProgressTabSwitched(tab.$1)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? GalaxyColors.nebulaViolet.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? GalaxyColors.nebulaViolet
                      : GalaxyColors.border(isDark),
                ),
              ),
              child: Column(
                children: [
                  Text(tab.$2, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(tab.$3,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.normal,
                        color: selected
                            ? GalaxyColors.nebulaViolet
                            : GalaxyColors.textSecond(isDark),
                        fontFamily: 'Nunito',
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tab Content ───────────────────────────────────────────────────────────────
class _TabContent extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _TabContent({super.key, required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    switch (state.selectedTab) {
      case 'games':
        return _GamesTab(state: state, isDark: isDark);
      case 'logs':
        return _LogsTab(state: state, isDark: isDark);
      default:
        return _OverviewTab(state: state, isDark: isDark);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  OVERVIEW TAB
// ════════════════════════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _OverviewTab({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data source badge
          if (!state.isRealData) _DemoBadge(isDark: isDark),

          // Stat cards
          Row(children: [
            _StatCard(
                icon: Icons.sports_esports_rounded,
                value: '${state.sessions}',
                label: 'Sessions',
                gradient: [GalaxyColors.cosmicBlue, GalaxyColors.nebulaViolet],
                isDark: isDark),
            const SizedBox(width: 10),
            _StatCard(
                icon: Icons.local_fire_department_rounded,
                value: '${state.streakDays}d',
                label: 'Streak',
                gradient: [GalaxyColors.cometOrange, GalaxyColors.solarGold],
                isDark: isDark,
                highlighted: true),
            const SizedBox(width: 10),
            _StatCard(
                icon: Icons.emoji_events_rounded,
                value: '${state.awards}',
                label: 'Awards',
                gradient: [GalaxyColors.solarGold, GalaxyColors.stardustPink],
                isDark: isDark),
            const SizedBox(width: 10),
            _StatCard(
                icon: Icons.star_rounded,
                value: '${state.totalScore}',
                label: 'Points',
                gradient: [GalaxyColors.auroraGreen, GalaxyColors.cosmicBlue],
                isDark: isDark),
          ]),
          const SizedBox(height: 18),

          // Weekly chart
          GalaxyCard(
            padding: const EdgeInsets.all(18),
            glowing: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Weekly Activity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: GalaxyColors.textPrimary(isDark),
                        fontFamily: 'Nunito',
                      )),
                  const Spacer(),
                  Text('avg accuracy per day',
                      style: TextStyle(
                        fontSize: 10,
                        color: GalaxyColors.textSecond(isDark),
                        fontFamily: 'Nunito',
                      )),
                ]),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: state.weeklyData.map((data) {
                      final pct = (data.value * 100).round();
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (data.value > 0)
                                Text('$pct%',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: GalaxyColors.textSecond(isDark),
                                      fontFamily: 'Nunito',
                                    )),
                              const SizedBox(height: 2),
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor: data.value.clamp(0.05, 1.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          GalaxyColors.nebulaPurple
                                              .withOpacity(isDark ? 0.9 : 0.7),
                                          GalaxyColors.cosmicBlue
                                              .withOpacity(isDark ? 0.9 : 0.7),
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: isDark
                                          ? [
                                              BoxShadow(
                                                  color: GalaxyColors
                                                      .nebulaViolet
                                                      .withOpacity(0.4),
                                                  blurRadius: 8)
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(data.day,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: GalaxyColors.textSecond(isDark),
                                    fontFamily: 'Nunito',
                                  )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Doctor view: per-game accuracy breakdown
          if (state.selectedView == 'Doctor') ...[
            Text('Game Accuracy',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: GalaxyColors.textPrimary(isDark),
                  fontFamily: 'Nunito',
                )),
            const SizedBox(height: 10),
            ...state.gameStats.values
                .map((g) => _AccuracyRow(stat: g, isDark: isDark)),
            const SizedBox(height: 10),
          ],

          // Recent activity
          Row(children: [
            Text('Recent Activity',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: GalaxyColors.textPrimary(isDark),
                  fontFamily: 'Nunito',
                )),
          ]),
          const SizedBox(height: 10),
          ...state.dailyLogs.take(5).map((log) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _LogCard(log: log, isDark: isDark),
              )),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  GAMES TAB
// ════════════════════════════════════════════════════════════════════════════
class _GamesTab extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _GamesTab({required this.state, required this.isDark});

  static const _gradients = {
    'emotion_match': [Color(0xFF7C3AED), Color(0xFFEC4899)],
    'word_builder': [Color(0xFF2563EB), Color(0xFF7C3AED)],
    'color_match': [Color(0xFFEC4899), Color(0xFFF97316)],
    'number_fun': [Color(0xFFF97316), Color(0xFFEF4444)],
    'sequencing': [Color(0xFF059669), Color(0xFF0EA5E9)],
    'color_sorting': [Color(0xFF10B981), Color(0xFF3B82F6)],
  };

  @override
  Widget build(BuildContext context) {
    if (state.gameStats.isEmpty) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎮', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No games played yet!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: GalaxyColors.textPrimary(isDark),
                fontFamily: 'Nunito',
              )),
          Text('Play some games to see stats here',
              style: TextStyle(
                fontSize: 13,
                color: GalaxyColors.textSecond(isDark),
                fontFamily: 'Nunito',
              )),
        ],
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        children: [
          if (!state.isRealData) _DemoBadge(isDark: isDark),
          ...state.gameStats.values.map((stat) {
            final gradient = (_gradients[stat.gameId] ??
                    [GalaxyColors.nebulaViolet, GalaxyColors.cosmicBlue])
                .cast<Color>();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GalaxyCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                      color: gradient.first.withOpacity(0.5),
                                      blurRadius: 12)
                                ]
                              : null,
                        ),
                        child: Center(
                            child: Text(stat.emoji,
                                style: const TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stat.gameName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: GalaxyColors.textPrimary(isDark),
                                  fontFamily: 'Nunito',
                                )),
                            Text(
                              '${stat.plays} plays  •  Best: ${stat.bestScore} pts',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: GalaxyColors.textSecond(isDark),
                                  fontFamily: 'Nunito'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(stat.avgAccuracy * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Nunito'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Text('Accuracy',
                          style: TextStyle(
                              fontSize: 11,
                              color: GalaxyColors.textSecond(isDark),
                              fontFamily: 'Nunito')),
                      const Spacer(),
                      Text('${(stat.avgAccuracy * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: gradient.first,
                            fontFamily: 'Nunito',
                          )),
                    ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: stat.avgAccuracy,
                        backgroundColor: GalaxyColors.border(isDark),
                        valueColor: AlwaysStoppedAnimation(gradient.first),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  LOGS TAB
// ════════════════════════════════════════════════════════════════════════════
class _LogsTab extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _LogsTab({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (state.dailyLogs.isEmpty) {
      return Center(
          child: Text('No activity yet',
              style: TextStyle(
                color: GalaxyColors.textSecond(isDark),
                fontFamily: 'Nunito',
              )));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: state.dailyLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _LogCard(log: state.dailyLogs[i], isDark: isDark),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────
class _DemoBadge extends StatelessWidget {
  final bool isDark;
  const _DemoBadge({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: GalaxyColors.solarGold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GalaxyColors.solarGold.withOpacity(0.4)),
      ),
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(
          'Showing demo data — connect Firebase to see real stats',
          style: TextStyle(
              fontSize: 11,
              color: GalaxyColors.solarGold,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600),
        )),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final List<Color> gradient;
  final bool isDark, highlighted;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
    required this.isDark,
    this.highlighted = false,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: GalaxyColors.surface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted
                ? gradient.first.withOpacity(0.4)
                : GalaxyColors.border(isDark),
          ),
          boxShadow: highlighted && isDark
              ? [
                  BoxShadow(
                      color: gradient.first.withOpacity(0.3),
                      blurRadius: 14,
                      spreadRadius: -4),
                ]
              : null,
        ),
        child: Column(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                    color: gradient.first.withOpacity(isDark ? 0.5 : 0.25),
                    blurRadius: 8)
              ],
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GalaxyColors.textPrimary(isDark),
                  fontFamily: 'Nunito')),
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: GalaxyColors.textSecond(isDark),
                  fontFamily: 'Nunito')),
        ]),
      ),
    );
  }
}

class _AccuracyRow extends StatelessWidget {
  final GameStatSummary stat;
  final bool isDark;
  const _AccuracyRow({required this.stat, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(stat.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(stat.gameName,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: GalaxyColors.textPrimary(isDark),
                      fontFamily: 'Nunito')),
              const Spacer(),
              Text('${(stat.avgAccuracy * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GalaxyColors.nebulaViolet,
                    fontFamily: 'Nunito',
                  )),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stat.avgAccuracy,
                backgroundColor: GalaxyColors.border(isDark),
                valueColor:
                    const AlwaysStoppedAnimation(GalaxyColors.nebulaViolet),
                minHeight: 6,
              ),
            ),
          ],
        )),
      ]),
    );
  }
}

class _LogCard extends StatelessWidget {
  final DailyLog log;
  final bool isDark;
  const _LogCard({required this.log, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final scoreColor = log.score >= 8
        ? GalaxyColors.auroraGreen
        : log.score >= 5
            ? GalaxyColors.solarGold
            : GalaxyColors.supernovaRed;
    return GalaxyCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Text(log.emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(log.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: GalaxyColors.textPrimary(isDark),
                      fontFamily: 'Nunito')),
              if (log.gameName.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GalaxyColors.nebulaViolet.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(log.gameName,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: GalaxyColors.nebulaViolet,
                        fontFamily: 'Nunito',
                      )),
                ),
              ],
            ]),
            const SizedBox(height: 2),
            Text(log.note,
                style: TextStyle(
                    fontSize: 11,
                    color: GalaxyColors.textSecond(isDark),
                    fontFamily: 'Nunito')),
          ],
        )),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scoreColor.withOpacity(0.4)),
          ),
          child: Text('${log.score}/10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: scoreColor,
                fontFamily: 'Nunito',
              )),
        ),
      ]),
    );
  }
}
