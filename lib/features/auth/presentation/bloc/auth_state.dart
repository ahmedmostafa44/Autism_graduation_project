part of 'auth_bloc.dart';

abstract class AuthState {}

/// Initial — haven't checked Firebase yet
class AuthInitial extends AuthState {}

/// Checking Firebase auth state
class AuthLoading extends AuthState {}

/// Fully authenticated with profile loaded
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

/// Not logged in
class AuthUnauthenticated extends AuthState {}

/// Auth operation in progress (login / register)
class AuthOperationInProgress extends AuthState {}

/// Password reset email sent successfully
class AuthPasswordResetSent extends AuthState {}

/// Any error
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
