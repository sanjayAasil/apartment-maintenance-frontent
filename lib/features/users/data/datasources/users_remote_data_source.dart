import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUser(String id);
  Future<UserModel> updateUser(
    String id,
    String name,
    String email,
    UserRole role,
  );
  Future<UserModel> setActive(String id, bool isActive);
}

@LazySingleton(as: UsersRemoteDataSource)
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  const UsersRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await _dio.get<dynamic>(ApiPaths.users);
    dynamic value = response.data;
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is Map && value['users'] != null) value = value['users'];
    if (value is! List) throw _malformed('users list');
    return value
        .map(
          (item) => UserModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<UserModel> getUser(String id) async {
    final response = await _dio.get<dynamic>(ApiPaths.user(id));
    return _decodeUser(response.data);
  }

  @override
  Future<UserModel> updateUser(
    String id,
    String name,
    String email,
    UserRole role,
  ) async {
    final response = await _dio.patch<dynamic>(
      ApiPaths.user(id),
      data: {'name': name, 'email': email, 'role': role.apiValue},
    );
    return _decodeUser(response.data);
  }

  @override
  Future<UserModel> setActive(String id, bool isActive) async {
    final response = await _dio.patch<dynamic>(
      ApiPaths.userStatus(id),
      data: {'isActive': isActive},
    );
    return _decodeUser(response.data);
  }

  UserModel _decodeUser(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is Map && value['user'] != null) value = value['user'];
    if (value is! Map) throw _malformed('user');
    return UserModel.fromJson(Map<String, dynamic>.from(value));
  }

  Failure _malformed(String subject) => Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected $subject response.',
  );
}
