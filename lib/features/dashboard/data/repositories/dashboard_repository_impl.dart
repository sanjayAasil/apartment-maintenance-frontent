import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/paged_parts.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remote);
  final DashboardRemoteDataSource _remote;
  Future<T> _safe<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<DashboardSummary> getSummary() => _safe(_remote.getSummary);
  @override
  Future<List<RequestStatusCount>> getRequestsByStatus(DashboardRange range) =>
      _safe(() => _remote.getRequestsByStatus(range));
  @override
  Future<List<RequestCategoryCount>> getRequestsByCategory(
    DashboardRange range,
  ) => _safe(() => _remote.getRequestsByCategory(range));
  @override
  Future<List<TechnicianWorkload>> getTechnicianWorkload(
    DashboardRange range,
  ) => _safe(() => _remote.getTechnicianWorkload(range));
  @override
  Future<MaintenanceCostSummary> getMonthlyCost(DashboardRange range) =>
      _safe(() => _remote.getMonthlyCost(range));
  @override
  Future<ResolutionTimeSummary> getAverageResolutionTime(
    DashboardRange range,
  ) => _safe(() => _remote.getAverageResolutionTime(range));
  @override
  Future<FeedbackSummary> getFeedbackSummary(DashboardRange range) =>
      _safe(() => _remote.getFeedbackSummary(range));
  @override
  Future<PagedParts> getLowStockParts() => _safe(_remote.getLowStockParts);
}
