abstract final class ApiPaths {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const me = '/auth/me';
  static const users = '/users';
  static const apartments = '/apartments';
  static const residents = '/residents';
  static const currentResident = '/residents/me';
  static const maintenanceCategories = '/maintenance-categories';
  static const technicians = '/technicians';
  static const availableTechnicians = '/technicians/available';
  static const currentTechnician = '/technicians/me';
  static const maintenanceRequests = '/maintenance-requests';
  static const parts = '/parts';

  static String user(String id) => '/users/$id';
  static String userStatus(String id) => '/users/$id/status';
  static String apartment(String id) => '/apartments/$id';
  static String resident(String id) => '/residents/$id';
  static String residentApartment(String id) => '/residents/$id/apartment';
  static String residentStatus(String id) => '/residents/$id/status';
  static String maintenanceCategory(String id) => '/maintenance-categories/$id';
  static String maintenanceCategoryStatus(String id) =>
      '/maintenance-categories/$id/status';
  static String technician(String id) => '/technicians/$id';
  static String technicianStatus(String id) => '/technicians/$id/status';
  static String technicianAvailability(String id) =>
      '/technicians/$id/availability';
  static String technicianSkills(String id) => '/technicians/$id/skills';
  static String technicianSkill(String id, String categoryId) =>
      '/technicians/$id/skills/$categoryId';
  static String maintenanceRequest(String id) => '/maintenance-requests/$id';
  static String maintenanceRequestStatus(String id) =>
      '/maintenance-requests/$id/status';
  static String maintenanceRequestAssign(String id) =>
      '/maintenance-requests/$id/assign';
  static String maintenanceRequestAssignment(String id) =>
      '/maintenance-requests/$id/assignment';
  static String maintenanceRequestAssignmentHistory(String id) =>
      '/maintenance-requests/$id/assignment-history';
  static String maintenanceRequestComments(String id) =>
      '/maintenance-requests/$id/comments';
  static String maintenanceRequestHistory(String id) =>
      '/maintenance-requests/$id/history';
  static String maintenanceRequestWorkNotes(String id) =>
      '/maintenance-requests/$id/work-notes';
  static String maintenanceRequestWorkNote(String id, String noteId) =>
      '/maintenance-requests/$id/work-notes/$noteId';
  static String maintenanceRequestParts(String id) =>
      '/maintenance-requests/$id/parts';
  static String maintenanceRequestPart(String id, String usageId) =>
      '/maintenance-requests/$id/parts/$usageId';
  static String maintenanceRequestCost(String id) =>
      '/maintenance-requests/$id/cost';
  static String part(String id) => '/parts/$id';
  static String partStatus(String id) => '/parts/$id/status';
  static String partStock(String id) => '/parts/$id/stock';
  static const lowStockParts = '/parts/low-stock';

  static const publicPaths = {login, register};
}
