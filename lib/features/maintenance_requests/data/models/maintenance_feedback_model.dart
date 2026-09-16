import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_feedback.dart';

class MaintenanceFeedbackModel {
  const MaintenanceFeedbackModel({
    required this.id,
    required this.maintenanceRequestId,
    required this.residentId,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.resident,
    this.comment,
  });

  factory MaintenanceFeedbackModel.fromJson(Map<String, dynamic> json) {
    final resident = Map<String, dynamic>.from(json['resident'] as Map);
    final user = Map<String, dynamic>.from(resident['user'] as Map);
    return MaintenanceFeedbackModel(
      id: json['id'] as String,
      maintenanceRequestId: json['maintenanceRequestId'] as String,
      residentId: json['residentId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resident: MaintenanceFeedbackResident(
        id: resident['id'] as String,
        name: user['name'] as String,
      ),
    );
  }

  final String id;
  final String maintenanceRequestId;
  final String residentId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MaintenanceFeedbackResident resident;

  MaintenanceFeedback toEntity() => MaintenanceFeedback(
    id: id,
    maintenanceRequestId: maintenanceRequestId,
    residentId: residentId,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
    updatedAt: updatedAt,
    resident: resident,
  );
}
