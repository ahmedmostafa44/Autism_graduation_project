import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';

import '../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0));
    _ctrl.forward();

    // Fire auth check
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/');
        } else if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: GalaxyColors.bg(isDark),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        GalaxyColors.nebulaPurple,
                        GalaxyColors.cosmicBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: GalaxyColors.nebulaPurple.withOpacity(0.7),
                        blurRadius: 40,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      color: Colors.white, size: 52),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    Text('BuddyApp',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: GalaxyColors.textPrimary(isDark),
                          fontFamily: 'Nunito',
                          letterSpacing: -1,
                        )),
                    const SizedBox(height: 6),
                    Text('Learning through the stars ✨',
                        style: TextStyle(
                          fontSize: 14,
                          color: GalaxyColors.textSecond(isDark),
                          fontFamily: 'Nunito',
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              FadeTransition(
                opacity: _fade,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: GalaxyColors.nebulaViolet,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
