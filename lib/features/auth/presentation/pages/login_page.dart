import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignInRequested(
          email: _emailCtrl.text,
          password: _passCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message,
                style: const TextStyle(fontFamily: 'Nunito')),
            backgroundColor: GalaxyColors.supernovaRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: GalaxyColors.bg(isDark),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // Logo + title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                GalaxyColors.nebulaPurple,
                                GalaxyColors.cosmicBlue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    GalaxyColors.nebulaPurple.withOpacity(0.6),
                                blurRadius: 28,
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.smart_toy_rounded,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 20),
                        Text('Welcome Back! ',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: GalaxyColors.textPrimary(isDark),
                              fontFamily: 'Nunito',
                            )),
                        const SizedBox(height: 6),
                        Text('Sign in to continue your journey',
                            style: TextStyle(
                              fontSize: 14,
                              color: GalaxyColors.textSecond(isDark),
                              fontFamily: 'Nunito',
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),

                  // Email
                  GalaxyTextField(
                    hint: 'Email address',
                    icon: Icons.email_outlined,
                    controller: _emailCtrl,
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Please enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  GalaxyTextField(
                    hint: 'Password',
                    icon: Icons.lock_outline_rounded,
                    controller: _passCtrl,
                    isDark: isDark,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Please enter your password';
                      if (v.length < 6) return 'Password too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.push('/forgot-password'),
                      child: Text('Forgot password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: GalaxyColors.nebulaViolet,
                            fontFamily: 'Nunito',
                          )),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Sign in button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => GalaxyButton(
                      label: 'Sign In ',
                      loading: state is AuthOperationInProgress,
                      onTap: _submit,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: GalaxyColors.border(isDark))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('or',
                            style: TextStyle(
                              color: GalaxyColors.textSecond(isDark),
                              fontFamily: 'Nunito',
                            )),
                      ),
                      Expanded(
                          child: Divider(color: GalaxyColors.border(isDark))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register link
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: GalaxyColors.surface(isDark),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: GalaxyColors.border(isDark), width: 1.5),
                      ),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: GalaxyColors.textSecond(isDark),
                              fontFamily: 'Nunito',
                            ),
                            children: const [
                              TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: 'Create one',
                                style: TextStyle(
                                  color: GalaxyColors.nebulaViolet,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
