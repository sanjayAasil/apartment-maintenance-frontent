import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:equatable/equatable.dart';

class MaintenanceWorkNote extends Equatable {
  const MaintenanceWorkNote({
    required this.id,
    required this.maintenanceRequestId,
    required this.technicianId,
    required this.technicianName,
    required this.diagnosis,
    required this.workPerformed,
    required this.laborCost,
    required this.otherCost,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String maintenanceRequestId;
  final String technicianId;
  final String technicianName;
  final String diagnosis;
  final String workPerformed;
  final double laborCost;
  final double otherCost;
  final DateTime createdAt;
  final DateTime updatedAt;
  @override
  List<Object> get props => [
    id,
    maintenanceRequestId,
    technicianId,
    technicianName,
    diagnosis,
    workPerformed,
    laborCost,
    otherCost,
    createdAt,
    updatedAt,
  ];
}

class MaintenancePartUsage extends Equatable {
  const MaintenancePartUsage({
    required this.id,
    required this.maintenanceRequestId,
    required this.partId,
    required this.part,
    required this.quantity,
    required this.unitPrice,
    required this.createdAt,
  });
  final String id;
  final String maintenanceRequestId;
  final String partId;
  final Part part;
  final int quantity;
  final double unitPrice;
  final DateTime createdAt;
  double get total => quantity * unitPrice;
  @override
  List<Object> get props => [
    id,
    maintenanceRequestId,
    partId,
    part,
    quantity,
    unitPrice,
    createdAt,
  ];
}

class MaintenanceCost extends Equatable {
  const MaintenanceCost({
    required this.partsCost,
    required this.laborCost,
    required this.otherCost,
    required this.totalCost,
  });
  final double partsCost;
  final double laborCost;
  final double otherCost;
  final double totalCost;
  @override
  List<Object> get props => [partsCost, laborCost, otherCost, totalCost];
}
