import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/paged_maintenance_requests.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMaintenanceRequests {
  const GetMaintenanceRequests(this._repository);
  final MaintenanceRequestsRepository _repository;
  Future<PagedMaintenanceRequests> call(MaintenanceRequestQuery query) =>
      _repository.getRequests(query);
}
