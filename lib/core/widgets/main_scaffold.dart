import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/navigation_bloc.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    _TabItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        path: '/'),
    _TabItem(
        label: 'Games',
        icon: Icons.sports_esports_outlined,
        activeIcon: Icons.sports_esports,
        path: '/games'),
    _TabItem(
        label: 'Chat',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble_rounded,
        path: '/chat'),
    _TabItem(
        label: 'Speak',
        icon: Icons.volume_up_outlined,
        activeIcon: Icons.volume_up_rounded,
        path: '/speak'),
    _TabItem(
        label: 'Community',
        icon: Icons.people_outline,
        activeIcon: Icons.people_rounded,
        path: '/community'),
    _TabItem(
        label: 'Progress',
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
        path: '/progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        return BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, navState) {
            final currentIndex = navState.currentIndex;
            return Scaffold(
              backgroundColor: GalaxyColors.bg(isDark),
              body: child,
              bottomNavigationBar: _GalaxyNavBar(
                isDark: isDark,
                currentIndex: currentIndex,
                tabs: _tabs,
                onTap: (index) {
                  context
                      .read<NavigationBloc>()
                      .add(NavigationTabChanged(index));
                  context.go(_tabs[index].path);
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _GalaxyNavBar extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final List<_TabItem> tabs;
  final ValueChanged<int> onTap;

  const _GalaxyNavBar({
    required this.isDark,
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = GalaxyColors.surface(isDark);
    final border = GalaxyColors.border(isDark);

    return Container(
      decoration: BoxDecoration(
        color: surface.withOpacity(isDark ? 0.85 : 0.95),
        border: Border(top: BorderSide(color: border, width: 0.5)),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: GalaxyColors.nebulaViolet.withOpacity(0.15),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isActive = currentIndex == index;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isActive ? 40 : 0,
                          height: isActive ? 4 : 0,
                          margin: EdgeInsets.only(bottom: isActive ? 4 : 0),
                          decoration: BoxDecoration(
                            color: GalaxyColors.nebulaViolet,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: isActive && isDark
                                ? [
                                    BoxShadow(
                                      color: GalaxyColors.nebulaViolet
                                          .withOpacity(0.8),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        Icon(
                          isActive ? tab.activeIcon : tab.icon,
                          size: 22,
                          color: isActive
                              ? GalaxyColors.nebulaViolet
                              : GalaxyColors.textSecond(isDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.normal,
                            color: isActive
                                ? GalaxyColors.nebulaViolet
                                : GalaxyColors.textSecond(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
