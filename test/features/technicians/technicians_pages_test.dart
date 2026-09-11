import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/paged_technicians.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/add_technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/create_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_technicians.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/remove_technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_availability.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_status.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_mutation_cubit.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technicians_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/pages/technician_details_page.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/pages/technician_form_page.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/pages/technicians_page.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/paged_users.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'technician_fakes.dart';

class MockGetTechnicians extends Mock implements GetTechnicians {}

class MockGetTechnician extends Mock implements GetTechnician {}

class MockGetUsers extends Mock implements GetUsers {}

class MockGetCategories extends Mock implements GetMaintenanceCategories {}

class MockCreate extends Mock implements CreateTechnician {}

class MockUpdate extends Mock implements UpdateTechnician {}

class MockStatus extends Mock implements UpdateTechnicianStatus {}

class MockAvailability extends Mock implements UpdateTechnicianAvailability {}

class MockAddSkill extends Mock implements AddTechnicianSkill {}

class MockRemoveSkill extends Mock implements RemoveTechnicianSkill {}

void registerMutation() {
  final getUsers = MockGetUsers();
  final getCategories = MockGetCategories();
  when(() => getUsers(any())).thenAnswer(
    (_) async => const PagedUsers(
      items: [technicianUser],
      total: 1,
      page: 1,
      pageSize: 100,
    ),
  );
  when(() => getCategories(any())).thenAnswer(
    (_) async => const PagedMaintenanceCategories(
      items: [technicianCategory],
      total: 1,
      page: 1,
      pageSize: 100,
    ),
  );
  getIt.registerFactory<TechnicianMutationCubit>(
    () => TechnicianMutationCubit(
      getUsers,
      getCategories,
      MockCreate(),
      MockUpdate(),
      MockStatus(),
      MockAvailability(),
      MockAddSkill(),
      MockRemoveSkill(),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const TechnicianQuery());
    registerFallbackValue(const UserQuery());
    registerFallbackValue(const MaintenanceCategoryQuery());
  });
  tearDown(() async => getIt.reset());

  testWidgets('shows technician list loading', (tester) async {
    final get = MockGetTechnicians();
    final pending = Completer<PagedTechnicians>();
    when(() => get(any())).thenAnswer((_) => pending.future);
    getIt.registerFactory<TechniciansListBloc>(() => TechniciansListBloc(get));
    registerMutation();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TechniciansPage())),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows loaded technicians and skills', (tester) async {
    final get = MockGetTechnicians();
    when(() => get(any())).thenAnswer(
      (_) async => const PagedTechnicians(
        items: [technician],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    getIt.registerFactory<TechniciansListBloc>(() => TechniciansListBloc(get));
    registerMutation();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TechniciansPage())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tara Technician'), findsOneWidget);
    expect(find.textContaining('Plumbing'), findsOneWidget);
  });

  testWidgets('shows technician empty and error states', (tester) async {
    final get = MockGetTechnicians();
    when(() => get(any())).thenAnswer(
      (_) async =>
          const PagedTechnicians(items: [], total: 0, page: 1, pageSize: 20),
    );
    getIt.registerFactory<TechniciansListBloc>(() => TechniciansListBloc(get));
    registerMutation();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TechniciansPage())),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No technicians match the selected filters.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await getIt.reset();
    final failed = MockGetTechnicians();
    when(() => failed(any())).thenThrow(
      const Failure(kind: FailureKind.server, message: 'Technicians failed'),
    );
    getIt.registerFactory<TechniciansListBloc>(
      () => TechniciansListBloc(failed),
    );
    registerMutation();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TechniciansPage())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Technicians failed'), findsOneWidget);
  });

  testWidgets('validates required technician form fields', (tester) async {
    registerMutation();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TechnicianFormPage())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveTechnicianButton')));
    await tester.pump();
    expect(find.text('Select a technician user.'), findsOneWidget);
    expect(find.text('Phone is required.'), findsOneWidget);
    expect(find.text('Enter a whole number.'), findsOneWidget);
  });

  testWidgets('shows technician skill management UI', (tester) async {
    final get = MockGetTechnician();
    when(() => get('technician-1')).thenAnswer((_) async => technician);
    getIt.registerFactory<TechnicianDetailsBloc>(
      () => TechnicianDetailsBloc(get),
    );
    registerMutation();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TechnicianDetailsPage(technicianId: 'technician-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Plumbing'), findsOneWidget);
    expect(find.byKey(const Key('technicianSkillSelector')), findsOneWidget);
  });
}
