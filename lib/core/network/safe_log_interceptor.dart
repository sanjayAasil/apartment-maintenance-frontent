import 'package:dio/dio.dart';

class SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Intentionally logs only method/path. Never log headers or bodies.
    // ignore: avoid_print
    print('[HTTP] ${options.method} ${options.uri.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('[HTTP] ${response.statusCode} ${response.requestOptions.uri.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print(
      '[HTTP] ${err.response?.statusCode ?? 'ERROR'} '
      '${err.requestOptions.uri.path}',
    );
    handler.next(err);
  }
}
