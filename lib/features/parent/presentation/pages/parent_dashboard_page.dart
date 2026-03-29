import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import 'package:autism_app/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:autism_app/features/parent/services/report_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ParentDashboardPage
//  PIN-locked screen for parents & therapists.
//  Shows child overview, weekly chart, game stats, and PDF report export.
// ─────────────────────────────────────────────────────────────────────────────

class ParentDashboardPage extends StatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;

    if (!_unlocked) {
      return _PinLockScreen(
        isDark: isDark,
        onUnlocked: () => setState(() => _unlocked = true),
      );
    }

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
            return _Dashboard(state: state, isDark: isDark);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

// ── PIN Lock Screen ───────────────────────────────────────────────────────────
class _PinLockScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onUnlocked;
  const _PinLockScreen({required this.isDark, required this.onUnlocked});

  @override
  State<_PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<_PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _entered = '';
  String _error = '';
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  // Default PIN — parent can change in settings
  static const _defaultPin = '1234';

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    setState(() {
      _entered += d;
      _error = '';
    });
    if (_entered.length == 4) _checkPin();
  }

  Future<void> _checkPin() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('parent_pin') ?? _defaultPin;
    if (_entered == saved) {
      widget.onUnlocked();
    } else {
      _shakeCtrl.forward(from: 0);
      setState(() {
        _error = 'Incorrect PIN. Try again.';
        _entered = '';
      });
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                    _shakeAnim.value > 0
                        ? 12 * (1 - _shakeAnim.value) *
                            ((_shakeAnim.value * 10).floor() % 2 == 0 ? 1 : -1)
                        : 0,
                    0),
                child: child,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lock icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          GalaxyColors.nebulaPurple,
                          GalaxyColors.cosmicBlue
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GalaxyColors.nebulaViolet.withOpacity(0.5),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 24),
                  Text('Parent Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: GalaxyColors.textPrimary(isDark),
                        fontFamily: 'Nunito',
                      )),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your 4-digit PIN to continue\n(Default: 1234)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: GalaxyColors.textSecond(isDark),
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _entered.length
                              ? GalaxyColors.nebulaViolet
                              : GalaxyColors.border(isDark),
                          boxShadow: i < _entered.length
                              ? [
                                  BoxShadow(
                                    color: GalaxyColors.nebulaViolet
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_error,
                        style: TextStyle(
                          color: GalaxyColors.supernovaRed,
                          fontSize: 13,
                          fontFamily: 'Nunito',
                        )),
                  ],

                  const SizedBox(height: 32),

                  // Numpad
                  _Numpad(onDigit: _onDigit, onDelete: _onDelete, isDark: isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Numpad ────────────────────────────────────────────────────────────────────
class _Numpad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final bool isDark;
  const _Numpad(
      {required this.onDigit, required this.onDelete, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((digit) {
              if (digit.isEmpty) return const SizedBox(width: 72, height: 56);
              final isDelete = digit == '⌫';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    isDelete ? onDelete() : onDigit(digit);
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: GalaxyColors.surface(isDark),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: GalaxyColors.border(isDark), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        digit,
                        style: TextStyle(
                          fontSize: isDelete ? 20 : 22,
                          fontWeight: FontWeight.w700,
                          color: isDelete
                              ? GalaxyColors.supernovaRed
                              : GalaxyColors.textPrimary(isDark),
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// ── Main Dashboard ────────────────────────────────────────────────────────────
class _Dashboard extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _Dashboard({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App bar
        SliverToBoxAdapter(child: _DashboardHeader(isDark: isDark, state: state)),

        // Summary cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _SummaryCards(state: state, isDark: isDark),
          ),
        ),

        // Weekly chart
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _WeeklyChart(state: state, isDark: isDark),
          ),
        ),

        // Game performance
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _GamePerformance(state: state, isDark: isDark),
          ),
        ),

        // Recent sessions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: _RecentSessions(state: state, isDark: isDark),
          ),
        ),

        // Report button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
            child: _ReportButton(state: state, isDark: isDark),
          ),
        ),
      ],
    );
  }
}

// ── Dashboard Header ──────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final bool isDark;
  final ProgressLoaded state;
  const _DashboardHeader({required this.isDark, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GalaxyColors.nebulaPurple.withOpacity(0.3),
            GalaxyColors.cosmicBlue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
            bottom:
                BorderSide(color: GalaxyColors.border(isDark), width: 0.5)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: GalaxyColors.surface(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GalaxyColors.border(isDark)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: GalaxyColors.textPrimary(isDark)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Parent Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: GalaxyColors.textPrimary(isDark),
                  fontFamily: 'Nunito',
                )),
            Text('Child progress overview',
                style: TextStyle(
                  fontSize: 12,
                  color: GalaxyColors.textSecond(isDark),
                  fontFamily: 'Nunito',
                )),
          ]),
        ),
        if (!state.isRealData)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: GalaxyColors.solarGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: GalaxyColors.solarGold.withOpacity(0.4)),
            ),
            child: Text('Demo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: GalaxyColors.solarGold,
                  fontFamily: 'Nunito',
                )),
          ),
      ]),
    );
  }
}

