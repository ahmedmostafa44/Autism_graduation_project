import 'package:autism_app/core/bloc/nav_bloc.dart';
import 'package:autism_app/core/utils/contansts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    _TabItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home, path: '/'),
    _TabItem(label: 'Games', icon: Icons.sports_esports_outlined, activeIcon: Icons.sports_esports, path: '/games'),
    _TabItem(label: 'Chat', icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, path: '/chat'),
    _TabItem(label: 'Speak', icon: Icons.volume_up_outlined, activeIcon: Icons.volume_up, path: '/speak'),
    _TabItem(label: 'Community', icon: Icons.people_outline, activeIcon: Icons.people, path: '/community'),
    _TabItem(label: 'Progress', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, path: '/progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        final currentIndex = navState.currentIndex;
        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 64,
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final tab = _tabs[index];
                    final isActive = currentIndex == index;
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          context.read<NavigationBloc>().add(NavigationTabChanged(index));
                          context.go(tab.path);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActive ? tab.activeIcon : tab.icon,
                              size: 22,
                              color: isActive ? AppColors.primary : AppColors.textSecondary,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                color: isActive ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
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
