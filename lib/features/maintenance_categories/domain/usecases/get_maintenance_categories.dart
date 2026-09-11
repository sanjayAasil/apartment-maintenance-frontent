import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/repositories/maintenance_categories_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMaintenanceCategories {
  const GetMaintenanceCategories(this._repository);
  final MaintenanceCategoriesRepository _repository;
  Future<PagedMaintenanceCategories> call(MaintenanceCategoryQuery query) =>
      _repository.getCategories(query);
}
