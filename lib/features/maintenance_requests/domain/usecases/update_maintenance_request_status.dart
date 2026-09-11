import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMaintenanceRequestStatus {
  const UpdateMaintenanceRequestStatus(this._repository);
  final MaintenanceRequestsRepository _repository;
  Future<MaintenanceRequest> call(String id, MaintenanceRequestStatus status) =>
      _repository.updateStatus(id, status);
}
