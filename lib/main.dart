import 'package:autism_app/core/bloc/nav_bloc.dart';
import 'package:autism_app/core/utils/contansts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autism_app/core/router/app_router.dart';
import 'package:autism_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:autism_app/features/games/presentation/bloc/games_bloc.dart';
import 'package:autism_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:autism_app/features/speak/presentation/bloc/speak_bloc.dart';
import 'package:autism_app/features/community/presentation/bloc/community_bloc.dart';
import 'package:autism_app/features/progress/presentation/bloc/progress_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AutismApp());
}

class AutismApp extends StatelessWidget {
  const AutismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => HomeBloc()..add(HomeLoadData())),
        BlocProvider(create: (_) => GamesBloc()..add(GamesLoadRequested())),
        BlocProvider(create: (_) => ChatBloc()..add(ChatInitialized())),
        BlocProvider(create: (_) => SpeakBloc()..add(SpeakLoadRequested())),
        BlocProvider(create: (_) => CommunityBloc()..add(CommunityLoadRequested())),
        BlocProvider(create: (_) => ProgressBloc()..add(ProgressLoadRequested())),
      ],
      child: MaterialApp.router(
        title: 'Autism Support App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
