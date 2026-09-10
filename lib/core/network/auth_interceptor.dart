import 'dart:async';

import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/network/session_coordinator.dart';
import 'package:apartment_maintenance_frontent/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._sessions);
  final TokenStorage _storage;
  final SessionCoordinator _sessions;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!ApiPaths.publicPaths.contains(options.path)) {
      final token = await _storage.read();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 &&
        !ApiPaths.publicPaths.contains(err.requestOptions.path)) {
      unawaited(_sessions.invalidate());
    }
    handler.next(err);
  }
}
