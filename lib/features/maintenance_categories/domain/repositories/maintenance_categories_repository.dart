import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';

abstract interface class MaintenanceCategoriesRepository {
  Future<PagedMaintenanceCategories> getCategories(
    MaintenanceCategoryQuery query,
  );
  Future<MaintenanceCategory> getCategory(String id);
  Future<MaintenanceCategory> createCategory({
    required String name,
    String? description,
  });
  Future<MaintenanceCategory> updateCategory({
    required String id,
    required String name,
    String? description,
  });
  Future<MaintenanceCategory> updateCategoryStatus(String id, bool isActive);
}
