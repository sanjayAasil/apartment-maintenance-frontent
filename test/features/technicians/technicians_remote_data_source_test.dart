import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/features/technicians/data/datasources/technicians_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'technician_fakes.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late TechniciansRemoteDataSourceImpl remote;
  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    adapter = DioAdapter(dio: dio);
    remote = TechniciansRemoteDataSourceImpl(dio);
  });

  test('parses filtered technician and available lists', () async {
    adapter.onGet(
      ApiPaths.technicians,
      (server) => server.reply(200, {
        'data': [technicianJson],
        'meta': {'page': 1, 'limit': 20, 'total': 1},
      }),
      queryParameters: {
        'search': 'Tara',
        'isActive': true,
        'isAvailable': true,
        'categoryId': 'category-1',
        'page': 1,
        'limit': 20,
      },
    );
    adapter.onGet(
      ApiPaths.availableTechnicians,
      (server) => server.reply(200, [technicianJson]),
      queryParameters: {'categoryId': 'category-1'},
    );
    final result = await remote.getTechnicians(
      const TechnicianQuery(
        search: 'Tara',
        isActive: true,
        isAvailable: true,
        categoryId: 'category-1',
      ),
    );
    expect(result.items.single.skills.single.category.name, 'Plumbing');
    expect(
      (await remote.getAvailableTechnicians('category-1')).single.id,
      'technician-1',
    );
  });

  test('maps profile, mutation, and skill paths and payloads', () async {
    adapter.onGet(
      ApiPaths.technician('technician-1'),
      (server) => server.reply(200, technicianJson),
    );
    adapter.onGet(
      ApiPaths.currentTechnician,
      (server) => server.reply(200, technicianJson),
    );
    adapter.onPost(
      ApiPaths.technicians,
      (server) => server.reply(201, technicianJson),
      data: {'userId': 'user-1', 'phone': '9876543210', 'experienceYears': 3},
    );
    adapter.onPatch(
      ApiPaths.technician('technician-1'),
      (server) => server.reply(200, technicianJson),
      data: {'phone': '9876543210', 'experienceYears': 3},
    );
    adapter.onPatch(
      ApiPaths.technicianStatus('technician-1'),
      (server) => server.reply(200, technicianJson),
      data: {'isActive': false},
    );
    adapter.onPatch(
      ApiPaths.technicianAvailability('technician-1'),
      (server) => server.reply(200, technicianJson),
      data: {'isAvailable': false},
    );
    adapter.onGet(
      ApiPaths.technicianSkills('technician-1'),
      (server) => server.reply(200, [skillJson]),
    );
    adapter.onPost(
      ApiPaths.technicianSkills('technician-1'),
      (server) => server.reply(201, skillJson),
      data: {'categoryId': 'category-1'},
    );
    adapter.onDelete(
      ApiPaths.technicianSkill('technician-1', 'category-1'),
      (server) => server.reply(204, null),
    );

    await remote.getTechnician('technician-1');
    await remote.getCurrentTechnician();
    await remote.createTechnician('user-1', '9876543210', 3);
    await remote.updateTechnician('technician-1', '9876543210', 3);
    await remote.updateStatus('technician-1', false);
    await remote.updateAvailability('technician-1', false);
    expect(
      (await remote.getSkills('technician-1')).single.categoryId,
      'category-1',
    );
    await remote.addSkill('technician-1', 'category-1');
    await remote.removeSkill('technician-1', 'category-1');
  });
}
