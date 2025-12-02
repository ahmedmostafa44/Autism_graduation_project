import 'package:autism_app/features/onboarding/view/onboarding.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(AutismApp());
}

class AutismApp extends StatelessWidget {
  const AutismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Onboarding());
  }
}
