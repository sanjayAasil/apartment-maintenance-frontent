import 'dart:async';

import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/core/network/session_coordinator.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/login.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/logout.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/restore_session.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class AuthRestoreRequested extends AuthEvent {
  const AuthRestoreRequested();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object> get props => [email, password];
}

final class AuthUserAuthenticated extends AuthEvent {
  const AuthUserAuthenticated(this.user);
  final AppUser user;
  @override
  List<Object> get props => [user];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class _AuthInvalidated extends AuthEvent {
  const _AuthInvalidated();
}

enum AuthStatus {
  initial,
  restoring,
  authenticating,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.user, this.failure});
  final AuthStatus status;
  final AppUser? user;
  final Failure? failure;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user, failure];
}

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._login,
    this._restore,
    this._logout,
    SessionCoordinator sessions,
  ) : super(const AuthState()) {
    on<AuthRestoreRequested>(_onRestore);
    on<AuthLoginRequested>(_onLogin);
    on<AuthUserAuthenticated>(
      (event, emit) =>
          emit(AuthState(status: AuthStatus.authenticated, user: event.user)),
    );
    on<AuthLogoutRequested>(_onLogout);
    on<_AuthInvalidated>(
      (_, emit) => emit(const AuthState(status: AuthStatus.unauthenticated)),
    );
    _invalidations = sessions.invalidations.listen(
      (_) => add(const _AuthInvalidated()),
    );
  }

  final Login _login;
  final RestoreSession _restore;
  final Logout _logout;
  late final StreamSubscription<void> _invalidations;

  Future<void> _onRestore(
    AuthRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.restoring));
    try {
      final user = await _restore();
      emit(
        AuthState(
          status: user == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: user,
        ),
      );
    } catch (error) {
      emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState(status: AuthStatus.authenticating));
    try {
      final session = await _login(event.email, event.password);
      emit(AuthState(status: AuthStatus.authenticated, user: session.user));
    } catch (error) {
      emit(
        AuthState(
          status: AuthStatus.unauthenticated,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> close() async {
    await _invalidations.cancel();
    return super.close();
  }
}
