import 'package:apartment_maintenance_frontent/features/apartments/data/models/apartment_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/models/maintenance_category_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/users/data/models/user_model.dart';

class MaintenanceRequestResidentModel {
  const MaintenanceRequestResidentModel({
    required this.id,
    required this.userId,
    required this.phone,
    required this.isActive,
    required this.user,
  });
  factory MaintenanceRequestResidentModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceRequestResidentModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        phone: json['phone'] as String,
        isActive: json['isActive'] as bool,
        user: UserModel.fromJson(
          Map<String, dynamic>.from(json['user'] as Map),
        ),
      );
  final String id;
  final String userId;
  final String phone;
  final bool isActive;
  final UserModel user;
  MaintenanceRequestResident toEntity() => MaintenanceRequestResident(
    id: id,
    userId: userId,
    phone: phone,
    isActive: isActive,
    user: user.toEntity(),
  );
}

class MaintenanceRequestModel {
  const MaintenanceRequestModel({
    required this.id,
    required this.residentId,
    required this.apartmentId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.resident,
    required this.apartment,
    required this.category,
    this.resolvedAt,
    this.closedAt,
  });
  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceRequestModel(
        id: json['id'] as String,
        residentId: json['residentId'] as String,
        apartmentId: json['apartmentId'] as String,
        categoryId: json['categoryId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        priority: MaintenancePriority.fromApi(json['priority'] as String),
        status: MaintenanceRequestStatus.fromApi(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        resolvedAt: json['resolvedAt'] == null
            ? null
            : DateTime.parse(json['resolvedAt'] as String),
        closedAt: json['closedAt'] == null
            ? null
            : DateTime.parse(json['closedAt'] as String),
        resident: MaintenanceRequestResidentModel.fromJson(
          Map<String, dynamic>.from(json['resident'] as Map),
        ),
        apartment: ApartmentModel.fromJson(
          Map<String, dynamic>.from(json['apartment'] as Map),
        ),
        category: MaintenanceCategoryModel.fromJson(
          Map<String, dynamic>.from(json['category'] as Map),
        ),
      );
  final String id;
  final String residentId;
  final String apartmentId;
  final String categoryId;
  final String title;
  final String description;
  final MaintenancePriority priority;
  final MaintenanceRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final MaintenanceRequestResidentModel resident;
  final ApartmentModel apartment;
  final MaintenanceCategoryModel category;
  MaintenanceRequest toEntity() => MaintenanceRequest(
    id: id,
    residentId: residentId,
    apartmentId: apartmentId,
    categoryId: categoryId,
    title: title,
    description: description,
    priority: priority,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
    resolvedAt: resolvedAt,
    closedAt: closedAt,
    resident: resident.toEntity(),
    apartment: apartment.toEntity(),
    category: category.toEntity(),
  );
}

class PagedMaintenanceRequestModels {
  const PagedMaintenanceRequestModels({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
  final List<MaintenanceRequestModel> items;
  final int total;
  final int page;
  final int limit;
}
