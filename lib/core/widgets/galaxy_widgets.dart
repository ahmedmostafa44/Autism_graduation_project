import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';

/// Glassmorphic card with nebula border glow
class GalaxyCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final double radius;
  final bool glowing;

  const GalaxyCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.radius = 20,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    final bgColor = color ?? GalaxyColors.surface(isDark);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: glowing
              ? GalaxyColors.nebulaViolet.withOpacity(0.5)
              : GalaxyColors.border(isDark),
          width: glowing ? 1.5 : 1,
        ),
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: GalaxyColors.nebulaViolet.withOpacity(isDark ? 0.3 : 0.12),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
              ]
            : isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: GalaxyColors.lightBorder.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}

/// Standard page app bar with back button + theme toggle
class GalaxyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const GalaxyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              if (showBack)
                _CosmicButton(
                  isDark: isDark,
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              if (showBack) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: GalaxyColors.textPrimary(isDark),
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              ...(actions ?? []),
              const SizedBox(width: 8),
              const _ThemeToggleButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark/Light toggle with cosmic animation
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return GestureDetector(
      onTap: () => context.read<ThemeBloc>().add(ThemeToggled()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E2654), const Color(0xFF0F1330)]
                : [const Color(0xFFDDD6FE), const Color(0xFFBFDBFE)],
          ),
          border: Border.all(
            color: isDark
                ? GalaxyColors.nebulaViolet.withOpacity(0.4)
                : GalaxyColors.lightBorder,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              left: isDark ? 4 : 24,
              top: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? GalaxyColors.nebulaViolet : GalaxyColors.solarGold,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? GalaxyColors.nebulaViolet.withOpacity(0.8)
                          : GalaxyColors.solarGold.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CosmicButton extends StatelessWidget {
  final bool isDark;
  final Widget child;
  final VoidCallback onTap;

  const _CosmicButton({required this.isDark, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: GalaxyColors.surface(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GalaxyColors.border(isDark)),
        ),
        child: child,
      ),
    );
  }
}
