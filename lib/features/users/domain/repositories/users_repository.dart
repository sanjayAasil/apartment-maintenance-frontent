import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/paged_users.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';

abstract interface class UsersRepository {
  Future<PagedUsers> getUsers(UserQuery query);
  Future<AppUser> getUser(String id);
  Future<AppUser> updateUser({
    required String id,
    required String name,
    required String email,
    required UserRole role,
  });
  Future<AppUser> setActive(String id, bool isActive);
}
