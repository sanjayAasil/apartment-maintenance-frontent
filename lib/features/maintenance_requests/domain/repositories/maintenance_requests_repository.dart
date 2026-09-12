import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/paged_maintenance_requests.dart';

abstract interface class MaintenanceRequestsRepository {
  Future<PagedMaintenanceRequests> getRequests(MaintenanceRequestQuery query);
  Future<MaintenanceRequest> getRequest(String id);
  Future<MaintenanceRequest> createRequest({
    required String categoryId,
    required String title,
    required String description,
    required MaintenancePriority priority,
  });
  Future<MaintenanceRequest> updateRequest({
    required String id,
    String? categoryId,
    String? title,
    String? description,
    MaintenancePriority? priority,
  });
  Future<MaintenanceRequest> updateStatus(
    String id,
    MaintenanceRequestStatus status,
  );
  Future<MaintenanceAssignment> getCurrentAssignment(String id);
  Future<List<MaintenanceAssignment>> getAssignmentHistory(String id);
  Future<MaintenanceAssignment> assignTechnician(
    String id,
    String technicianId,
  );
  Future<MaintenanceAssignment> reassignTechnician(
    String id,
    String technicianId,
  );
  Future<void> unassignTechnician(String id);
  Future<List<MaintenanceComment>> getComments(String id);
  Future<MaintenanceComment> addComment(String id, String message);
  Future<List<MaintenanceHistoryEntry>> getHistory(String id);
}
