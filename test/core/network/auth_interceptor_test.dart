import 'package:apartment_maintenance_frontent/core/network/auth_interceptor.dart';
import 'package:apartment_maintenance_frontent/core/network/session_coordinator.dart';
import 'package:apartment_maintenance_frontent/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class MockSessionCoordinator extends Mock implements SessionCoordinator {}

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late MockTokenStorage storage;

  setUp(() {
    storage = MockTokenStorage();
    final sessions = MockSessionCoordinator();
    when(storage.read).thenAnswer((_) async => 'secret-token');
    dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.interceptors.add(AuthInterceptor(storage, sessions));
    adapter = DioAdapter(dio: dio);
  });

  test('attaches bearer token to protected endpoints', () async {
    adapter.onGet('/auth/me', (server) => server.reply(200, {}));
    final response = await dio.get<dynamic>('/auth/me');
    expect(
      response.requestOptions.headers['Authorization'],
      'Bearer secret-token',
    );
  });

  test('does not attach bearer token to login', () async {
    adapter.onPost(
      '/auth/login',
      (server) => server.reply(200, {}),
      data: Matchers.any,
    );
    final response = await dio.post<dynamic>('/auth/login', data: {});
    expect(response.requestOptions.headers['Authorization'], isNull);
    verifyNever(storage.read);
  });
}
