import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:equatable/equatable.dart';

enum MaintenancePriority {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  urgent('URGENT');

  const MaintenancePriority(this.apiValue);
  final String apiValue;
  String get label => name[0].toUpperCase() + name.substring(1);
  static MaintenancePriority fromApi(String value) => values.firstWhere(
    (item) => item.apiValue == value.toUpperCase(),
    orElse: () => throw FormatException('Unknown maintenance priority: $value'),
  );
}

enum MaintenanceRequestStatus {
  open('OPEN'),
  assigned('ASSIGNED'),
  inProgress('IN_PROGRESS'),
  resolved('RESOLVED'),
  closed('CLOSED'),
  cancelled('CANCELLED');

  const MaintenanceRequestStatus(this.apiValue);
  final String apiValue;
  String get label => name == 'inProgress'
      ? 'In progress'
      : name[0].toUpperCase() + name.substring(1);
  static MaintenanceRequestStatus fromApi(String value) => values.firstWhere(
    (item) => item.apiValue == value.toUpperCase(),
    orElse: () => throw FormatException('Unknown maintenance status: $value'),
  );
}

class MaintenanceRequestResident extends Equatable {
  const MaintenanceRequestResident({
    required this.id,
    required this.userId,
    required this.phone,
    required this.isActive,
    required this.user,
  });
  final String id;
  final String userId;
  final String phone;
  final bool isActive;
  final AppUser user;
  @override
  List<Object?> get props => [id, userId, phone, isActive, user];
}

class MaintenanceRequest extends Equatable {
  const MaintenanceRequest({
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
  final MaintenanceRequestResident resident;
  final Apartment apartment;
  final MaintenanceCategory category;
  @override
  List<Object?> get props => [
    id,
    residentId,
    apartmentId,
    categoryId,
    title,
    description,
    priority,
    status,
    createdAt,
    updatedAt,
    resolvedAt,
    closedAt,
    resident,
    apartment,
    category,
  ];
}
