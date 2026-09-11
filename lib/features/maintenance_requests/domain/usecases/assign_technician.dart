import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AssignTechnician {
  const AssignTechnician(this._repository);
  final MaintenanceRequestsRepository _repository;
  Future<MaintenanceAssignment> call(String id, String technicianId) =>
      _repository.assignTechnician(id, technicianId);
}
