import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/models/maintenance_category_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class MaintenanceCategoriesRemoteDataSource {
  Future<PagedMaintenanceCategoryModels> getCategories(
    MaintenanceCategoryQuery query,
  );
  Future<MaintenanceCategoryModel> getCategory(String id);
  Future<MaintenanceCategoryModel> createCategory(
    String name,
    String? description,
  );
  Future<MaintenanceCategoryModel> updateCategory(
    String id,
    String name,
    String? description,
  );
  Future<MaintenanceCategoryModel> updateCategoryStatus(
    String id,
    bool isActive,
  );
}

@LazySingleton(as: MaintenanceCategoriesRemoteDataSource)
class MaintenanceCategoriesRemoteDataSourceImpl
    implements MaintenanceCategoriesRemoteDataSource {
  const MaintenanceCategoriesRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<PagedMaintenanceCategoryModels> getCategories(
    MaintenanceCategoryQuery query,
  ) async {
    final response = await _dio.get<dynamic>(
      ApiPaths.maintenanceCategories,
      queryParameters: {
        if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
        if (query.isActive != null) 'isActive': query.isActive,
        'page': query.page,
        'limit': query.pageSize,
      },
    );
    final value = response.data;
    if (value is! Map || value['data'] is! List || value['meta'] is! Map) {
      throw _malformed('maintenance category list');
    }
    final meta = Map<String, dynamic>.from(value['meta'] as Map);
    return PagedMaintenanceCategoryModels(
      items: (value['data'] as List)
          .map(
            (item) => MaintenanceCategoryModel.fromJson(
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
  Future<MaintenanceCategoryModel> getCategory(String id) async =>
      _decode((await _dio.get<dynamic>(ApiPaths.maintenanceCategory(id))).data);

  @override
  Future<MaintenanceCategoryModel> createCategory(
    String name,
    String? description,
  ) async => _decode(
    (await _dio.post<dynamic>(
      ApiPaths.maintenanceCategories,
      data: {'name': name, 'description': description},
    )).data,
  );

  @override
  Future<MaintenanceCategoryModel> updateCategory(
    String id,
    String name,
    String? description,
  ) async => _decode(
    (await _dio.patch<dynamic>(
      ApiPaths.maintenanceCategory(id),
      data: {'name': name, 'description': description},
    )).data,
  );

  @override
  Future<MaintenanceCategoryModel> updateCategoryStatus(
    String id,
    bool isActive,
  ) async => _decode(
    (await _dio.patch<dynamic>(
      ApiPaths.maintenanceCategoryStatus(id),
      data: {'isActive': isActive},
    )).data,
  );

  MaintenanceCategoryModel _decode(dynamic value) {
    if (value is Map && value['data'] != null) value = value['data'];
    if (value is! Map) throw _malformed('maintenance category');
    return MaintenanceCategoryModel.fromJson(Map<String, dynamic>.from(value));
  }

  Failure _malformed(String subject) => Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected $subject response.',
  );
}
