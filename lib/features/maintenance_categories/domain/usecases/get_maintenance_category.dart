import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/repositories/maintenance_categories_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMaintenanceCategory {
  const GetMaintenanceCategory(this._repository);
  final MaintenanceCategoriesRepository _repository;
  Future<MaintenanceCategory> call(String id) => _repository.getCategory(id);
}
