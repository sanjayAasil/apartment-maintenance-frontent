import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

class MaintenanceActor extends Equatable {
  const MaintenanceActor({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final UserRole role;

  @override
  List<Object> get props => [id, name, role];
}

class MaintenanceComment extends Equatable {
  const MaintenanceComment({
    required this.id,
    required this.maintenanceRequestId,
    required this.userId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
  });

  final String id;
  final String maintenanceRequestId;
  final String userId;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MaintenanceActor author;

  @override
  List<Object> get props => [
    id,
    maintenanceRequestId,
    userId,
    message,
    createdAt,
    updatedAt,
    author,
  ];
}
