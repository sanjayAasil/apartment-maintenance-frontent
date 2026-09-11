import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/residents/data/datasources/residents_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/residents/data/models/resident_model.dart';
import 'package:apartment_maintenance_frontent/features/residents/data/repositories/residents_repository_impl.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'resident_fakes.dart';

class MockResidentsRemote extends Mock implements ResidentsRemoteDataSource {}

void main() {
  late MockResidentsRemote remote;
  late ResidentsRepositoryImpl repository;

  setUp(() {
    remote = MockResidentsRemote();
    repository = ResidentsRepositoryImpl(remote);
  });

  test('maps paginated resident models to entities', () async {
    const query = ResidentQuery();
    when(() => remote.getResidents(query)).thenAnswer(
      (_) async => PagedResidentModels(
        items: [residentModel],
        total: 1,
        page: 1,
        limit: 20,
      ),
    );
    final result = await repository.getResidents(query);
    expect(result.items.single.user.name, 'Ravi Resident');
    expect(result.items.single.apartment.block, 'A');
  });

  test('maps get current, create, and update operations', () async {
    when(remote.getCurrentResident).thenAnswer((_) async => residentModel);
    when(
      () => remote.createResident(
        'user-1',
        'apartment-1',
        '9876543210',
        '2026-09-01',
      ),
    ).thenAnswer((_) async => residentModel);
    when(
      () => remote.updateResident('resident-1', '9876543210', '2026-09-01'),
    ).thenAnswer((_) async => residentModel);

    expect((await repository.getCurrentResident()).id, 'resident-1');
    await repository.createResident(
      userId: 'user-1',
      apartmentId: 'apartment-1',
      phone: ' 9876543210 ',
      moveInDate: '2026-09-01',
    );
    await repository.updateResident(
      id: 'resident-1',
      phone: '9876543210',
      moveInDate: '2026-09-01',
    );
  });

  test('maps Dio conflict errors to domain failures', () async {
    when(remote.getCurrentResident).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ApiPaths.currentResident),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: ApiPaths.currentResident),
          statusCode: 409,
          data: {'message': 'Resident conflict'},
        ),
      ),
    );
    await expectLater(
      repository.getCurrentResident(),
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
