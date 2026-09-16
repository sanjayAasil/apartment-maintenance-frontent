import 'package:apartment_maintenance_frontent/app/theme/app_theme.dart';
import 'package:apartment_maintenance_frontent/core/widgets/app_shell.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  for (final user in [
    residentUser,
    const AppUser(
      id: 'tech',
      name: 'Technician',
      email: 'tech@example.com',
      role: UserRole.technician,
      isActive: true,
    ),
  ]) {
    testWidgets('shell preserves ${user.role.name} navigation restrictions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = MockAuthBloc();
      when(
        () => auth.state,
      ).thenReturn(AuthState(status: AuthStatus.authenticated, user: user));
      when(() => auth.stream).thenAnswer((_) => const Stream.empty());
      final router = GoRouter(
        routes: [
          ShellRoute(
            builder: (_, _, child) => AppShell(child: child),
            routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: auth,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final adminLabel in [
        'Dashboard',
        'Users',
        'Residents',
        'Technicians',
        'Categories',
        'Parts',
      ]) {
        expect(find.text(adminLabel), findsNothing);
      }
      expect(
        find.text(user.role == UserRole.technician ? 'My Jobs' : 'My Requests'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('does not crash while sign-out clears the current user', (
    tester,
  ) async {
    final authBloc = MockAuthBloc();
    when(
      () => authBloc.state,
    ).thenReturn(const AuthState(status: AuthStatus.unauthenticated));
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => const SizedBox()),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(AppShell), findsOneWidget);
  });
}
