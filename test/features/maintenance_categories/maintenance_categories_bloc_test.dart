import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_categories_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_category_fakes.dart';

class MockGetMaintenanceCategories extends Mock
    implements GetMaintenanceCategories {}

void main() {
  setUpAll(() => registerFallbackValue(const MaintenanceCategoryQuery()));

  blocTest<MaintenanceCategoriesListBloc, MaintenanceCategoriesListState>(
    'loads categories successfully',
    build: () {
      final getCategories = MockGetMaintenanceCategories();
      when(() => getCategories(any())).thenAnswer(
        (_) async => const PagedMaintenanceCategories(
          items: [maintenanceCategory],
          total: 1,
          page: 1,
          pageSize: 20,
        ),
      );
      return MaintenanceCategoriesListBloc(getCategories);
    },
    act: (bloc) => bloc.add(const MaintenanceCategoriesRequested()),
    verify: (bloc) =>
        expect(bloc.state.status, MaintenanceCategoriesListStatus.success),
  );

  blocTest<MaintenanceCategoriesListBloc, MaintenanceCategoriesListState>(
    'emits empty for an empty category list',
    build: () {
      final getCategories = MockGetMaintenanceCategories();
      when(() => getCategories(any())).thenAnswer(
        (_) async => const PagedMaintenanceCategories(
          items: [],
          total: 0,
          page: 1,
          pageSize: 20,
        ),
      );
      return MaintenanceCategoriesListBloc(getCategories);
    },
    act: (bloc) => bloc.add(const MaintenanceCategoriesRequested()),
    verify: (bloc) =>
        expect(bloc.state.status, MaintenanceCategoriesListStatus.empty),
  );

  blocTest<MaintenanceCategoriesListBloc, MaintenanceCategoriesListState>(
    'maps category list failures',
    build: () {
      final getCategories = MockGetMaintenanceCategories();
      when(() => getCategories(any())).thenThrow(
        const Failure(kind: FailureKind.server, message: 'Categories failed'),
      );
      return MaintenanceCategoriesListBloc(getCategories);
    },
    act: (bloc) => bloc.add(const MaintenanceCategoriesRequested()),
    verify: (bloc) {
      expect(bloc.state.status, MaintenanceCategoriesListStatus.failure);
      expect(bloc.state.failure?.kind, FailureKind.server);
    },
  );
}
