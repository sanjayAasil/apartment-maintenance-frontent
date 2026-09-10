import 'package:apartment_maintenance_frontent/core/config/app_config.dart';
import 'package:apartment_maintenance_frontent/core/network/auth_interceptor.dart';
import 'package:apartment_maintenance_frontent/core/network/request_defaults_interceptor.dart';
import 'package:apartment_maintenance_frontent/core/network/safe_log_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(AppConfig config, AuthInterceptor authInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(RequestDefaultsInterceptor());
    dio.interceptors.add(authInterceptor);
    if (kDebugMode) dio.interceptors.add(SafeLogInterceptor());
    return dio;
  }
}
