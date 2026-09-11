import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/datasources/maintenance_categories_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/models/maintenance_category_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/repositories/maintenance_categories_repository_impl.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_category_fakes.dart';

class MockRemote extends Mock
    implements MaintenanceCategoriesRemoteDataSource {}

void main() {
  setUpAll(() => registerFallbackValue(const MaintenanceCategoryQuery()));

  test('maps list models to domain entities', () async {
    final remote = MockRemote();
    when(() => remote.getCategories(any())).thenAnswer(
      (_) async => const PagedMaintenanceCategoryModels(
        items: [maintenanceCategoryModel],
        total: 1,
        page: 1,
        limit: 20,
      ),
    );
    final result = await MaintenanceCategoriesRepositoryImpl(
      remote,
    ).getCategories(const MaintenanceCategoryQuery());
    expect(result.items.single, maintenanceCategory);
  });

  test('preserves mapped duplicate conflicts', () async {
    final remote = MockRemote();
    when(() => remote.createCategory(any(), any())).thenThrow(
      const Failure(kind: FailureKind.conflict, message: 'Already exists'),
    );
    await expectLater(
      MaintenanceCategoriesRepositoryImpl(
        remote,
      ).createCategory(name: 'Plumbing'),
      throwsA(
        isA<Failure>().having(
          (error) => error.kind,
          'kind',
          FailureKind.conflict,
        ),
      ),
    );
  });
}
