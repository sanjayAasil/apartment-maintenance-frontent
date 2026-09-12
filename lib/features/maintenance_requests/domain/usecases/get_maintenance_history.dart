import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMaintenanceHistory {
  const GetMaintenanceHistory(this._repository);
  final MaintenanceRequestsRepository _repository;
  Future<List<MaintenanceHistoryEntry>> call(String requestId) =>
      _repository.getHistory(requestId);
}
