import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMaintenanceRequest {
  const GetMaintenanceRequest(this._repository);
  final MaintenanceRequestsRepository _repository;
  Future<MaintenanceRequest> call(String id) => _repository.getRequest(id);
}
