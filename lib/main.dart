import 'package:autism_app/features/auth/bloc/auth_bloc.dart';
import 'package:autism_app/features/auth/bloc/auth_event.dart';
import 'package:autism_app/features/onboarding/view/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// lib/main.dart
void main() {
  runApp(
    BlocProvider(
      create: (context) => AuthBloc()..add(AuthCheckRequested()),
      child: const AutismApp(),
    ),
  );
}

class AutismApp extends StatelessWidget {
  const AutismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}
