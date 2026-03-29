part of 'auth_bloc.dart';

abstract class AuthEvent {}

/// Check current Firebase auth state on app start
class AuthCheckRequested extends AuthEvent {}

/// Sign up with email + password + profile info
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String parentName;
  final String childName;
  final int    childAge;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.parentName,
    required this.childName,
    required this.childAge,
  });
}

/// Sign in with email + password
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignInRequested({required this.email, required this.password});
}

/// Sign out
class AuthSignOutRequested extends AuthEvent {}

/// Send password reset email
class AuthPasswordResetRequested extends AuthEvent {
  final String email;
  AuthPasswordResetRequested(this.email);
}
