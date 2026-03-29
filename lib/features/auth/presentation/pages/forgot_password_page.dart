import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: GalaxyColors.surface(isDark),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('📧 Email Sent!',
                  style: TextStyle(
                      fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
              content: Text(
                'Password reset instructions have been sent to ${_emailCtrl.text}',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    color: GalaxyColors.textSecond(isDark)),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                  child: const Text('Back to Login',
                      style: TextStyle(
                          color: GalaxyColors.nebulaViolet,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Nunito')),
                ),
              ],
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: GalaxyColors.supernovaRed,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: GalaxyColors.bg(isDark),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: GalaxyColors.surface(isDark),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: GalaxyColors.border(isDark)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: GalaxyColors.textPrimary(isDark)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: GalaxyColors.cosmicBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: GalaxyColors.cosmicBlue.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.lock_reset_rounded,
                          color: GalaxyColors.cosmicBlue, size: 34),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Reset Password 🔑',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: GalaxyColors.textPrimary(isDark),
                        fontFamily: 'Nunito',
                      )),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email and we'll send you a reset link.",
                    style: TextStyle(
                      fontSize: 14,
                      color: GalaxyColors.textSecond(isDark),
                      fontFamily: 'Nunito',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  GalaxyTextField(
                    hint: 'Email address',
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => GalaxyButton(
                      label: 'Send Reset Email',
                      loading: state is AuthOperationInProgress,
                      gradient: const [
                        GalaxyColors.cosmicBlue,
                        GalaxyColors.auroraGreen,
                      ],
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          context
                              .read<AuthBloc>()
                              .add(AuthPasswordResetRequested(_emailCtrl.text));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
