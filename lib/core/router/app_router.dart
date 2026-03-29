import 'package:autism_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:autism_app/core/widgets/main_scaffold.dart';
import 'package:autism_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:autism_app/features/auth/presentation/pages/splash_page.dart';
import 'package:autism_app/features/auth/presentation/pages/login_page.dart';
import 'package:autism_app/features/auth/presentation/pages/register_page.dart';
import 'package:autism_app/features/auth/presentation/pages/forgot_password_page.dart';
// import 'package:autism_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:autism_app/features/home/presentation/pages/home_page.dart';
import 'package:autism_app/features/games/presentation/pages/games_page.dart';
import 'package:autism_app/features/games/presentation/pages/emotion_match_game.dart';
import 'package:autism_app/features/games/presentation/pages/word_builder_game.dart';
import 'package:autism_app/features/games/presentation/pages/color_match_game.dart';
import 'package:autism_app/features/games/presentation/pages/number_fun_game.dart';
import 'package:autism_app/features/games/presentation/pages/sequencing_game.dart';
import 'package:autism_app/features/games/presentation/pages/color_sorting_game.dart';
import 'package:autism_app/features/chat/presentation/pages/chat_page.dart';
import 'package:autism_app/features/speak/presentation/pages/speak_page.dart';
import 'package:autism_app/features/community/presentation/pages/community_page.dart';
import 'package:autism_app/features/progress/presentation/pages/progress_page.dart';
import 'package:autism_app/features/parent/presentation/pages/parent_dashboard_page.dart';
import 'package:autism_app/core/widgets/galaxy_background.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';

class AppRouter {
  // ── Route constants ───────────────────────────────────────────────────────
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/';
  static const games = '/games';
  static const emotionMatch = '/games/emotion-match';
  static const wordBuilder = '/games/word-builder';
  static const colorMatch = '/games/color-match';
  static const numberFun = '/games/number-fun';
  static const sequencing = '/games/sequencing';
  static const colorSorting = '/games/color-sorting';
  static const chat = '/chat';
  static const speak = '/speak';
  static const community = '/community';
  static const progress = '/progress';
  static const parentDashboard = '/parent-dashboard';

  // ── Router ────────────────────────────────────────────────────────────────
  static GoRouter createRouter(AuthBloc authBloc) => GoRouter(
        initialLocation: splash,
        refreshListenable: _AuthNotifier(authBloc),
        redirect: (context, state) {
          final authState = authBloc.state;
          final isOnAuth = state.matchedLocation == login ||
              state.matchedLocation == register ||
              state.matchedLocation == forgotPassword ||
              state.matchedLocation == splash ||
              state.matchedLocation == onboarding;

          if (authState is AuthInitial || authState is AuthLoading) {
            return state.matchedLocation == splash ? null : splash;
          }
          if (authState is AuthUnauthenticated) {
            return isOnAuth ? null : login;
          }
          if (authState is AuthAuthenticated) {
            return isOnAuth ? home : null;
          }
          return null;
        },
        routes: [
          // ── Auth routes (no shell/nav bar) ──
          GoRoute(path: splash, builder: (_, __) => const SplashPage()),
          // GoRoute(path: onboarding,     builder: (_, __) => const OnboardingPage()),
          GoRoute(path: login, builder: (_, __) => const LoginPage()),
          GoRoute(path: register, builder: (_, __) => const RegisterPage()),
          GoRoute(
              path: forgotPassword,
              builder: (_, __) => const ForgotPasswordPage()),

          // ── Main app shell (has galaxy bg + bottom nav bar) ──
          ShellRoute(
            builder: (context, state, child) => MainScaffold(child: child),
            routes: [
              GoRoute(
                path: home,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: HomePage()),
              ),
              GoRoute(
                path: games,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: GamesPage()),
              ),
              GoRoute(
                path: chat,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ChatPage()),
              ),
              GoRoute(
                path: speak,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: SpeakPage()),
              ),
              GoRoute(
                path: community,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: CommunityPage()),
              ),
              GoRoute(
                path: progress,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ProgressPage()),
              ),
            ],
          ),

          // ── Game sub-screens (full screen, no nav bar, galaxy bg) ──
          GoRoute(
            path: emotionMatch,
            builder: (context, _) =>
                _GameShell(child: const EmotionMatchGame()),
          ),
          GoRoute(
            path: wordBuilder,
            builder: (context, _) => _GameShell(child: const WordBuilderGame()),
          ),
          GoRoute(
            path: colorMatch,
            builder: (context, _) => _GameShell(child: const ColorMatchGame()),
          ),
          GoRoute(
            path: numberFun,
            builder: (context, _) => _GameShell(child: const NumberFunGame()),
          ),
          GoRoute(
            path: sequencing,
            builder: (context, _) => _GameShell(child: const SequencingGame()),
          ),
          GoRoute(
            path: colorSorting,
            builder: (context, _) =>
                _GameShell(child: const ColorSortingGame()),
          ),
          GoRoute(
            path: parentDashboard,
            builder: (context, _) =>
                _GameShell(child: const ParentDashboardPage()),
          ),
        ],
      );
}

/// Wraps game screens in the galaxy background (no nav bar)
class _GameShell extends StatelessWidget {
  final Widget child;
  const _GameShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;
    return Scaffold(
      backgroundColor: GalaxyColors.bg(isDark),
      body: GalaxyBackground(isDark: isDark, child: child),
    );
  }
}

/// Makes GoRouter refresh when AuthBloc state changes
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
