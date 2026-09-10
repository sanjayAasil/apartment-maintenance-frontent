import 'package:apartment_maintenance_frontent/core/widgets/app_shell.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
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
