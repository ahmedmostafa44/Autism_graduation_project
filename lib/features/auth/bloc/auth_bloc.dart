// lib/features/auth/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState.unauthenticated()) {
    
    // Check if user is already logged in (e.g. from SharedPreferences)
    on<AuthCheckRequested>((event, emit) async {
      // Logic for persisting session goes here
      emit(const AuthState.unauthenticated());
    });

    // Handle Login
    on<LoginRequested>((event, emit) async {
      emit(const AuthState.loading());
      
      try {
        // Replace this with your actual API/Firebase call
        await Future.delayed(const Duration(seconds: 2)); 
        
        if (event.email.isNotEmpty && event.password.length > 5) {
          emit(AuthState.authenticated(event.email));
        } else {
          emit(const AuthState.failure("Invalid credentials"));
        }
      } catch (e) {
        emit(AuthState.failure(e.toString()));
      }
    });

    // Handle Logout
    on<LogoutRequested>((event, emit) {
      emit(const AuthState.unauthenticated());
    });
  }
}