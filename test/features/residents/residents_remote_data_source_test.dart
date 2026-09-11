import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/features/residents/data/datasources/residents_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'resident_fakes.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ResidentsRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    adapter = DioAdapter(dio: dio);
    remote = ResidentsRemoteDataSourceImpl(dio);
  });

  test(
    'parses paginated resident list with nested user and apartment',
    () async {
      adapter.onGet(
        ApiPaths.residents,
        (server) => server.reply(200, {
          'data': [residentJson],
          'meta': {'page': 1, 'limit': 20, 'total': 1},
        }),
        queryParameters: {'page': 1, 'limit': 20},
      );

      final result = await remote.getResidents(const ResidentQuery());

      expect(result.items.single.user.name, 'Ravi Resident');
      expect(result.items.single.apartment.unitNumber, '204');
      expect(result.total, 1);
    },
  );

  test(
    'gets a resident and the current profile from their exact paths',
    () async {
      adapter.onGet(
        ApiPaths.resident('resident-1'),
        (server) => server.reply(200, residentJson),
      );
      adapter.onGet(
        ApiPaths.currentResident,
        (server) => server.reply(200, residentJson),
      );
      expect((await remote.getResident('resident-1')).id, 'resident-1');
      expect((await remote.getCurrentResident()).id, 'resident-1');
    },
  );

  test('maps create and update request bodies to the API contract', () async {
    adapter.onPost(
      ApiPaths.residents,
      (server) => server.reply(201, residentJson),
      data: {
        'userId': 'user-1',
        'apartmentId': 'apartment-1',
        'phone': '9876543210',
        'moveInDate': '2026-09-01',
      },
    );
    adapter.onPatch(
      ApiPaths.resident('resident-1'),
      (server) => server.reply(200, residentJson),
      data: {'phone': '9876543210', 'moveInDate': '2026-09-01'},
    );

    await remote.createResident(
      'user-1',
      'apartment-1',
      '9876543210',
      '2026-09-01',
    );
    await remote.updateResident('resident-1', '9876543210', '2026-09-01');
  });
}
