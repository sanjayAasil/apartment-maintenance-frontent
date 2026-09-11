import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/technicians/data/models/technician_model.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class TechniciansRemoteDataSource {
  Future<PagedTechnicianModels> getTechnicians(TechnicianQuery query);
  Future<List<TechnicianModel>> getAvailableTechnicians(String? categoryId);
  Future<TechnicianModel> getTechnician(String id);
  Future<TechnicianModel> getCurrentTechnician();
  Future<TechnicianModel> createTechnician(
    String userId,
    String phone,
    int experienceYears,
  );
  Future<TechnicianModel> updateTechnician(
    String id,
    String phone,
    int experienceYears,
  );
  Future<TechnicianModel> updateStatus(String id, bool isActive);
  Future<TechnicianModel> updateAvailability(String id, bool isAvailable);
  Future<List<TechnicianSkillModel>> getSkills(String id);
  Future<TechnicianSkillModel> addSkill(String id, String categoryId);
  Future<void> removeSkill(String id, String categoryId);
}

@LazySingleton(as: TechniciansRemoteDataSource)
class TechniciansRemoteDataSourceImpl implements TechniciansRemoteDataSource {
  const TechniciansRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<PagedTechnicianModels> getTechnicians(TechnicianQuery query) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.technicians,
      queryParameters: {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        if (query.isActive != null) 'isActive': query.isActive,
        if (query.isAvailable != null) 'isAvailable': query.isAvailable,
        if (query.categoryId != null) 'categoryId': query.categoryId,
        'page': query.page,
        'limit': query.pageSize,
      },
    );
    final value = response.data;
    if (value is! Map || value['data'] is! List || value['meta'] is! Map) {
      throw _malformed('technician list');
    }
    final meta = Map<String, dynamic>.from(value['meta'] as Map);
    return PagedTechnicianModels(
      items: (value['data'] as List)
          .map(
            (item) => TechnicianModel.fromJson(
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
  Future<List<TechnicianModel>> getAvailableTechnicians(
    String? categoryId,
  ) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.availableTechnicians,
      queryParameters: {'categoryId': ?categoryId},
    );
    dynamic value = response.data;
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! List) throw _malformed('available technician list');
    return value
        .map(
          (item) =>
              TechnicianModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<TechnicianModel> getTechnician(String id) async => _decodeTechnician(
    (await _dio.get<dynamic>(ApiPaths.technician(id))).data,
  );

  @override
  Future<TechnicianModel> getCurrentTechnician() async => _decodeTechnician(
    (await _dio.get<dynamic>(ApiPaths.currentTechnician)).data,
  );

  @override
  Future<TechnicianModel> createTechnician(
    String userId,
    String phone,
    int experienceYears,
  ) async => _decodeTechnician(
    (await _dio.post<dynamic>(
      ApiPaths.technicians,
      data: {
        'userId': userId,
        'phone': phone,
        'experienceYears': experienceYears,
      },
    )).data,
  );

  @override
  Future<TechnicianModel> updateTechnician(
    String id,
    String phone,
    int experienceYears,
  ) async => _decodeTechnician(
    (await _dio.patch<dynamic>(
      ApiPaths.technician(id),
      data: {'phone': phone, 'experienceYears': experienceYears},
    )).data,
  );

  @override
  Future<TechnicianModel> updateStatus(String id, bool isActive) async =>
      _decodeTechnician(
        (await _dio.patch<dynamic>(
          ApiPaths.technicianStatus(id),
          data: {'isActive': isActive},
        )).data,
      );

  @override
  Future<TechnicianModel> updateAvailability(
    String id,
    bool isAvailable,
  ) async => _decodeTechnician(
    (await _dio.patch<dynamic>(
      ApiPaths.technicianAvailability(id),
      data: {'isAvailable': isAvailable},
    )).data,
  );

  @override
  Future<List<TechnicianSkillModel>> getSkills(String id) async {
    final response = await _dio.get<dynamic>(ApiPaths.technicianSkills(id));
    dynamic value = response.data;
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! List) throw _malformed('technician skills');
    return value
        .map(
          (item) => TechnicianSkillModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<TechnicianSkillModel> addSkill(String id, String categoryId) async =>
      _decodeSkill(
        (await _dio.post<dynamic>(
          ApiPaths.technicianSkills(id),
          data: {'categoryId': categoryId},
        )).data,
      );

  @override
  Future<void> removeSkill(String id, String categoryId) async {
    await _dio.delete<dynamic>(ApiPaths.technicianSkill(id, categoryId));
  }

  TechnicianModel _decodeTechnician(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('technician');
    return TechnicianModel.fromJson(Map<String, dynamic>.from(value));
  }

  TechnicianSkillModel _decodeSkill(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('technician skill');
    return TechnicianSkillModel.fromJson(Map<String, dynamic>.from(value));
  }

  Failure _malformed(String subject) => Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected $subject response.',
  );
}
