import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/navigation_bloc.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/core/widgets/galaxy_widgets.dart';
import 'package:autism_app/features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return Center(
              child: CircularProgressIndicator(
                color: GalaxyColors.nebulaViolet,
              ),
            );
          }
          if (state is HomeLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HomeHeader(state: state, isDark: isDark),
                    const SizedBox(height: 20),
                    _TodayTipCard(tip: state.todayTip, isDark: isDark),
                    const SizedBox(height: 24),
                    _FeatureGrid(isDark: isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final HomeLoaded state;
  final bool isDark;
  const _HomeHeader({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Robot avatar with glow
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color:
                    GalaxyColors.nebulaPurple.withOpacity(isDark ? 0.6 : 0.3),
                blurRadius: 16,
                spreadRadius: -2,
              ),
            ],
          ),
          child: const Icon(Icons.smart_toy_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning ',
                  style: TextStyle(
                    fontSize: 12,
                    color: GalaxyColors.textSecond(isDark),
                    fontFamily: 'Nunito',
                  )),
              Text(state.parentName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: GalaxyColors.textPrimary(isDark),
                    fontFamily: 'Nunito',
                  )),
            ],
          ),
        ),
        // Offline badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: GalaxyColors.auroraGreen.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: GalaxyColors.auroraGreen.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: GalaxyColors.auroraGreen, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text('Offline Ready',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: GalaxyColors.auroraGreen,
                    fontFamily: 'Nunito',
                  )),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Bell with glow dot
        Stack(
          children: [
            GalaxyCard(
              padding: const EdgeInsets.all(8),
              radius: 12,
              child: Icon(Icons.notifications_outlined,
                  size: 20, color: GalaxyColors.textPrimary(isDark)),
            ),
            if (state.hasNotification)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: GalaxyColors.supernovaRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: GalaxyColors.supernovaRed.withOpacity(0.7),
                          blurRadius: 6),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
        // Logout button
        GestureDetector(
          onTap: () {
            context.read<AuthBloc>().add(AuthSignOutRequested());
          },
          child: GalaxyCard(
            padding: const EdgeInsets.all(8),
            radius: 12,
            child: Icon(Icons.logout_rounded,
                size: 20, color: GalaxyColors.supernovaRed),
          ),
        ),
      ],
    );
  }
}

class _TodayTipCard extends StatelessWidget {
  final String tip;
  final bool isDark;
  const _TodayTipCard({required this.tip, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1250), const Color(0xFF120E3A)]
              : [const Color(0xFFEDE9FE), const Color(0xFFDBEAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GalaxyColors.nebulaViolet.withOpacity(isDark ? 0.35 : 0.2),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: GalaxyColors.nebulaPurple.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: GalaxyColors.solarGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Center(child: Text('💡', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Tip",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: GalaxyColors.nebulaViolet,
                      fontFamily: 'Nunito',
                    )),
                const SizedBox(height: 4),
                Text(tip,
                    style: TextStyle(
                      fontSize: 13,
                      color: GalaxyColors.textPrimary(isDark),
                      height: 1.5,
                      fontFamily: 'Nunito',
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final bool isDark;
  const _FeatureGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureItem(
        title: 'Educational\nGames',
        subtitle: '12 games',
        icon: Icons.sports_esports_rounded,
        gradient: [const Color(0xFF2563EB), const Color(0xFF7C3AED)],
        bgColor: GalaxyColors.gamesCard(isDark),
        route: '/games',
        tabIndex: 1,
      ),
      _FeatureItem(
        title: 'Chat Bot',
        subtitle: 'AI assistant',
        icon: Icons.smart_toy_rounded,
        gradient: [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
        bgColor: GalaxyColors.chatCard(isDark),
        route: '/chat',
        tabIndex: 2,
      ),
      _FeatureItem(
        title: 'Text to\nSpeech',
        subtitle: 'Speak out loud',
        icon: Icons.record_voice_over_rounded,
        gradient: [const Color(0xFF059669), const Color(0xFF0EA5E9)],
        bgColor: GalaxyColors.speakCard(isDark),
        route: '/speak',
        tabIndex: 3,
      ),
      _FeatureItem(
        title: 'Community',
        subtitle: 'Resources',
        icon: Icons.people_alt_rounded,
        gradient: [const Color(0xFFF97316), const Color(0xFFEF4444)],
        bgColor: GalaxyColors.communityCard(isDark),
        route: '/community',
        tabIndex: 4,
      ),
      _FeatureItem(
        title: 'Track\nProgress',
        subtitle: 'View insights',
        icon: Icons.insights_rounded,
        gradient: [const Color(0xFF2563EB), const Color(0xFF06B6D4)],
        bgColor: GalaxyColors.progressCard(isDark),
        route: '/progress',
        tabIndex: 5,
        isNew: true,
      ),
      _FeatureItem(
        title: 'Subscription',
        subtitle: 'Manage plan',
        icon: Icons.workspace_premium_rounded,
        gradient: [const Color(0xFF7C3AED), const Color(0xFF2563EB)],
        bgColor: GalaxyColors.subCard(isDark),
        route: '/',
        tabIndex: 0,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) =>
          _FeatureCard(feature: features[i], isDark: isDark),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;
  final bool isDark;
  const _FeatureCard({super.key, required this.feature, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context
            .read<NavigationBloc>()
            .add(NavigationTabChanged(feature.tabIndex));
        context.go(feature.route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: feature.bgColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: GalaxyColors.border(isDark), width: 0.5),
        ),
        child: Stack(
          children: [
            // Subtle gradient glow top-right
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      feature.gradient.first.withOpacity(isDark ? 0.25 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gradient icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: feature.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: feature.gradient.first
                              .withOpacity(isDark ? 0.5 : 0.25),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Icon(feature.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 14),
                  Text(feature.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: GalaxyColors.textPrimary(isDark),
                        fontFamily: 'Nunito',
                        height: 1.2,
                      )),
                  const SizedBox(height: 3),
                  Text(feature.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: GalaxyColors.textSecond(isDark),
                        fontFamily: 'Nunito',
                      )),
                ],
              ),
            ),
            if (feature.isNew)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      GalaxyColors.nebulaViolet,
                      GalaxyColors.stardustPink
                    ]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: GalaxyColors.nebulaViolet.withOpacity(0.5),
                          blurRadius: 8),
                    ],
                  ),
                  child: const Text('New',
                      style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title, subtitle, route;
  final IconData icon;
  final List<Color> gradient;
  final Color bgColor;
  final int tabIndex;
  final bool isNew;
  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.bgColor,
    required this.route,
    required this.tabIndex,
    this.isNew = false,
  });
}
