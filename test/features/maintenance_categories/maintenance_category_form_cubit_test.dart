import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/create_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category_status.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_category_form_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_category_fakes.dart';

class MockGetCategory extends Mock implements GetMaintenanceCategory {}

class MockCreateCategory extends Mock implements CreateMaintenanceCategory {}

class MockUpdateCategory extends Mock implements UpdateMaintenanceCategory {}

class MockUpdateCategoryStatus extends Mock
    implements UpdateMaintenanceCategoryStatus {}

MaintenanceCategoryFormCubit buildCubit({
  MockGetCategory? get,
  MockCreateCategory? create,
  MockUpdateCategory? update,
  MockUpdateCategoryStatus? status,
}) => MaintenanceCategoryFormCubit(
  get ?? MockGetCategory(),
  create ?? MockCreateCategory(),
  update ?? MockUpdateCategory(),
  status ?? MockUpdateCategoryStatus(),
);

void main() {
  blocTest<MaintenanceCategoryFormCubit, MaintenanceCategoryFormState>(
    'creates a category',
    build: () {
      final create = MockCreateCategory();
      when(
        () => create('Plumbing', 'Water'),
      ).thenAnswer((_) async => maintenanceCategory);
      return buildCubit(create: create);
    },
    act: (cubit) => cubit.create('Plumbing', 'Water'),
    verify: (cubit) =>
        expect(cubit.state.status, MaintenanceCategoryFormStatus.success),
  );

  blocTest<MaintenanceCategoryFormCubit, MaintenanceCategoryFormState>(
    'exposes duplicate create failures',
    build: () {
      final create = MockCreateCategory();
      when(() => create(any(), any())).thenThrow(
        const Failure(
          kind: FailureKind.conflict,
          message: 'Category already exists',
        ),
      );
      return buildCubit(create: create);
    },
    act: (cubit) => cubit.create('Plumbing', null),
    verify: (cubit) => expect(cubit.state.failure?.kind, FailureKind.conflict),
  );

  blocTest<MaintenanceCategoryFormCubit, MaintenanceCategoryFormState>(
    'updates category status',
    build: () {
      final status = MockUpdateCategoryStatus();
      when(() => status('category-1', false)).thenAnswer(
        (_) async => const MaintenanceCategory(
          id: 'category-1',
          name: 'Plumbing',
          isActive: false,
        ),
      );
      return buildCubit(status: status);
    },
    act: (cubit) => cubit.updateStatus('category-1', false),
    verify: (cubit) => expect(cubit.state.category?.isActive, false),
  );
}
