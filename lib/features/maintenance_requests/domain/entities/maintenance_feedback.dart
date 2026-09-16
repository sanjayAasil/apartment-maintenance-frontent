import 'package:equatable/equatable.dart';

class MaintenanceFeedbackResident extends Equatable {
  const MaintenanceFeedbackResident({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class MaintenanceFeedback extends Equatable {
  const MaintenanceFeedback({
    required this.id,
    required this.maintenanceRequestId,
    required this.residentId,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.resident,
    this.comment,
  });

  final String id;
  final String maintenanceRequestId;
  final String residentId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MaintenanceFeedbackResident resident;

  @override
  List<Object?> get props => [
    id,
    maintenanceRequestId,
    residentId,
    rating,
    comment,
    createdAt,
    updatedAt,
    resident,
  ];
}
