import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/models/maintenance_work_models.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/widgets/maintenance_history_formatter.dart';
import 'package:apartment_maintenance_frontent/features/parts/data/models/part_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses part inventory and low-stock state', () {
    final part = PartModel.fromJson({
      'id': 'part-1',
      'name': 'Water Valve',
      'description': null,
      'quantity': 3,
      'unitPrice': '250.00',
      'minimumStock': 5,
      'isActive': true,
    }).toEntity();
    expect(part.unitPrice, 250);
    expect(part.isLowStock, isTrue);
  });

  test('parses work note, historical part price, and cost response', () {
    final note = MaintenanceWorkNoteModel.fromJson({
      'id': 'note-1',
      'maintenanceRequestId': 'request-1',
      'technicianId': 'technician-1',
      'diagnosis': 'Damaged valve',
      'workPerformed': 'Replaced valve',
      'laborCost': '300.00',
      'otherCost': '100.00',
      'createdAt': '2026-09-12T08:00:00.000Z',
      'updatedAt': '2026-09-12T08:00:00.000Z',
      'technician': {
        'id': 'technician-1',
        'userId': 'user-1',
        'user': {'id': 'user-1', 'name': 'Ravi', 'role': 'TECHNICIAN'},
      },
    }).toEntity();
    final usage = MaintenancePartUsageModel.fromJson({
      'id': 'usage-1',
      'maintenanceRequestId': 'request-1',
      'partId': 'part-1',
      'quantity': 2,
      'unitPrice': '250.00',
      'createdAt': '2026-09-12T08:10:00.000Z',
      'part': {
        'id': 'part-1',
        'name': 'Water Valve',
        'description': null,
        'quantity': 8,
        'unitPrice': '300.00',
        'minimumStock': 2,
        'isActive': true,
      },
    }).toEntity();
    final cost = MaintenanceCostModel.fromJson({
      'partsCost': 500,
      'laborCost': 300,
      'otherCost': 100,
      'totalCost': 900,
    }).toEntity();
    expect(note.technicianName, 'Ravi');
    expect(usage.unitPrice, 250);
    expect(usage.part.unitPrice, 300);
    expect(usage.total, 500);
    expect(cost.totalCost, 900);
  });

  test('formats part audit history for people', () {
    final entry = MaintenanceHistoryEntry(
      id: 'history-1',
      maintenanceRequestId: 'request-1',
      action: MaintenanceHistoryAction.partAdded,
      metadata: const {'partName': 'Water Valve', 'quantity': 2},
      createdAt: DateTime.utc(2026, 9, 12),
    );
    expect(maintenanceHistoryDescription(entry), '2 Water Valve added');
  });
}
