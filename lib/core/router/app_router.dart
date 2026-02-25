import 'package:autism_app/core/utils/widgets/main_scaff.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/features/home/presentation/pages/home_page.dart';
import 'package:autism_app/features/games/presentation/pages/games_page.dart';
import 'package:autism_app/features/chat/presentation/pages/chat_page.dart';
import 'package:autism_app/features/speak/presentation/pages/speak_page.dart';
import 'package:autism_app/features/community/presentation/pages/community_page.dart';
import 'package:autism_app/features/progress/presentation/pages/progress_page.dart';

class AppRouter {
  static const String home = '/';
  static const String games = '/games';
  static const String chat = '/chat';
  static const String speak = '/speak';
  static const String community = '/community';
  static const String progress = '/progress';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: games,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GamesPage(),
            ),
          ),
          GoRoute(
            path: chat,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ChatPage(),
            ),
          ),
          GoRoute(
            path: speak,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SpeakPage(),
            ),
          ),
          GoRoute(
            path: community,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommunityPage(),
            ),
          ),
          GoRoute(
            path: progress,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProgressPage(),
            ),
          ),
        ],
      ),
    ],
  );
}
