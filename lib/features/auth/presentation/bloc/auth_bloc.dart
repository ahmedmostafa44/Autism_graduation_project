import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc({AuthRepository? repo})
      : _repo = repo ?? AuthRepository(),
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthPasswordResetRequested>(_onPasswordReset);
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onCheck(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final profile = await _repo.fetchCurrentProfile();
      if (profile != null) {
        await _repo.touchLastActive();
        emit(AuthAuthenticated(profile));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignUp(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthOperationInProgress());
    try {
      final user = await _repo.signUp(
        email:      event.email,
        password:   event.password,
        parentName: event.parentName,
        childName:  event.childName,
        childAge:   event.childAge,
      );
      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_friendlyMessage(e)));
    } catch (e) {
      emit(AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthOperationInProgress());
    try {
      final user = await _repo.signIn(
        email:    event.email,
        password: event.password,
      );
      await _repo.touchLastActive();
      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_friendlyMessage(e)));
    } catch (e) {
      emit(AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _repo.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onPasswordReset(
      AuthPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthOperationInProgress());
    try {
      await _repo.sendPasswordReset(event.email);
      emit(AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_friendlyMessage(e)));
    }
  }

  // ── Firebase error → human-readable message ───────────────────────────────

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
