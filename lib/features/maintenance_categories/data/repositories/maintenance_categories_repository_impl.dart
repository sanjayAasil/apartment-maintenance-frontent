import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/datasources/maintenance_categories_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/repositories/maintenance_categories_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: MaintenanceCategoriesRepository)
class MaintenanceCategoriesRepositoryImpl
    implements MaintenanceCategoriesRepository {
  const MaintenanceCategoriesRepositoryImpl(this._remote);
  final MaintenanceCategoriesRemoteDataSource _remote;

  @override
  Future<PagedMaintenanceCategories> getCategories(
    MaintenanceCategoryQuery query,
  ) async {
    try {
      final result = await _remote.getCategories(query);
      return PagedMaintenanceCategories(
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
  Future<MaintenanceCategory> getCategory(String id) async {
    try {
      return (await _remote.getCategory(id)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceCategory> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      return (await _remote.createCategory(
        name.trim(),
        description?.trim(),
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceCategory> updateCategory({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      return (await _remote.updateCategory(
        id,
        name.trim(),
        description?.trim(),
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<MaintenanceCategory> updateCategoryStatus(
    String id,
    bool isActive,
  ) async {
    try {
      return (await _remote.updateCategoryStatus(id, isActive)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }
}
