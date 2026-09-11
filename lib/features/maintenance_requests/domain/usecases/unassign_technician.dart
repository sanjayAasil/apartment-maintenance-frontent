import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UnassignTechnician {
  const UnassignTechnician(this._repository);
  final MaintenanceRequestsRepository _repository;
  Future<void> call(String id) => _repository.unassignTechnician(id);
}
