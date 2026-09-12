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
  static bool canManageParts(AppUser? user) => user?.role == UserRole.admin;
  static bool canViewOwnTechnicianProfile(AppUser? user) =>
      user?.role == UserRole.technician;
  static bool canViewOwnResidentProfile(AppUser? user) =>
      user?.role == UserRole.resident;
  static bool canViewMaintenanceRequests(AppUser? user) =>
      user?.role == UserRole.admin ||
      user?.role == UserRole.resident ||
      user?.role == UserRole.technician;
  static bool canCreateMaintenanceRequest(AppUser? user) =>
      user?.role == UserRole.resident;
  static bool canEditMaintenanceRequest(AppUser? user) =>
      user?.role == UserRole.admin || user?.role == UserRole.resident;
  static bool canViewTechnicianJobs(AppUser? user) =>
      user?.role == UserRole.technician;
}
