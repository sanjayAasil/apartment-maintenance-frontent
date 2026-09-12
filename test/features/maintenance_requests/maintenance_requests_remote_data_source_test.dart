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

  test('uses exact assignment and history contracts', () async {
    adapter.onGet(
      ApiPaths.maintenanceRequestAssignment('request-1'),
      (server) => server.reply(200, maintenanceAssignmentJson),
    );
    adapter.onGet(
      ApiPaths.maintenanceRequestAssignmentHistory('request-1'),
      (server) => server.reply(200, [maintenanceAssignmentJson]),
    );
    adapter.onPost(
      ApiPaths.maintenanceRequestAssign('request-1'),
      (server) => server.reply(201, maintenanceAssignmentJson),
      data: {'technicianId': 'technician-1'},
    );
    adapter.onPatch(
      ApiPaths.maintenanceRequestAssignment('request-1'),
      (server) => server.reply(200, maintenanceAssignmentJson),
      data: {'technicianId': 'technician-2'},
    );
    adapter.onDelete(
      ApiPaths.maintenanceRequestAssignment('request-1'),
      (server) => server.reply(204, null),
    );

    expect(
      (await remote.getCurrentAssignment('request-1')).technician.user.name,
      'Tara Technician',
    );
    expect(await remote.getAssignmentHistory('request-1'), hasLength(1));
    await remote.assignTechnician('request-1', 'technician-1');
    await remote.reassignTechnician('request-1', 'technician-2');
    await remote.unassignTechnician('request-1');
  });

  test('parses comments and maintenance audit history contracts', () async {
    adapter.onGet(
      ApiPaths.maintenanceRequestComments('request-1'),
      (server) => server.reply(200, [maintenanceCommentJson]),
    );
    adapter.onPost(
      ApiPaths.maintenanceRequestComments('request-1'),
      (server) => server.reply(201, maintenanceCommentJson),
      data: {'message': 'The leak is getting worse.'},
    );
    adapter.onGet(
      ApiPaths.maintenanceRequestHistory('request-1'),
      (server) => server.reply(200, [maintenanceHistoryJson]),
    );

    final comments = await remote.getComments('request-1');
    expect(comments.single.author.name, 'Riya Resident');
    expect(
      (await remote.addComment(
        'request-1',
        'The leak is getting worse.',
      )).message,
      'The leak is getting worse.',
    );
    final history = await remote.getHistory('request-1');
    expect(history.single.oldValue, 'ASSIGNED');
    expect(history.single.newValue, 'IN_PROGRESS');
  });
}
