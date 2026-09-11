import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';

abstract final class RouteAccess {
  static bool canManageUsers(AppUser? user) => user?.role == UserRole.admin;
  static bool canManageApartments(AppUser? user) =>
      user?.role == UserRole.admin;
  static bool canManageResidents(AppUser? user) => user?.role == UserRole.admin;
  static bool canManageMaintenanceCategories(AppUser? user) =>
      user?.role == UserRole.admin;
  static bool canManageTechnicians(AppUser? user) =>
      user?.role == UserRole.admin;
  static bool canViewOwnTechnicianProfile(AppUser? user) =>
      user?.role == UserRole.technician;
  static bool canViewOwnResidentProfile(AppUser? user) =>
      user?.role == UserRole.resident;
}
