import 'package:apartment_maintenance_frontent/core/network/request_defaults_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    dio.interceptors.add(RequestDefaultsInterceptor());
    adapter = DioAdapter(dio: dio);
  });

  test('does not set content type or send timeout on a GET request', () async {
    adapter.onGet('/users', (server) => server.reply(200, []));

    final response = await dio.get<dynamic>('/users');

    expect(response.requestOptions.contentType, isNull);
    expect(response.requestOptions.sendTimeout, isNull);
    expect(
      response.requestOptions.headers.containsKey(Headers.contentTypeHeader),
      isFalse,
    );
  });

  test(
    'sets JSON content type and send timeout on a request with a body',
    () async {
      adapter.onPost(
        '/auth/login',
        (server) => server.reply(200, {}),
        data: Matchers.any,
      );

      final response = await dio.post<dynamic>(
        '/auth/login',
        data: {'email': 'admin@example.com', 'password': 'password'},
      );

      expect(response.requestOptions.contentType, Headers.jsonContentType);
      expect(
        response.requestOptions.sendTimeout,
        RequestDefaultsInterceptor.sendTimeout,
      );
    },
  );
}
