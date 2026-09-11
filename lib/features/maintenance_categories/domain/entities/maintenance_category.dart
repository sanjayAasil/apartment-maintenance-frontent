import 'package:equatable/equatable.dart';

class MaintenanceCategory extends Equatable {
  const MaintenanceCategory({
    required this.id,
    required this.name,
    required this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    isActive,
    createdAt,
    updatedAt,
  ];
}
