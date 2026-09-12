import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_work.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMaintenanceWorkNote {
  const GetMaintenanceWorkNote(this.repository);
  final MaintenanceRequestsRepository repository;
  Future<MaintenanceWorkNote?> call(String id) => repository.getWorkNote(id);
}

@injectable
class SaveMaintenanceWorkNote {
  const SaveMaintenanceWorkNote(this.repository);
  final MaintenanceRequestsRepository repository;
  Future<MaintenanceWorkNote> call({
    required String requestId,
    String? noteId,
    required String diagnosis,
    required String workPerformed,
    required double laborCost,
    required double otherCost,
  }) => noteId == null
      ? repository.createWorkNote(
          id: requestId,
          diagnosis: diagnosis,
          workPerformed: workPerformed,
          laborCost: laborCost,
          otherCost: otherCost,
        )
      : repository.updateWorkNote(
          id: requestId,
          noteId: noteId,
          diagnosis: diagnosis,
          workPerformed: workPerformed,
          laborCost: laborCost,
          otherCost: otherCost,
        );
}

@injectable
class GetMaintenanceParts {
  const GetMaintenanceParts(this.repository);
  final MaintenanceRequestsRepository repository;
  Future<List<MaintenancePartUsage>> call(String id) =>
      repository.getPartsUsed(id);
}

@injectable
class AddMaintenancePart {
  const AddMaintenancePart(this.repository);
  final MaintenanceRequestsRepository repository;
  Future<MaintenancePartUsage> call(String id, String partId, int quantity) =>
      repository.addPart(id, partId, quantity);
}

@injectable
class RemoveMaintenancePart {
  const RemoveMaintenancePart(this.repository);
  final MaintenanceRequestsRepository repository;
  Future<void> call(String id, String usageId) =>
      repository.removePart(id, usageId);
}

@injectable
class GetMaintenanceCost {
  const GetMaintenanceCost(this.repository);
  final MaintenanceRequestsRepository repository;
  Future<MaintenanceCost> call(String id) => repository.getCost(id);
}
