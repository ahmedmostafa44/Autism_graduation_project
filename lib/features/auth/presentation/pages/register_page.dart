import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:autism_app/core/theme/app_theme.dart';
import 'package:autism_app/core/bloc/theme_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _parentCtrl = TextEditingController();
  final _childCtrl = TextEditingController();
  int _childAge = 6;
  int _step = 0; // 0 = account info, 1 = family info

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _parentCtrl.dispose();
    _childCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _step = 1);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignUpRequested(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          parentName: _parentCtrl.text,
          childName: _childCtrl.text,
          childAge: _childAge,
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
                  const SizedBox(height: 20),
                  // Back button
                  GestureDetector(
                    onTap: () {
                      if (_step == 1) {
                        setState(() => _step = 0);
                      } else {
                        context.pop();
                      }
                    },
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
                  const SizedBox(height: 24),

                  // Step indicator
                  Row(
                    children: [
                      _StepDot(active: _step == 0, done: _step > 0),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: _step > 0
                              ? GalaxyColors.nebulaViolet
                              : GalaxyColors.border(isDark),
                        ),
                      ),
                      _StepDot(active: _step == 1, done: false),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    _step == 0 ? 'Create Account ' : 'Family Info ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: GalaxyColors.textPrimary(isDark),
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _step == 0
                        ? 'Set up your secure account'
                        : 'Tell us about your family',
                    style: TextStyle(
                      fontSize: 14,
                      color: GalaxyColors.textSecond(isDark),
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Step 0: Account ──
                  if (_step == 0) ...[
                    GalaxyTextField(
                      hint: 'Email address',
                      icon: Icons.email_outlined,
                      controller: _emailCtrl,
                      isDark: isDark,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter email';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    GalaxyTextField(
                      hint: 'Password (min 6 chars)',
                      icon: Icons.lock_outline_rounded,
                      controller: _passCtrl,
                      isDark: isDark,
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter password';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    GalaxyTextField(
                      hint: 'Confirm password',
                      icon: Icons.lock_rounded,
                      controller: _confirmCtrl,
                      isDark: isDark,
                      isPassword: true,
                      validator: (v) {
                        if (v != _passCtrl.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    GalaxyButton(
                      label: 'Next →',
                      onTap: _nextStep,
                    ),
                  ],

                  // ── Step 1: Family ──
                  if (_step == 1) ...[
                    GalaxyTextField(
                      hint: "Parent's name",
                      icon: Icons.person_outline_rounded,
                      controller: _parentCtrl,
                      isDark: isDark,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 14),
                    GalaxyTextField(
                      hint: "Child's name",
                      icon: Icons.child_care_rounded,
                      controller: _childCtrl,
                      isDark: isDark,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Enter child's name" : null,
                    ),
                    const SizedBox(height: 18),
                    // Age selector
                    Text("Child's Age",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: GalaxyColors.textSecond(isDark),
                          fontFamily: 'Nunito',
                        )),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(10, (i) {
                        final age = i + 3;
                        final selected = age == _childAge;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _childAge = age),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? const LinearGradient(colors: [
                                        GalaxyColors.nebulaPurple,
                                        GalaxyColors.cosmicBlue
                                      ])
                                    : null,
                                color: selected
                                    ? null
                                    : GalaxyColors.surface(isDark),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? Colors.transparent
                                      : GalaxyColors.border(isDark),
                                ),
                              ),
                              child: Center(
                                child: Text('$age',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : GalaxyColors.textSecond(isDark),
                                      fontFamily: 'Nunito',
                                    )),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => GalaxyButton(
                        label: 'Create Account ',
                        loading: state is AuthOperationInProgress,
                        onTap: _submit,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            color: GalaxyColors.textSecond(isDark),
                            fontFamily: 'Nunito',
                          ),
                          children: const [
                            TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Sign in',
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

class _StepDot extends StatelessWidget {
  final bool active, done;
  const _StepDot({required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: (active || done)
            ? const LinearGradient(
                colors: [GalaxyColors.nebulaPurple, GalaxyColors.cosmicBlue])
            : null,
        color: (!active && !done) ? Colors.grey.withOpacity(0.2) : null,
        boxShadow: (active || done)
            ? [
                BoxShadow(
                    color: GalaxyColors.nebulaPurple.withOpacity(0.5),
                    blurRadius: 10)
              ]
            : null,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : Text(active ? '●' : '○',
                style: TextStyle(
                  color: (active || done) ? Colors.white : Colors.grey,
                  fontSize: 12,
                )),
      ),
    );
  }
}
