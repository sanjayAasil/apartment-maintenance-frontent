import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/apartments/data/models/apartment_model.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class ApartmentsRemoteDataSource {
  Future<PagedApartmentModels> getApartments(ApartmentQuery query);
  Future<ApartmentModel> getApartment(String id);
  Future<ApartmentModel> createApartment(
    String block,
    int floor,
    String unitNumber,
  );
  Future<ApartmentModel> updateApartment(
    String id,
    String block,
    int floor,
    String unitNumber,
  );
}

@LazySingleton(as: ApartmentsRemoteDataSource)
class ApartmentsRemoteDataSourceImpl implements ApartmentsRemoteDataSource {
  const ApartmentsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<PagedApartmentModels> getApartments(ApartmentQuery query) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.apartments,
      queryParameters: {
        if (query.block.trim().isNotEmpty) 'block': query.block.trim(),
        if (query.floor != null) 'floor': query.floor,
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        'page': query.page,
        'limit': query.pageSize,
      },
    );
    dynamic value = response.data;
    if (value is Map && value['success'] == true && value['data'] != null) {
      value = value;
    }
    if (value is! Map || value['data'] is! List || value['meta'] is! Map) {
      throw _malformed('apartment list');
    }
    final data = value['data'] as List;
    final meta = Map<String, dynamic>.from(value['meta'] as Map);
    return PagedApartmentModels(
      items: data
          .map(
            (item) =>
                ApartmentModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false),
      total: meta['total'] as int,
      page: meta['page'] as int,
      limit: meta['limit'] as int,
    );
  }

  @override
  Future<ApartmentModel> getApartment(String id) async {
    final response = await _dio.get<dynamic>(ApiPaths.apartment(id));
    return _decodeApartment(response.data);
  }

  @override
  Future<ApartmentModel> createApartment(
    String block,
    int floor,
    String unitNumber,
  ) async {
    final response = await _dio.post<dynamic>(
      ApiPaths.apartments,
      data: {'block': block, 'floor': floor, 'unitNumber': unitNumber},
    );
    return _decodeApartment(response.data);
  }

  @override
  Future<ApartmentModel> updateApartment(
    String id,
    String block,
    int floor,
    String unitNumber,
  ) async {
    final response = await _dio.patch<dynamic>(
      ApiPaths.apartment(id),
      data: {'block': block, 'floor': floor, 'unitNumber': unitNumber},
    );
    return _decodeApartment(response.data);
  }

  ApartmentModel _decodeApartment(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is Map && value['apartment'] != null) {
      value = value['apartment'];
    }
    if (value is! Map) throw _malformed('apartment');
    return ApartmentModel.fromJson(Map<String, dynamic>.from(value));
  }

  Failure _malformed(String subject) => Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected $subject response.',
  );
}
