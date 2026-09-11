import 'package:apartment_maintenance_frontent/core/routing/app_redirector.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  test('preserves a direct URL while restoring authentication', () {
    final redirect = appRedirect(
      const AuthState(status: AuthStatus.restoring),
      Uri.parse('/apartments/abc/edit?source=bookmark'),
    );

    expect(
      redirect,
      '/startup?from=%2Fapartments%2Fabc%2Fedit%3Fsource%3Dbookmark',
    );
  });

  test('returns to a direct URL after restoring an authenticated user', () {
    final redirect = appRedirect(
      const AuthState(status: AuthStatus.authenticated, user: adminUser),
      Uri.parse('/startup?from=%2Fapartments%2Fabc%2Fedit%3Fsource%3Dbookmark'),
    );

    expect(redirect, '/apartments/abc/edit?source=bookmark');
  });

  test('carries a direct URL from startup through login', () {
    final redirect = appRedirect(
      const AuthState(status: AuthStatus.unauthenticated),
      Uri.parse('/startup?from=%2Fapartments'),
    );

    expect(redirect, '/login?from=%2Fapartments');
  });

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

  test('allows residents to view apartments but not mutate them', () {
    final state = const AuthState(
      status: AuthStatus.authenticated,
      user: residentUser,
    );
    expect(appRedirect(state, Uri.parse('/apartments')), isNull);
    expect(appRedirect(state, Uri.parse('/apartments/new')), '/forbidden');
    expect(appRedirect(state, Uri.parse('/apartments/one/edit')), '/forbidden');
  });

  test('allows admins to access resident management', () {
    final state = const AuthState(
      status: AuthStatus.authenticated,
      user: adminUser,
    );
    expect(appRedirect(state, Uri.parse('/residents')), isNull);
    expect(appRedirect(state, Uri.parse('/residents/new')), isNull);
    expect(appRedirect(state, Uri.parse('/residents/one/edit')), isNull);
  });

  test('allows residents only their own resident profile route', () {
    final state = const AuthState(
      status: AuthStatus.authenticated,
      user: residentUser,
    );
    expect(appRedirect(state, Uri.parse('/resident/profile')), isNull);
    expect(appRedirect(state, Uri.parse('/residents')), '/forbidden');
    expect(appRedirect(state, Uri.parse('/residents/one')), '/forbidden');
  });

  test('prevents technicians from accessing resident routes', () {
    const technician = AppUser(
      id: 'technician-1',
      name: 'Tech User',
      email: 'tech@example.com',
      role: UserRole.technician,
      isActive: true,
    );
    const state = AuthState(status: AuthStatus.authenticated, user: technician);
    expect(appRedirect(state, Uri.parse('/residents')), '/forbidden');
    expect(appRedirect(state, Uri.parse('/resident/profile')), '/forbidden');
  });

  test('allows only admins to access category management routes', () {
    const adminState = AuthState(
      status: AuthStatus.authenticated,
      user: adminUser,
    );
    const residentState = AuthState(
      status: AuthStatus.authenticated,
      user: residentUser,
    );
    const technician = AppUser(
      id: 'technician-1',
      name: 'Tech User',
      email: 'tech@example.com',
      role: UserRole.technician,
      isActive: true,
    );
    const technicianState = AuthState(
      status: AuthStatus.authenticated,
      user: technician,
    );

    expect(
      appRedirect(adminState, Uri.parse('/maintenance-categories')),
      isNull,
    );
    expect(
      appRedirect(residentState, Uri.parse('/maintenance-categories')),
      '/forbidden',
    );
    expect(
      appRedirect(technicianState, Uri.parse('/maintenance-categories/new')),
      '/forbidden',
    );
  });

  test('enforces technician management and self-profile routes', () {
    const technician = AppUser(
      id: 'technician-1',
      name: 'Tech User',
      email: 'tech@example.com',
      role: UserRole.technician,
      isActive: true,
    );
    const adminState = AuthState(
      status: AuthStatus.authenticated,
      user: adminUser,
    );
    const technicianState = AuthState(
      status: AuthStatus.authenticated,
      user: technician,
    );
    const residentState = AuthState(
      status: AuthStatus.authenticated,
      user: residentUser,
    );

    expect(appRedirect(adminState, Uri.parse('/technicians')), isNull);
    expect(appRedirect(adminState, Uri.parse('/technicians/new')), isNull);
    expect(
      appRedirect(technicianState, Uri.parse('/technicians')),
      '/forbidden',
    );
    expect(
      appRedirect(technicianState, Uri.parse('/technician/profile')),
      isNull,
    );
    expect(appRedirect(residentState, Uri.parse('/technicians')), '/forbidden');
    expect(
      appRedirect(residentState, Uri.parse('/technician/profile')),
      '/forbidden',
    );
  });
}
