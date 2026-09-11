import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';

class MaintenanceCategoryModel {
  const MaintenanceCategoryModel({
    required this.id,
    required this.name,
    required this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory MaintenanceCategoryModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceCategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        isActive: json['isActive'] as bool,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
      );

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MaintenanceCategory toEntity() => MaintenanceCategory(
    id: id,
    name: name,
    description: description,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class PagedMaintenanceCategoryModels {
  const PagedMaintenanceCategoryModels({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
  final List<MaintenanceCategoryModel> items;
  final int total;
  final int page;
  final int limit;
}
