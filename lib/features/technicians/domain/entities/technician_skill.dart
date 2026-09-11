import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:equatable/equatable.dart';

class TechnicianSkill extends Equatable {
  const TechnicianSkill({
    required this.id,
    required this.technicianId,
    required this.categoryId,
    required this.category,
    this.createdAt,
  });
  final String id;
  final String technicianId;
  final String categoryId;
  final MaintenanceCategory category;
  final DateTime? createdAt;
  @override
  List<Object?> get props => [
    id,
    technicianId,
    categoryId,
    category,
    createdAt,
  ];
}
