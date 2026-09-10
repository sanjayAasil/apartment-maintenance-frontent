import 'package:dio/dio.dart';

/// Applies JSON and send-timeout defaults only to requests that have a body.
///
/// Dio Web rejects a send timeout on bodyless requests, and adding a JSON
/// content type to GET requests creates an unnecessary CORS preflight reason.
class RequestDefaultsInterceptor extends Interceptor {
  static const sendTimeout = Duration(seconds: 10);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data != null) {
      options.contentType ??= Headers.jsonContentType;
      options.sendTimeout ??= sendTimeout;
    } else {
      options.contentType = null;
      options.sendTimeout = null;
      options.headers.remove(Headers.contentTypeHeader);
    }
    handler.next(options);
  }
}
