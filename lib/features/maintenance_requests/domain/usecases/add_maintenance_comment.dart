import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddMaintenanceComment {
  const AddMaintenanceComment(this._repository);
  final MaintenanceRequestsRepository _repository;
  Future<MaintenanceComment> call(String requestId, String message) =>
      _repository.addComment(requestId, message);
}
