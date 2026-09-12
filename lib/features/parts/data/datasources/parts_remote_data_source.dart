import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/parts/data/models/part_model.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class PartsRemoteDataSource {
  Future<PagedPartModels> getParts(PartQuery query);
  Future<PartModel> getPart(String id);
  Future<PartModel> createPart(Map<String, dynamic> data);
  Future<PartModel> updatePart(String id, Map<String, dynamic> data);
  Future<PartModel> updateStatus(String id, bool isActive);
  Future<PartModel> setStock(String id, int quantity);
}

@LazySingleton(as: PartsRemoteDataSource)
class PartsRemoteDataSourceImpl implements PartsRemoteDataSource {
  const PartsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<PagedPartModels> getParts(PartQuery query) async {
    final value = (await _dio.get<dynamic>(
      ApiPaths.parts,
      queryParameters: {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        if (query.isActive != null) 'isActive': query.isActive,
        if (query.lowStock != null) 'lowStock': query.lowStock,
        'page': query.page,
        'limit': query.pageSize,
      },
    )).data;
    if (value is! Map || value['data'] is! List || value['meta'] is! Map) {
      throw _malformed('parts list');
    }
    final meta = Map<String, dynamic>.from(value['meta'] as Map);
    return PagedPartModels(
      items: (value['data'] as List)
          .map(
            (item) =>
                PartModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
      total: meta['total'] as int,
      page: meta['page'] as int,
      limit: meta['limit'] as int,
    );
  }

  @override
  Future<PartModel> getPart(String id) async =>
      _decode((await _dio.get<dynamic>(ApiPaths.part(id))).data);
  @override
  Future<PartModel> createPart(Map<String, dynamic> data) async =>
      _decode((await _dio.post<dynamic>(ApiPaths.parts, data: data)).data);
  @override
  Future<PartModel> updatePart(String id, Map<String, dynamic> data) async =>
      _decode((await _dio.patch<dynamic>(ApiPaths.part(id), data: data)).data);
  @override
  Future<PartModel> updateStatus(String id, bool isActive) async => _decode(
    (await _dio.patch<dynamic>(
      ApiPaths.partStatus(id),
      data: {'isActive': isActive},
    )).data,
  );
  @override
  Future<PartModel> setStock(String id, int quantity) async => _decode(
    (await _dio.patch<dynamic>(
      ApiPaths.partStock(id),
      data: {'quantity': quantity},
    )).data,
  );

  PartModel _decode(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('part');
    return PartModel.fromJson(Map<String, dynamic>.from(value));
  }

  Failure _malformed(String subject) => Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected $subject response.',
  );
}
