import 'package:apartment_maintenance_frontent/core/routing/app_redirector.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  test(
    'sends unauthenticated deep link to login and preserves destination',
    () {
      final redirect = appRedirect(
        const AuthState(status: AuthStatus.unauthenticated),
        Uri.parse('/users/admin-1'),
      );
      expect(redirect, '/login?from=%2Fusers%2Fadmin-1');
    },
  );

  test('sends non-admin user away from users routes', () {
    final redirect = appRedirect(
      const AuthState(status: AuthStatus.authenticated, user: residentUser),
      Uri.parse('/users'),
    );
    expect(redirect, '/forbidden');
  });

  test('allows admin user routes', () {
    final redirect = appRedirect(
      const AuthState(status: AuthStatus.authenticated, user: adminUser),
      Uri.parse('/users'),
    );
    expect(redirect, isNull);
  });
}
