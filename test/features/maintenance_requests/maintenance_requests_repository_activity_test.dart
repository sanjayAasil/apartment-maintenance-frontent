import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/datasources/maintenance_requests_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/models/maintenance_activity_models.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/repositories/maintenance_requests_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_request_fakes.dart';

class MockRemoteDataSource extends Mock
    implements MaintenanceRequestsRemoteDataSource {}

void main() {
  late MockRemoteDataSource remote;
  late MaintenanceRequestsRepositoryImpl repository;

  setUp(() {
    remote = MockRemoteDataSource();
    repository = MaintenanceRequestsRepositoryImpl(remote);
  });

  test('maps comment and history models to domain entities', () async {
    final commentModel = MaintenanceCommentModel.fromJson(
      maintenanceCommentJson,
    );
    final historyModel = MaintenanceHistoryEntryModel.fromJson(
      maintenanceHistoryJson,
    );
    when(
      () => remote.getComments('request-1'),
    ).thenAnswer((_) async => [commentModel]);
    when(
      () => remote.getHistory('request-1'),
    ).thenAnswer((_) async => [historyModel]);
    when(
      () => remote.addComment('request-1', 'Update'),
    ).thenAnswer((_) async => commentModel);

    expect(
      (await repository.getComments('request-1')).single.author.name,
      'Riya Resident',
    );
    expect(
      (await repository.getHistory('request-1')).single.oldValue,
      'ASSIGNED',
    );
    await repository.addComment('request-1', ' Update ');
    verify(() => remote.addComment('request-1', 'Update')).called(1);
  });

  test('maps comment API authorization errors', () async {
    when(() => remote.getComments('request-1')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/comments'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 403,
          data: {'message': 'You cannot access this maintenance request'},
        ),
      ),
    );
    await expectLater(
      repository.getComments('request-1'),
      throwsA(
        isA<Failure>().having(
          (failure) => failure.kind,
          'kind',
          FailureKind.forbidden,
        ),
      ),
    );
  });
}
