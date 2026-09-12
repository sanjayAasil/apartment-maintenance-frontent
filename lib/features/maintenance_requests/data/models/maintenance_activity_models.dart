import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';

class MaintenanceActorModel {
  const MaintenanceActorModel({
    required this.id,
    required this.name,
    required this.role,
  });

  factory MaintenanceActorModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceActorModel(
        id: json['id'] as String,
        name: json['name'] as String,
        role: UserRole.fromApi(json['role'] as String),
      );

  final String id;
  final String name;
  final UserRole role;

  MaintenanceActor toEntity() =>
      MaintenanceActor(id: id, name: name, role: role);
}

class MaintenanceCommentModel {
  const MaintenanceCommentModel({
    required this.id,
    required this.maintenanceRequestId,
    required this.userId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
  });

  factory MaintenanceCommentModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceCommentModel(
        id: json['id'] as String,
        maintenanceRequestId: json['maintenanceRequestId'] as String,
        userId: json['userId'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        author: MaintenanceActorModel.fromJson(
          Map<String, dynamic>.from(json['user'] as Map),
        ),
      );

  final String id;
  final String maintenanceRequestId;
  final String userId;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MaintenanceActorModel author;

  MaintenanceComment toEntity() => MaintenanceComment(
    id: id,
    maintenanceRequestId: maintenanceRequestId,
    userId: userId,
    message: message,
    createdAt: createdAt,
    updatedAt: updatedAt,
    author: author.toEntity(),
  );
}

class MaintenanceHistoryEntryModel {
  const MaintenanceHistoryEntryModel({
    required this.id,
    required this.maintenanceRequestId,
    required this.action,
    required this.createdAt,
    this.userId,
    this.oldValue,
    this.newValue,
    this.metadata,
    this.actor,
  });

  factory MaintenanceHistoryEntryModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceHistoryEntryModel(
        id: json['id'] as String,
        maintenanceRequestId: json['maintenanceRequestId'] as String,
        userId: json['userId'] as String?,
        action: MaintenanceHistoryAction.fromApi(json['action'] as String),
        oldValue: json['oldValue'] as String?,
        newValue: json['newValue'] as String?,
        metadata: json['metadata'] == null
            ? null
            : Map<String, dynamic>.from(json['metadata'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
        actor: json['user'] == null
            ? null
            : MaintenanceActorModel.fromJson(
                Map<String, dynamic>.from(json['user'] as Map),
              ),
      );

  final String id;
  final String maintenanceRequestId;
  final String? userId;
  final MaintenanceHistoryAction action;
  final String? oldValue;
  final String? newValue;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final MaintenanceActorModel? actor;

  MaintenanceHistoryEntry toEntity() => MaintenanceHistoryEntry(
    id: id,
    maintenanceRequestId: maintenanceRequestId,
    userId: userId,
    action: action,
    oldValue: oldValue,
    newValue: newValue,
    metadata: metadata,
    createdAt: createdAt,
    actor: actor?.toEntity(),
  );
}
