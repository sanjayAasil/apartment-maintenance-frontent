import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/models/maintenance_request_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class MaintenanceRequestsRemoteDataSource {
  Future<PagedMaintenanceRequestModels> getRequests(
    MaintenanceRequestQuery query,
  );
  Future<MaintenanceRequestModel> getRequest(String id);
  Future<MaintenanceRequestModel> createRequest(
    String categoryId,
    String title,
    String description,
    MaintenancePriority priority,
  );
  Future<MaintenanceRequestModel> updateRequest(
    String id, {
    String? categoryId,
    String? title,
    String? description,
    MaintenancePriority? priority,
  });
  Future<MaintenanceRequestModel> updateStatus(
    String id,
    MaintenanceRequestStatus status,
  );
  Future<MaintenanceAssignmentModel> getCurrentAssignment(String id);
  Future<List<MaintenanceAssignmentModel>> getAssignmentHistory(String id);
  Future<MaintenanceAssignmentModel> assignTechnician(
    String id,
    String technicianId,
  );
  Future<MaintenanceAssignmentModel> reassignTechnician(
    String id,
    String technicianId,
  );
  Future<void> unassignTechnician(String id);
}

@LazySingleton(as: MaintenanceRequestsRemoteDataSource)
class MaintenanceRequestsRemoteDataSourceImpl
    implements MaintenanceRequestsRemoteDataSource {
  const MaintenanceRequestsRemoteDataSourceImpl(this._dio);
  final Dio _dio;
  @override
  Future<PagedMaintenanceRequestModels> getRequests(
    MaintenanceRequestQuery query,
  ) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.maintenanceRequests,
      queryParameters: {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        if (query.status != null) 'status': query.status!.apiValue,
        if (query.priority != null) 'priority': query.priority!.apiValue,
        if (query.categoryId != null) 'categoryId': query.categoryId,
        if (query.apartmentId != null) 'apartmentId': query.apartmentId,
        if (query.residentId != null) 'residentId': query.residentId,
        'page': query.page,
        'limit': query.pageSize,
        'sortBy': query.sortBy,
        'sortOrder': query.sortOrder,
      },
    );
    final value = response.data;
    if (value is! Map || value['data'] is! List || value['meta'] is! Map) {
      throw _malformed('maintenance request list');
    }
    final meta = Map<String, dynamic>.from(value['meta'] as Map);
    return PagedMaintenanceRequestModels(
      items: (value['data'] as List)
          .map(
            (item) => MaintenanceRequestModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      total: meta['total'] as int,
      page: meta['page'] as int,
      limit: meta['limit'] as int,
    );
  }

  @override
  Future<MaintenanceRequestModel> getRequest(String id) async =>
      _decode((await _dio.get<dynamic>(ApiPaths.maintenanceRequest(id))).data);
  @override
  Future<MaintenanceRequestModel> createRequest(
    String categoryId,
    String title,
    String description,
    MaintenancePriority priority,
  ) async => _decode(
    (await _dio.post<dynamic>(
      ApiPaths.maintenanceRequests,
      data: {
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'priority': priority.apiValue,
      },
    )).data,
  );
  @override
  Future<MaintenanceRequestModel> updateRequest(
    String id, {
    String? categoryId,
    String? title,
    String? description,
    MaintenancePriority? priority,
  }) async => _decode(
    (await _dio.patch<dynamic>(
      ApiPaths.maintenanceRequest(id),
      data: {
        'categoryId': ?categoryId,
        'title': ?title,
        'description': ?description,
        if (priority != null) 'priority': priority.apiValue,
      },
    )).data,
  );
  @override
  Future<MaintenanceRequestModel> updateStatus(
    String id,
    MaintenanceRequestStatus status,
  ) async => _decode(
    (await _dio.patch<dynamic>(
      ApiPaths.maintenanceRequestStatus(id),
      data: {'status': status.apiValue},
    )).data,
  );

  @override
  Future<MaintenanceAssignmentModel> getCurrentAssignment(String id) async =>
      _decodeAssignment(
        (await _dio.get<dynamic>(
          ApiPaths.maintenanceRequestAssignment(id),
        )).data,
      );

  @override
  Future<List<MaintenanceAssignmentModel>> getAssignmentHistory(
    String id,
  ) async {
    var value = (await _dio.get<dynamic>(
      ApiPaths.maintenanceRequestAssignmentHistory(id),
    )).data;
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! List) throw _malformed('assignment history');
    return value
        .map(
          (item) => MaintenanceAssignmentModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<MaintenanceAssignmentModel> assignTechnician(
    String id,
    String technicianId,
  ) async => _decodeAssignment(
    (await _dio.post<dynamic>(
      ApiPaths.maintenanceRequestAssign(id),
      data: {'technicianId': technicianId},
    )).data,
  );

  @override
  Future<MaintenanceAssignmentModel> reassignTechnician(
    String id,
    String technicianId,
  ) async => _decodeAssignment(
    (await _dio.patch<dynamic>(
      ApiPaths.maintenanceRequestAssignment(id),
      data: {'technicianId': technicianId},
    )).data,
  );

  @override
  Future<void> unassignTechnician(String id) async {
    await _dio.delete<dynamic>(ApiPaths.maintenanceRequestAssignment(id));
  }

  MaintenanceRequestModel _decode(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('maintenance request');
    return MaintenanceRequestModel.fromJson(Map<String, dynamic>.from(value));
  }

  MaintenanceAssignmentModel _decodeAssignment(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('maintenance assignment');
    return MaintenanceAssignmentModel.fromJson(
      Map<String, dynamic>.from(value),
    );
  }

  Failure _malformed(String subject) => Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected $subject response.',
  );
}
