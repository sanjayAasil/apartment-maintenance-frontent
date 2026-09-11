import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/datasources/maintenance_requests_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'maintenance_request_fakes.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late MaintenanceRequestsRemoteDataSourceImpl remote;
  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    adapter = DioAdapter(dio: dio);
    remote = MaintenanceRequestsRemoteDataSourceImpl(dio);
  });

  test('parses a filtered paginated request list', () async {
    adapter.onGet(
      ApiPaths.maintenanceRequests,
      (server) => server.reply(200, {
        'data': [maintenanceRequestJson],
        'meta': {'page': 1, 'limit': 20, 'total': 1},
      }),
      queryParameters: {
        'search': 'leak',
        'status': 'OPEN',
        'priority': 'MEDIUM',
        'page': 1,
        'limit': 20,
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      },
    );
    final result = await remote.getRequests(
      const MaintenanceRequestQuery(
        search: 'leak',
        status: MaintenanceRequestStatus.open,
        priority: MaintenancePriority.medium,
      ),
    );
    expect(result.items.single.title, 'Leaking kitchen tap');
    expect(result.items.single.apartment.unitNumber, '204');
    expect(result.total, 1);
  });

  test('uses exact get, create, update, and status contracts', () async {
    adapter.onGet(
      ApiPaths.maintenanceRequest('request-1'),
      (server) => server.reply(200, maintenanceRequestJson),
    );
    adapter.onPost(
      ApiPaths.maintenanceRequests,
      (server) => server.reply(201, maintenanceRequestJson),
      data: {
        'categoryId': 'category-1',
        'title': 'Leaking kitchen tap',
        'description': 'The kitchen tap is leaking continuously.',
        'priority': 'MEDIUM',
      },
    );
    adapter.onPatch(
      ApiPaths.maintenanceRequest('request-1'),
      (server) => server.reply(200, maintenanceRequestJson),
      data: {'title': 'Updated title'},
    );
    adapter.onPatch(
      ApiPaths.maintenanceRequestStatus('request-1'),
      (server) => server.reply(200, maintenanceRequestJson),
      data: {'status': 'CANCELLED'},
    );
    expect(
      (await remote.getRequest('request-1')).status,
      MaintenanceRequestStatus.open,
    );
    await remote.createRequest(
      'category-1',
      'Leaking kitchen tap',
      'The kitchen tap is leaking continuously.',
      MaintenancePriority.medium,
    );
    await remote.updateRequest('request-1', title: 'Updated title');
    await remote.updateStatus('request-1', MaintenanceRequestStatus.cancelled);
  });
}
