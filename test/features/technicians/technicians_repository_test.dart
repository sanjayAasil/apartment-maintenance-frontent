import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/technicians/data/datasources/technicians_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/technicians/data/models/technician_model.dart';
import 'package:apartment_maintenance_frontent/features/technicians/data/repositories/technicians_repository_impl.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'technician_fakes.dart';

class MockRemote extends Mock implements TechniciansRemoteDataSource {}

void main() {
  setUpAll(() => registerFallbackValue(const TechnicianQuery()));

  test('maps technician lists and available category filters', () async {
    final remote = MockRemote();
    final model = TechnicianModel.fromJson(technicianJson);
    when(() => remote.getTechnicians(any())).thenAnswer(
      (_) async =>
          PagedTechnicianModels(items: [model], total: 1, page: 1, limit: 20),
    );
    when(
      () => remote.getAvailableTechnicians('category-1'),
    ).thenAnswer((_) async => [model]);
    final repository = TechniciansRepositoryImpl(remote);
    final listed = (await repository.getTechnicians(
      const TechnicianQuery(),
    )).items.single;
    final available = (await repository.getAvailableTechnicians(
      'category-1',
    )).single;
    expect(listed.id, technician.id);
    expect(listed.skills.single.category.name, 'Plumbing');
    expect(available.id, technician.id);
  });

  test('preserves skill conflict failures', () async {
    final remote = MockRemote();
    when(() => remote.addSkill(any(), any())).thenThrow(
      const Failure(
        kind: FailureKind.conflict,
        message: 'Skill already exists',
      ),
    );
    await expectLater(
      TechniciansRepositoryImpl(remote).addSkill('technician-1', 'category-1'),
      throwsA(
        isA<Failure>().having(
          (failure) => failure.kind,
          'kind',
          FailureKind.conflict,
        ),
      ),
    );
  });
}