// ── Summary Cards ─────────────────────────────────────────────────────────────
class _SummaryCards extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _SummaryCards({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final avgAcc = state.gameStats.isEmpty
        ? 0.0
        : state.gameStats.values
                .map((g) => g.avgAccuracy)
                .reduce((a, b) => a + b) /
            state.gameStats.length;

    final cards = [
      ('🎮', 'Sessions', '${state.sessions}', GalaxyColors.cosmicBlue),
      ('🎯', 'Accuracy', '${(avgAcc * 100).round()}%', GalaxyColors.auroraGreen),
      ('🔥', 'Streak', '${state.streakDays}d', GalaxyColors.cometOrange),
      ('🏆', 'Awards', '${state.awards}', GalaxyColors.solarGold),
    ];

    return Row(
      children: cards.map((c) {
        final (icon, label, value, color) = c;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'Nunito',
                    )),
                Text(label,
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
    );
  }
}

// ── Weekly Chart ──────────────────────────────────────────────────────────────
class _WeeklyChart extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _WeeklyChart({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GalaxyCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Weekly Activity',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: GalaxyColors.textPrimary(isDark),
              fontFamily: 'Nunito',
            )),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: state.weeklyData.map((d) {
              final barH = (d.value * 64).clamp(4.0, 64.0);
              final isHigh = d.value >= 0.7;
              return SizedBox(
                width: 32,
                height: 110,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(d.value * 100).round()}%',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isHigh
                            ? GalaxyColors.auroraGreen
                            : GalaxyColors.textSecond(isDark),
                        fontFamily: 'Nunito',
                      )),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 28,
                    height: barH,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isHigh
                            ? [
                                GalaxyColors.auroraGreen,
                                GalaxyColors.cosmicBlue
                              ]
                            : [
                                GalaxyColors.nebulaViolet
                                    .withOpacity(0.4),
                                GalaxyColors.cosmicBlue.withOpacity(0.3),
                              ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(d.day,
                      style: TextStyle(
                        fontSize: 10,
                        color: GalaxyColors.textSecond(isDark),
                        fontFamily: 'Nunito',
                      )),
                ],
              ),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}

// ── Game Performance ──────────────────────────────────────────────────────────
class _GamePerformance extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _GamePerformance({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GalaxyCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Game Performance',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: GalaxyColors.textPrimary(isDark),
              fontFamily: 'Nunito',
            )),
        const SizedBox(height: 12),
        if (state.gameStats.isEmpty)
          Text('No games played yet.',
              style: TextStyle(
                  color: GalaxyColors.textSecond(isDark),
                  fontFamily: 'Nunito',
                  fontSize: 13))
        else
          ...state.gameStats.values.map((g) {
            final color = g.avgAccuracy >= 0.8
                ? GalaxyColors.auroraGreen
                : g.avgAccuracy >= 0.5
                    ? GalaxyColors.solarGold
                    : GalaxyColors.supernovaRed;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text('${g.emoji}  ${g.gameName}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: GalaxyColors.textPrimary(isDark),
                          fontFamily: 'Nunito',
                        )),
                    const Spacer(),
                    Text('${g.plays} plays',
                        style: TextStyle(
                          fontSize: 11,
                          color: GalaxyColors.textSecond(isDark),
                          fontFamily: 'Nunito',
                        )),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                          '${(g.avgAccuracy * 100).round()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: color,
                            fontFamily: 'Nunito',
                          )),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: g.avgAccuracy,
                      backgroundColor:
                          GalaxyColors.border(isDark),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
      ]),
    );
  }
}

// ── Recent Sessions ───────────────────────────────────────────────────────────
class _RecentSessions extends StatelessWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _RecentSessions({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final logs = state.dailyLogs.take(7).toList();
    return GalaxyCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Recent Sessions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: GalaxyColors.textPrimary(isDark),
              fontFamily: 'Nunito',
            )),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          Text('No sessions yet.',
              style: TextStyle(
                  color: GalaxyColors.textSecond(isDark),
                  fontFamily: 'Nunito'))
        else
          ...logs.map((log) {
            final scoreColor = log.score >= 8
                ? GalaxyColors.auroraGreen
                : log.score >= 5
                    ? GalaxyColors.solarGold
                    : GalaxyColors.supernovaRed;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Text(log.emoji,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        log.gameName.isNotEmpty
                            ? log.gameName
                            : log.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: GalaxyColors.textPrimary(isDark),
                          fontFamily: 'Nunito',
                        )),
                    Text(log.note,
                        style: TextStyle(
                          fontSize: 11,
                          color: GalaxyColors.textSecond(isDark),
                          fontFamily: 'Nunito',
                        )),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${log.score}/10',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                        fontFamily: 'Nunito',
                      )),
                  Text(_fmt(log.playedAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: GalaxyColors.textSecond(isDark),
                        fontFamily: 'Nunito',
                      )),
                ]),
              ]),
            );
          }),
      ]),
    );
  }

  String _fmt(DateTime d) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}';
  }
}

// ── Report Button ─────────────────────────────────────────────────────────────
class _ReportButton extends StatefulWidget {
  final ProgressLoaded state;
  final bool isDark;
  const _ReportButton({required this.state, required this.isDark});

  @override
  State<_ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<_ReportButton> {
  bool _loading = false;

  Future<void> _generateReport() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('child_name') ?? 'Child';
      await ReportService.instance.shareReport(
        data: widget.state,
        childName: name,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not generate report: $e'),
          backgroundColor: GalaxyColors.supernovaRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Main share button
      GestureDetector(
        onTap: _loading ? null : _generateReport,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: GalaxyColors.nebulaViolet.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: -2,
              ),
            ],
          ),
          child: _loading
              ? const Center(
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5)))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  const Text('Export PDF Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      )),
                ]),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Generates a full weekly progress report\nyou can save, print, or share with the therapist.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: GalaxyColors.textSecond(widget.isDark),
          fontFamily: 'Nunito',
        ),
      ),
    ]);
  }
}
