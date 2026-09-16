import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_feedback.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMaintenanceFeedback {
  const GetMaintenanceFeedback(this._repository);
  final MaintenanceRequestsRepository _repository;

  Future<MaintenanceFeedback?> call(String requestId) =>
      _repository.getFeedback(requestId);
}

@injectable
class SubmitMaintenanceFeedback {
  const SubmitMaintenanceFeedback(this._repository);
  final MaintenanceRequestsRepository _repository;

  Future<MaintenanceFeedback> call(
    String requestId,
    int rating,
    String? comment,
  ) => _repository.submitFeedback(requestId, rating, comment);
}
