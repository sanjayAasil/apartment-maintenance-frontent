import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/models/auth_response_model.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(
    String name,
    String email,
    String password,
  );
  Future<UserModel> me();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(_map(response.data));
  }

  @override
  Future<AuthResponseModel> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(_map(response.data));
  }

  @override
  Future<UserModel> me() async {
    final response = await _dio.get<dynamic>(ApiPaths.me);
    final root = _map(response.data);
    final candidate = root['data'] is Map ? root['data'] : root;
    final user = candidate is Map && candidate['user'] is Map
        ? candidate['user']
        : candidate;
    if (user is! Map) {
      throw const Failure(
        kind: FailureKind.malformedResponse,
        message: 'The current-user response has an unexpected format.',
      );
    }
    return UserModel.fromJson(Map<String, dynamic>.from(user));
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const Failure(
      kind: FailureKind.malformedResponse,
      message: 'The server returned an unexpected response.',
    );
  }
}
