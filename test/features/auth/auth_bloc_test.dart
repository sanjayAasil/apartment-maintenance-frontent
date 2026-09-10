import 'package:apartment_maintenance_frontent/core/network/session_coordinator.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/auth_session.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/login.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/logout.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/restore_session.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockLogin extends Mock implements Login {}

class MockRestore extends Mock implements RestoreSession {}

class MockLogout extends Mock implements Logout {}

class MockSessions extends Mock implements SessionCoordinator {}

void main() {
  late MockLogin login;
  late MockRestore restore;
  late MockLogout logout;
  late MockSessions sessions;

  setUp(() {
    login = MockLogin();
    restore = MockRestore();
    logout = MockLogout();
    sessions = MockSessions();
    when(() => sessions.invalidations).thenAnswer((_) => const Stream.empty());
  });

  AuthBloc build() => AuthBloc(login, restore, logout, sessions);

  blocTest<AuthBloc, AuthState>(
    'restores an authenticated session',
    build: () {
      when(restore.call).thenAnswer((_) async => adminUser);
      return build();
    },
    act: (bloc) => bloc.add(const AuthRestoreRequested()),
    expect: () => const [
      AuthState(status: AuthStatus.restoring),
      AuthState(status: AuthStatus.authenticated, user: adminUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'logs in and exposes current user',
    build: () {
      when(() => login('admin@example.com', 'password')).thenAnswer(
        (_) async => const AuthSession(accessToken: 'jwt', user: adminUser),
      );
      return build();
    },
    act: (bloc) => bloc.add(
      const AuthLoginRequested(
        email: 'admin@example.com',
        password: 'password',
      ),
    ),
    expect: () => const [
      AuthState(status: AuthStatus.authenticating),
      AuthState(status: AuthStatus.authenticated, user: adminUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'clears authentication on logout',
    build: () {
      when(logout.call).thenAnswer((_) async {});
      return build();
    },
    seed: () =>
        const AuthState(status: AuthStatus.authenticated, user: adminUser),
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => const [AuthState(status: AuthStatus.unauthenticated)],
  );
}
