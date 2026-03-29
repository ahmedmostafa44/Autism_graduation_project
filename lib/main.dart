import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:autism_app/core/services/gemini_service.dart';
import 'package:autism_app/firebase_options.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/router/app_router.dart';
import 'package:autism_app/core/bloc/navigation_bloc.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';
import 'package:autism_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:autism_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:autism_app/features/games/presentation/bloc/games_bloc.dart';
import 'package:autism_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:autism_app/features/speak/presentation/bloc/speak_bloc.dart';
import 'package:autism_app/features/community/presentation/bloc/community_bloc.dart';
import 'package:autism_app/features/progress/presentation/bloc/progress_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Gemini init ──────────────────────────────────────────────────────────
  GeminiService.init();

  // ── Firebase init ────────────────────────────────────────────────────────
  // Safe init: skips Firebase if you haven't run `flutterfire configure` yet.
  // The app runs in LOCAL MODE (mock login) until you connect Firebase.
  // To activate real Firebase:
  //   1. Go to https://console.firebase.google.com → create project
  //   2. Run:  dart pub global activate flutterfire_cli
  //   3. Run:  flutterfire configure   (in this project folder)
  //   4. That's it — firebase_options.dart gets auto-generated with your keys!
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase not configured yet — app continues in local/mock mode
    debugPrint('⚠️  Firebase not initialized. Running in local mode. Error: $e');
  }
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AutismApp());
}

class AutismApp extends StatefulWidget {
  const AutismApp({super.key});

  @override
  State<AutismApp> createState() => _AutismAppState();
}

class _AutismAppState extends State<AutismApp> {
  // AuthBloc lives here so router can reference it
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => HomeBloc()..add(HomeLoadData())),
        BlocProvider(create: (_) => GamesBloc()..add(GamesLoadRequested())),
        BlocProvider(create: (_) => ChatBloc()..add(ChatInitialized())),
        BlocProvider(create: (_) => SpeakBloc()..add(SpeakLoadRequested())),
        BlocProvider(create: (_) => CommunityBloc()..add(CommunityLoadRequested())),
        BlocProvider(create: (_) => ProgressBloc()..add(ProgressLoadRequested())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'BuddyApp',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.createRouter(_authBloc),
          );
        },
      ),
    );
  }
}
