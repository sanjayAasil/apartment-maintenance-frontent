import 'package:apartment_maintenance_frontent/features/apartments/data/models/apartment_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/models/maintenance_category_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/technicians/data/models/technician_model.dart';
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

class MaintenanceAssignmentModel {
  const MaintenanceAssignmentModel({
    required this.id,
    required this.maintenanceRequestId,
    required this.technicianId,
    required this.assignedByUserId,
    required this.assignedAt,
    required this.isActive,
    required this.technician,
    required this.assignedBy,
    this.unassignedAt,
    this.createdAt,
    this.updatedAt,
  });
  factory MaintenanceAssignmentModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceAssignmentModel(
        id: json['id'] as String,
        maintenanceRequestId: json['maintenanceRequestId'] as String,
        technicianId: json['technicianId'] as String,
        assignedByUserId: json['assignedByUserId'] as String,
        assignedAt: DateTime.parse(json['assignedAt'] as String),
        unassignedAt: json['unassignedAt'] == null
            ? null
            : DateTime.parse(json['unassignedAt'] as String),
        isActive: json['isActive'] as bool,
        createdAt: json['createdAt'] == null
            ? null
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt'] as String),
        technician: TechnicianModel.fromJson(
          Map<String, dynamic>.from(json['technician'] as Map),
        ),
        assignedBy: UserModel.fromJson(
          Map<String, dynamic>.from(json['assignedBy'] as Map),
        ),
      );
  final String id;
  final String maintenanceRequestId;
  final String technicianId;
  final String assignedByUserId;
  final DateTime assignedAt;
  final DateTime? unassignedAt;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TechnicianModel technician;
  final UserModel assignedBy;
  MaintenanceAssignment toEntity() => MaintenanceAssignment(
    id: id,
    maintenanceRequestId: maintenanceRequestId,
    technicianId: technicianId,
    assignedByUserId: assignedByUserId,
    assignedAt: assignedAt,
    unassignedAt: unassignedAt,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
    technician: technician.toEntity(),
    assignedBy: assignedBy.toEntity(),
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
    this.activeAssignment,
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
        activeAssignment: (json['assignments'] as List? ?? const []).isEmpty
            ? null
            : MaintenanceAssignmentModel.fromJson(
                Map<String, dynamic>.from(
                  (json['assignments'] as List).first as Map,
                ),
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
  final MaintenanceAssignmentModel? activeAssignment;
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
    activeAssignment: activeAssignment?.toEntity(),
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
