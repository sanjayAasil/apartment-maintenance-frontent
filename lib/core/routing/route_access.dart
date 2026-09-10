import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';

abstract final class RouteAccess {
  static bool canManageUsers(AppUser? user) => user?.role == UserRole.admin;
}
