import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/repositories/maintenance_categories_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMaintenanceCategory {
  const UpdateMaintenanceCategory(this._repository);
  final MaintenanceCategoriesRepository _repository;
  Future<MaintenanceCategory> call(
    String id,
    String name,
    String? description,
  ) => _repository.updateCategory(id: id, name: name, description: description);
}
