import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/features/parts/data/datasources/parts_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late PartsRemoteDataSourceImpl remote;
  final part = {
    'id': 'part-1',
    'name': 'Water Valve',
    'description': 'Bathroom valve',
    'quantity': 3,
    'unitPrice': '250.00',
    'minimumStock': 5,
    'isActive': true,
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    adapter = DioAdapter(dio: dio);
    remote = PartsRemoteDataSourceImpl(dio);
  });

  test('parses filtered paginated parts', () async {
    adapter.onGet(
      ApiPaths.parts,
      (server) => server.reply(200, {
        'data': [part],
        'meta': {'page': 1, 'limit': 20, 'total': 1},
      }),
      queryParameters: {
        'search': 'valve',
        'isActive': true,
        'lowStock': true,
        'page': 1,
        'limit': 20,
      },
    );
    final result = await remote.getParts(
      const PartQuery(search: 'valve', isActive: true, lowStock: true),
    );
    expect(result.items.single.name, 'Water Valve');
    expect(result.items.single.unitPrice, 250);
  });

  test('uses create, update, status, and stock contracts', () async {
    adapter.onPost(
      ApiPaths.parts,
      (server) => server.reply(201, part),
      data: {
        'name': 'Water Valve',
        'quantity': 3,
        'unitPrice': 250.0,
        'minimumStock': 5,
      },
    );
    adapter.onPatch(
      ApiPaths.part('part-1'),
      (server) => server.reply(200, part),
      data: {'unitPrice': 275.0},
    );
    adapter.onPatch(
      ApiPaths.partStatus('part-1'),
      (server) => server.reply(200, part),
      data: {'isActive': false},
    );
    adapter.onPatch(
      ApiPaths.partStock('part-1'),
      (server) => server.reply(200, part),
      data: {'quantity': 10},
    );
    await remote.createPart({
      'name': 'Water Valve',
      'quantity': 3,
      'unitPrice': 250.0,
      'minimumStock': 5,
    });
    await remote.updatePart('part-1', {'unitPrice': 275.0});
    await remote.updateStatus('part-1', false);
    await remote.setStock('part-1', 10);
  });
}
