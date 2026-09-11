import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/datasources/maintenance_categories_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'maintenance_category_fakes.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late MaintenanceCategoriesRemoteDataSourceImpl remote;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    adapter = DioAdapter(dio: dio);
    remote = MaintenanceCategoriesRemoteDataSourceImpl(dio);
  });

  test('parses a paginated category list and filters', () async {
    adapter.onGet(
      ApiPaths.maintenanceCategories,
      (server) => server.reply(200, {
        'data': [maintenanceCategoryJson],
        'meta': {'page': 1, 'limit': 20, 'total': 1},
      }),
      queryParameters: {
        'search': 'plumb',
        'isActive': true,
        'page': 1,
        'limit': 20,
      },
    );
    final result = await remote.getCategories(
      const MaintenanceCategoryQuery(search: 'plumb', isActive: true),
    );
    expect(result.items.single.name, 'Plumbing');
    expect(result.total, 1);
  });

  test('uses exact get, create, update, and status API contracts', () async {
    adapter.onGet(
      ApiPaths.maintenanceCategory('category-1'),
      (server) => server.reply(200, maintenanceCategoryJson),
    );
    adapter.onPost(
      ApiPaths.maintenanceCategories,
      (server) => server.reply(201, maintenanceCategoryJson),
      data: {'name': 'Plumbing', 'description': 'Water and pipes'},
    );
    adapter.onPatch(
      ApiPaths.maintenanceCategory('category-1'),
      (server) => server.reply(200, maintenanceCategoryJson),
      data: {'name': 'Plumbing', 'description': 'Water and pipes'},
    );
    adapter.onPatch(
      ApiPaths.maintenanceCategoryStatus('category-1'),
      (server) => server.reply(200, maintenanceCategoryJson),
      data: {'isActive': false},
    );
    expect((await remote.getCategory('category-1')).name, 'Plumbing');
    await remote.createCategory('Plumbing', 'Water and pipes');
    await remote.updateCategory('category-1', 'Plumbing', 'Water and pipes');
    await remote.updateCategoryStatus('category-1', false);
  });
}
