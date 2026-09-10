import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/network/session_coordinator.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/login.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/logout.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/register.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/restore_session.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/registration_cubit.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/pages/login_page.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLogin extends Mock implements Login {}

class MockRestore extends Mock implements RestoreSession {}

class MockLogout extends Mock implements Logout {}

class MockRegister extends Mock implements Register {}

class MockSessions extends Mock implements SessionCoordinator {}

AuthBloc makeAuthBloc() {
  final sessions = MockSessions();
  when(() => sessions.invalidations).thenAnswer((_) => const Stream.empty());
  return AuthBloc(MockLogin(), MockRestore(), MockLogout(), sessions);
}

void main() {
  tearDown(() async => getIt.reset());

  testWidgets('login form reports invalid email and password', (tester) async {
    final bloc = makeAuthBloc();
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.tap(find.byKey(const Key('loginSubmit')));
    await tester.pump();
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('registration form validates all required fields', (
    tester,
  ) async {
    getIt.registerFactory<RegistrationCubit>(
      () => RegistrationCubit(MockRegister()),
    );
    final bloc = makeAuthBloc();
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: RegisterPage()),
      ),
    );
    await tester.tap(find.byKey(const Key('registerSubmit')));
    await tester.pump();
    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });
}
