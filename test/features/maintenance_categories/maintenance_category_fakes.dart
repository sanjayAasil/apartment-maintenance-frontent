import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/models/maintenance_category_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';

const maintenanceCategory = MaintenanceCategory(
  id: 'category-1',
  name: 'Plumbing',
  description: 'Water and pipe related maintenance',
  isActive: true,
);

const maintenanceCategoryModel = MaintenanceCategoryModel(
  id: 'category-1',
  name: 'Plumbing',
  description: 'Water and pipe related maintenance',
  isActive: true,
);

Map<String, dynamic> get maintenanceCategoryJson => {
  'id': 'category-1',
  'name': 'Plumbing',
  'description': 'Water and pipe related maintenance',
  'isActive': true,
  'createdAt': '2026-09-01T00:00:00.000Z',
  'updatedAt': '2026-09-01T00:00:00.000Z',
};
