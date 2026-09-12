import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/datasources/maintenance_requests_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/paged_maintenance_requests.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: MaintenanceRequestsRepository)
class MaintenanceRequestsRepositoryImpl
    implements MaintenanceRequestsRepository {
  const MaintenanceRequestsRepositoryImpl(this._remote);
  final MaintenanceRequestsRemoteDataSource _remote;
  @override
  Future<PagedMaintenanceRequests> getRequests(
    MaintenanceRequestQuery query,
  ) async {
    try {
      final result = await _remote.getRequests(query);
      return PagedMaintenanceRequests(
        items: result.items
            .map((item) => item.toEntity())
            .toList(growable: false),
        total: result.total,
        page: result.page,
        pageSize: result.limit,
      );
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceRequest> getRequest(String id) async {
    try {
      return (await _remote.getRequest(id)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceRequest> createRequest({
    required String categoryId,
    required String title,
    required String description,
    required MaintenancePriority priority,
  }) async {
    try {
      return (await _remote.createRequest(
        categoryId,
        title.trim(),
        description.trim(),
        priority,
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceRequest> updateRequest({
    required String id,
    String? categoryId,
    String? title,
    String? description,
    MaintenancePriority? priority,
  }) async {
    try {
      return (await _remote.updateRequest(
        id,
        categoryId: categoryId,
        title: title?.trim(),
        description: description?.trim(),
        priority: priority,
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceRequest> updateStatus(
    String id,
    MaintenanceRequestStatus status,
  ) async {
    try {
      return (await _remote.updateStatus(id, status)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceAssignment> getCurrentAssignment(String id) async {
    try {
      return (await _remote.getCurrentAssignment(id)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<List<MaintenanceAssignment>> getAssignmentHistory(String id) async {
    try {
      return (await _remote.getAssignmentHistory(
        id,
      )).map((item) => item.toEntity()).toList(growable: false);
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceAssignment> assignTechnician(
    String id,
    String technicianId,
  ) async {
    try {
      return (await _remote.assignTechnician(id, technicianId)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceAssignment> reassignTechnician(
    String id,
    String technicianId,
  ) async {
    try {
      return (await _remote.reassignTechnician(id, technicianId)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<void> unassignTechnician(String id) async {
    try {
      await _remote.unassignTechnician(id);
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<List<MaintenanceComment>> getComments(String id) async {
    try {
      return (await _remote.getComments(
        id,
      )).map((item) => item.toEntity()).toList(growable: false);
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceComment> addComment(String id, String message) async {
    try {
      return (await _remote.addComment(id, message.trim())).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<List<MaintenanceHistoryEntry>> getHistory(String id) async {
    try {
      return (await _remote.getHistory(
        id,
      )).map((item) => item.toEntity()).toList(growable: false);
    } catch (error) {
      throw mapApiError(error);
    }
  }
}
