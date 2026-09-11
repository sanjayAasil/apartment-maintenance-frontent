import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/models/maintenance_category_model.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/users/data/models/user_model.dart';

class TechnicianSkillModel {
  const TechnicianSkillModel({
    required this.id,
    required this.technicianId,
    required this.categoryId,
    required this.category,
    this.createdAt,
  });
  factory TechnicianSkillModel.fromJson(Map<String, dynamic> json) =>
      TechnicianSkillModel(
        id: json['id'] as String,
        technicianId: json['technicianId'] as String,
        categoryId: json['categoryId'] as String,
        category: MaintenanceCategoryModel.fromJson(
          Map<String, dynamic>.from(json['category'] as Map),
        ),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
      );
  final String id;
  final String technicianId;
  final String categoryId;
  final MaintenanceCategoryModel category;
  final DateTime? createdAt;
  TechnicianSkill toEntity() => TechnicianSkill(
    id: id,
    technicianId: technicianId,
    categoryId: categoryId,
    category: category.toEntity(),
    createdAt: createdAt,
  );
}

class TechnicianModel {
  const TechnicianModel({
    required this.id,
    required this.userId,
    required this.phone,
    required this.experienceYears,
    required this.isAvailable,
    required this.isActive,
    required this.user,
    required this.skills,
    this.createdAt,
    this.updatedAt,
  });
  factory TechnicianModel.fromJson(Map<String, dynamic> json) =>
      TechnicianModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        phone: json['phone'] as String,
        experienceYears: json['experienceYears'] as int,
        isAvailable: json['isAvailable'] as bool,
        isActive: json['isActive'] as bool,
        user: UserModel.fromJson(
          Map<String, dynamic>.from(json['user'] as Map),
        ),
        skills: (json['skills'] as List? ?? const [])
            .map(
              (item) => TechnicianSkillModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(growable: false),
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
      );
  final String id;
  final String userId;
  final String phone;
  final int experienceYears;
  final bool isAvailable;
  final bool isActive;
  final UserModel user;
  final List<TechnicianSkillModel> skills;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Technician toEntity() => Technician(
    id: id,
    userId: userId,
    phone: phone,
    experienceYears: experienceYears,
    isAvailable: isAvailable,
    isActive: isActive,
    user: user.toEntity(),
    skills: skills.map((skill) => skill.toEntity()).toList(growable: false),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class PagedTechnicianModels {
  const PagedTechnicianModels({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
  final List<TechnicianModel> items;
  final int total;
  final int page;
  final int limit;
}
