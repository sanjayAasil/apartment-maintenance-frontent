import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/models/maintenance_activity_models.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/models/maintenance_request_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/models/maintenance_work_models.dart';
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
  Future<List<MaintenanceCommentModel>> getComments(String id);
  Future<MaintenanceCommentModel> addComment(String id, String message);
  Future<List<MaintenanceHistoryEntryModel>> getHistory(String id);
  Future<MaintenanceWorkNoteModel?> getWorkNote(String id);
  Future<MaintenanceWorkNoteModel> createWorkNote(
    String id,
    Map<String, dynamic> data,
  );
  Future<MaintenanceWorkNoteModel> updateWorkNote(
    String id,
    String noteId,
    Map<String, dynamic> data,
  );
  Future<List<MaintenancePartUsageModel>> getPartsUsed(String id);
  Future<MaintenancePartUsageModel> addPart(
    String id,
    String partId,
    int quantity,
  );
  Future<void> removePart(String id, String usageId);
  Future<MaintenanceCostModel> getCost(String id);
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

  @override
  Future<List<MaintenanceCommentModel>> getComments(String id) async =>
      _decodeList(
        (await _dio.get<dynamic>(ApiPaths.maintenanceRequestComments(id))).data,
        'maintenance comments',
        MaintenanceCommentModel.fromJson,
      );

  @override
  Future<MaintenanceCommentModel> addComment(String id, String message) async {
    var value = (await _dio.post<dynamic>(
      ApiPaths.maintenanceRequestComments(id),
      data: {'message': message},
    )).data;
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('maintenance comment');
    return MaintenanceCommentModel.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<List<MaintenanceHistoryEntryModel>> getHistory(String id) async =>
      _decodeList(
        (await _dio.get<dynamic>(ApiPaths.maintenanceRequestHistory(id))).data,
        'maintenance history',
        MaintenanceHistoryEntryModel.fromJson,
      );

  @override
  Future<MaintenanceWorkNoteModel?> getWorkNote(String id) async {
    var value = (await _dio.get<dynamic>(
      ApiPaths.maintenanceRequestWorkNotes(id),
    )).data;
    if (value is Map && value.containsKey('data')) value = value['data'];
    if (value == null) return null;
    if (value is! Map) throw _malformed('maintenance work note');
    return MaintenanceWorkNoteModel.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<MaintenanceWorkNoteModel> createWorkNote(
    String id,
    Map<String, dynamic> data,
  ) async => _decodeWorkNote(
    (await _dio.post<dynamic>(
      ApiPaths.maintenanceRequestWorkNotes(id),
      data: data,
    )).data,
  );

  @override
  Future<MaintenanceWorkNoteModel> updateWorkNote(
    String id,
    String noteId,
    Map<String, dynamic> data,
  ) async => _decodeWorkNote(
    (await _dio.patch<dynamic>(
      ApiPaths.maintenanceRequestWorkNote(id, noteId),
      data: data,
    )).data,
  );

  @override
  Future<List<MaintenancePartUsageModel>> getPartsUsed(String id) async =>
      _decodeList(
        (await _dio.get<dynamic>(ApiPaths.maintenanceRequestParts(id))).data,
        'maintenance parts',
        MaintenancePartUsageModel.fromJson,
      );

  @override
  Future<MaintenancePartUsageModel> addPart(
    String id,
    String partId,
    int quantity,
  ) async {
    var value = (await _dio.post<dynamic>(
      ApiPaths.maintenanceRequestParts(id),
      data: {'partId': partId, 'quantity': quantity},
    )).data;
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('maintenance part usage');
    return MaintenancePartUsageModel.fromJson(Map<String, dynamic>.from(value));
  }

  @override
  Future<void> removePart(String id, String usageId) =>
      _dio.delete<dynamic>(ApiPaths.maintenanceRequestPart(id, usageId));

  @override
  Future<MaintenanceCostModel> getCost(String id) async {
    var value = (await _dio.get<dynamic>(
      ApiPaths.maintenanceRequestCost(id),
    )).data;
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('maintenance cost');
    return MaintenanceCostModel.fromJson(Map<String, dynamic>.from(value));
  }

  MaintenanceWorkNoteModel _decodeWorkNote(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('maintenance work note');
    return MaintenanceWorkNoteModel.fromJson(Map<String, dynamic>.from(value));
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

  List<T> _decodeList<T>(
    dynamic value,
    String subject,
    T Function(Map<String, dynamic>) decode,
  ) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! List) throw _malformed(subject);
    return value
        .map((item) => decode(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Failure _malformed(String subject) => Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected $subject response.',
  );
}
