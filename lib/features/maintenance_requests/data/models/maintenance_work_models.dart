import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_work.dart';
import 'package:apartment_maintenance_frontent/features/parts/data/models/part_model.dart';

double _money(dynamic value) =>
    value is num ? value.toDouble() : double.parse(value.toString());

class MaintenanceWorkNoteModel {
  const MaintenanceWorkNoteModel(this.value);
  factory MaintenanceWorkNoteModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceWorkNoteModel(json);
  final Map<String, dynamic> value;
  MaintenanceWorkNote toEntity() {
    final technician = Map<String, dynamic>.from(value['technician'] as Map);
    final user = Map<String, dynamic>.from(technician['user'] as Map);
    return MaintenanceWorkNote(
      id: value['id'] as String,
      maintenanceRequestId: value['maintenanceRequestId'] as String,
      technicianId: value['technicianId'] as String,
      technicianName: user['name'] as String,
      diagnosis: value['diagnosis'] as String,
      workPerformed: value['workPerformed'] as String,
      laborCost: _money(value['laborCost']),
      otherCost: _money(value['otherCost']),
      createdAt: DateTime.parse(value['createdAt'] as String),
      updatedAt: DateTime.parse(value['updatedAt'] as String),
    );
  }
}

class MaintenancePartUsageModel {
  const MaintenancePartUsageModel(this.value);
  factory MaintenancePartUsageModel.fromJson(Map<String, dynamic> json) =>
      MaintenancePartUsageModel(json);
  final Map<String, dynamic> value;
  MaintenancePartUsage toEntity() => MaintenancePartUsage(
    id: value['id'] as String,
    maintenanceRequestId: value['maintenanceRequestId'] as String,
    partId: value['partId'] as String,
    part: PartModel.fromJson(
      Map<String, dynamic>.from(value['part'] as Map),
    ).toEntity(),
    quantity: value['quantity'] as int,
    unitPrice: _money(value['unitPrice']),
    createdAt: DateTime.parse(value['createdAt'] as String),
  );
}

class MaintenanceCostModel {
  const MaintenanceCostModel(this.value);
  factory MaintenanceCostModel.fromJson(Map<String, dynamic> json) =>
      MaintenanceCostModel(json);
  final Map<String, dynamic> value;
  MaintenanceCost toEntity() => MaintenanceCost(
    partsCost: _money(value['partsCost']),
    laborCost: _money(value['laborCost']),
    otherCost: _money(value['otherCost']),
    totalCost: _money(value['totalCost']),
  );
}
