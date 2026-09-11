import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_categories_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/paged_maintenance_requests.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_requests.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_requests_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/pages/maintenance_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';
import '../technicians/technician_fakes.dart';
import 'maintenance_request_fakes.dart';

class MockGetRequests extends Mock implements GetMaintenanceRequests {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockGetCategories extends Mock implements GetMaintenanceCategories {}

void main() {
  late MockAuthBloc authBloc;
  setUpAll(() {
    registerFallbackValue(const MaintenanceRequestQuery());
    registerFallbackValue(const MaintenanceCategoryQuery());
  });
  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(
      const AuthState(status: AuthStatus.authenticated, user: residentUser),
    );
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });
  tearDown(() async => getIt.reset());

  Widget app(GetMaintenanceRequests get, {AppUser? user}) {
    when(() => authBloc.state).thenReturn(
      AuthState(status: AuthStatus.authenticated, user: user ?? residentUser),
    );
    getIt.registerFactory<MaintenanceRequestsListBloc>(
      () => MaintenanceRequestsListBloc(get),
    );
    final getCategories = MockGetCategories();
    when(() => getCategories(any())).thenAnswer(
      (_) async => const PagedMaintenanceCategories(
        items: [],
        total: 0,
        page: 1,
        pageSize: 20,
      ),
    );
    getIt.registerFactory<MaintenanceCategoriesListBloc>(
      () => MaintenanceCategoriesListBloc(getCategories),
    );
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: const MaterialApp(home: Scaffold(body: MaintenanceRequestsPage())),
    );
  }

  testWidgets('shows request list loading', (tester) async {
    final get = MockGetRequests();
    final pending = Completer<PagedMaintenanceRequests>();
    when(() => get(any())).thenAnswer((_) => pending.future);
    await tester.pumpWidget(app(get));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows loaded requests', (tester) async {
    final get = MockGetRequests();
    when(() => get(any())).thenAnswer(
      (_) async => PagedMaintenanceRequests(
        items: [maintenanceRequest],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    await tester.pumpWidget(app(get));
    await tester.pumpAndSettle();
    expect(find.text('Leaking kitchen tap'), findsOneWidget);
  });

  testWidgets('shows the assigned jobs experience to technicians', (
    tester,
  ) async {
    final get = MockGetRequests();
    when(() => get(any())).thenAnswer(
      (_) async => PagedMaintenanceRequests(
        items: [assignedMaintenanceRequest],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    await tester.pumpWidget(app(get, user: technicianUser));
    await tester.pumpAndSettle();
    expect(find.text('My Jobs'), findsOneWidget);
    expect(find.text('Leaking kitchen tap'), findsOneWidget);
    expect(find.text('New request'), findsNothing);
  });

  testWidgets('shows empty request state', (tester) async {
    final get = MockGetRequests();
    when(() => get(any())).thenAnswer(
      (_) async => const PagedMaintenanceRequests(
        items: [],
        total: 0,
        page: 1,
        pageSize: 20,
      ),
    );
    await tester.pumpWidget(app(get));
    await tester.pumpAndSettle();
    expect(
      find.text('No maintenance requests match these filters.'),
      findsOneWidget,
    );
  });

  testWidgets('shows request list errors', (tester) async {
    final get = MockGetRequests();
    when(() => get(any())).thenThrow(
      const Failure(kind: FailureKind.server, message: 'Requests failed'),
    );
    await tester.pumpWidget(app(get));
    await tester.pumpAndSettle();
    expect(find.text('Requests failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
