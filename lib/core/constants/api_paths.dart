abstract final class ApiPaths {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const me = '/auth/me';
  static const users = '/users';
  static const apartments = '/apartments';
  static const residents = '/residents';
  static const currentResident = '/residents/me';
  static const maintenanceCategories = '/maintenance-categories';

  static String user(String id) => '/users/$id';
  static String userStatus(String id) => '/users/$id/status';
  static String apartment(String id) => '/apartments/$id';
  static String resident(String id) => '/residents/$id';
  static String residentApartment(String id) => '/residents/$id/apartment';
  static String residentStatus(String id) => '/residents/$id/status';
  static String maintenanceCategory(String id) => '/maintenance-categories/$id';
  static String maintenanceCategoryStatus(String id) =>
      '/maintenance-categories/$id/status';

  static const publicPaths = {login, register};
}
