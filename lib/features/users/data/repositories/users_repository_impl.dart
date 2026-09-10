import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/data/datasources/users_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/paged_users.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UsersRepository)
class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(this._remote);
  final UsersRemoteDataSource _remote;

  @override
  Future<PagedUsers> getUsers(UserQuery query) async {
    try {
      var users = (await _remote.getUsers())
          .map((model) => model.toEntity())
          .toList();
      final search = query.search.trim().toLowerCase();
      if (search.isNotEmpty) {
        users = users
            .where(
              (user) =>
                  user.name.toLowerCase().contains(search) ||
                  user.email.toLowerCase().contains(search),
            )
            .toList();
      }
      if (query.role != null) {
        users = users.where((user) => user.role == query.role).toList();
      }
      if (query.isActive != null) {
        users = users.where((user) => user.isActive == query.isActive).toList();
      }
      final total = users.length;
      final start = ((query.page - 1) * query.pageSize).clamp(0, total);
      final end = (start + query.pageSize).clamp(0, total);
      return PagedUsers(
        items: users.sublist(start, end),
        total: total,
        page: query.page,
        pageSize: query.pageSize,
      );
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<AppUser> getUser(String id) async {
    try {
      return (await _remote.getUser(id)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<AppUser> updateUser({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  }) async {
    try {
      return (await _remote.updateUser(
        id,
        name.trim(),
        email.trim(),
        role,
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<AppUser> setActive(String id, bool isActive) async {
    try {
      return (await _remote.setActive(id, isActive)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }
}
