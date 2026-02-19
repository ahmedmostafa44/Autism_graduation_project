// lib/features/auth/bloc/auth_state.dart
import 'package:equatable/equatable.dart';

enum AuthStatus { authenticated, unauthenticated, loading, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userEmail;
  final String? errorMessage;

  const AuthState._({
    this.status = AuthStatus.unauthenticated,
    this.userEmail,
    this.errorMessage,
  });

  const AuthState.unauthenticated() : this._();
  
  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.authenticated(String email) 
      : this._(status: AuthStatus.authenticated, userEmail: email);

  const AuthState.failure(String message) 
      : this._(status: AuthStatus.failure, errorMessage: message);

  @override
  List<Object?> get props => [status, userEmail, errorMessage];
}