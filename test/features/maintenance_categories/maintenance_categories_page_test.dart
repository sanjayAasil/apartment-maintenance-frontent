import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/create_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category_status.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_categories_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_category_form_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/pages/maintenance_categories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_category_fakes.dart';

class MockGetCategories extends Mock implements GetMaintenanceCategories {}

class MockGetCategory extends Mock implements GetMaintenanceCategory {}

class MockCreateCategory extends Mock implements CreateMaintenanceCategory {}

class MockUpdateCategory extends Mock implements UpdateMaintenanceCategory {}

class MockUpdateCategoryStatus extends Mock
    implements UpdateMaintenanceCategoryStatus {}

void registerDependencies(GetMaintenanceCategories getCategories) {
  getIt.registerFactory<MaintenanceCategoriesListBloc>(
    () => MaintenanceCategoriesListBloc(getCategories),
  );
  getIt.registerFactory<MaintenanceCategoryFormCubit>(
    () => MaintenanceCategoryFormCubit(
      MockGetCategory(),
      MockCreateCategory(),
      MockUpdateCategory(),
      MockUpdateCategoryStatus(),
    ),
  );
}

void main() {
  setUpAll(() => registerFallbackValue(const MaintenanceCategoryQuery()));
  tearDown(() async => getIt.reset());

  testWidgets('shows category list loading', (tester) async {
    final getCategories = MockGetCategories();
    final pending = Completer<PagedMaintenanceCategories>();
    when(() => getCategories(any())).thenAnswer((_) => pending.future);
    registerDependencies(getCategories);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MaintenanceCategoriesPage())),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows loaded categories', (tester) async {
    final getCategories = MockGetCategories();
    when(() => getCategories(any())).thenAnswer(
      (_) async => const PagedMaintenanceCategories(
        items: [maintenanceCategory],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    registerDependencies(getCategories);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MaintenanceCategoriesPage())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Plumbing'), findsOneWidget);
    expect(
      find.textContaining('Water and pipe related maintenance'),
      findsOneWidget,
    );
  });

  testWidgets('shows category empty state', (tester) async {
    final getCategories = MockGetCategories();
    when(() => getCategories(any())).thenAnswer(
      (_) async => const PagedMaintenanceCategories(
        items: [],
        total: 0,
        page: 1,
        pageSize: 20,
      ),
    );
    registerDependencies(getCategories);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MaintenanceCategoriesPage())),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('No categories match the selected filters.'),
      findsOneWidget,
    );
  });

  testWidgets('shows category error state', (tester) async {
    final getCategories = MockGetCategories();
    when(() => getCategories(any())).thenThrow(
      const Failure(kind: FailureKind.server, message: 'Categories failed'),
    );
    registerDependencies(getCategories);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MaintenanceCategoriesPage())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Categories failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
