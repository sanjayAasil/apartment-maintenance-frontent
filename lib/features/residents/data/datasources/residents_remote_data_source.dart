import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/residents/data/models/resident_model.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class ResidentsRemoteDataSource {
  Future<PagedResidentModels> getResidents(ResidentQuery query);
  Future<ResidentModel> getResident(String id);
  Future<ResidentModel> getCurrentResident();
  Future<ResidentModel> createResident(
    String userId,
    String apartmentId,
    String phone,
    String moveInDate,
  );
  Future<ResidentModel> updateResident(
    String id,
    String phone,
    String moveInDate,
  );
  Future<ResidentModel> changeApartment(String id, String apartmentId);
  Future<ResidentModel> updateStatus(String id, bool isActive);
}

@LazySingleton(as: ResidentsRemoteDataSource)
class ResidentsRemoteDataSourceImpl implements ResidentsRemoteDataSource {
  const ResidentsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<PagedResidentModels> getResidents(ResidentQuery query) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.residents,
      queryParameters: {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        if (query.apartmentId != null) 'apartmentId': query.apartmentId,
        if (query.isActive != null) 'isActive': query.isActive,
        'page': query.page,
        'limit': query.pageSize,
      },
    );
    final value = response.data;
    if (value is! Map || value['data'] is! List || value['meta'] is! Map) {
      throw _malformed('resident list');
    }
    final data = value['data'] as List;
    final meta = Map<String, dynamic>.from(value['meta'] as Map);
    return PagedResidentModels(
      items: data
          .map(
            (item) =>
                ResidentModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
      total: meta['total'] as int,
      page: meta['page'] as int,
      limit: meta['limit'] as int,
    );
  }

  @override
  Future<ResidentModel> getResident(String id) async {
    final response = await _dio.get<dynamic>(ApiPaths.resident(id));
    return _decode(response.data);
  }

  @override
  Future<ResidentModel> getCurrentResident() async {
    final response = await _dio.get<dynamic>(ApiPaths.currentResident);
    return _decode(response.data);
  }

  @override
  Future<ResidentModel> createResident(
    String userId,
    String apartmentId,
    String phone,
    String moveInDate,
  ) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.residents,
      data: {
        'userId': userId,
        'apartmentId': apartmentId,
        'phone': phone,
        'moveInDate': moveInDate,
      },
    );
    return _decode(response.data);
  }

  @override
  Future<ResidentModel> updateResident(
    String id,
    String phone,
    String moveInDate,
  ) async {
    final response = await _dio.patch<dynamic>(
      ApiPaths.resident(id),
      data: {'phone': phone, 'moveInDate': moveInDate},
    );
    return _decode(response.data);
  }

  @override
  Future<ResidentModel> changeApartment(String id, String apartmentId) async {
    final response = await _dio.patch<dynamic>(
      ApiPaths.residentApartment(id),
      data: {'apartmentId': apartmentId},
    );
    return _decode(response.data);
  }

  @override
  Future<ResidentModel> updateStatus(String id, bool isActive) async {
    final response = await _dio.patch<dynamic>(
      ApiPaths.residentStatus(id),
      data: {'isActive': isActive},
    );
    return _decode(response.data);
  }

  ResidentModel _decode(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is Map && value['resident'] != null) value = value['resident'];
    if (value is! Map) throw _malformed('resident');
    return ResidentModel.fromJson(Map<String, dynamic>.from(value));
  }

  Failure _malformed(String subject) => Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected $subject response.',
  );
}
