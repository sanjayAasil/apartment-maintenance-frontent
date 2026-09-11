import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMaintenanceRequest {
  const UpdateMaintenanceRequest(this._repository);
  final MaintenanceRequestsRepository _repository;
  Future<MaintenanceRequest> call(
    String id, {
    String? categoryId,
    String? title,
    String? description,
    MaintenancePriority? priority,
  }) => _repository.updateRequest(
    id: id,
    categoryId: categoryId,
    title: title,
    description: description,
    priority: priority,
  );
}
