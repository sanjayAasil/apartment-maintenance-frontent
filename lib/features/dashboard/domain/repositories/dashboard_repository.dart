import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/paged_parts.dart';

abstract interface class DashboardRepository {
  Future<DashboardSummary> getSummary();
  Future<List<RequestStatusCount>> getRequestsByStatus(DashboardRange range);
  Future<List<RequestCategoryCount>> getRequestsByCategory(
    DashboardRange range,
  );
  Future<List<TechnicianWorkload>> getTechnicianWorkload(DashboardRange range);
  Future<MaintenanceCostSummary> getMonthlyCost(DashboardRange range);
  Future<ResolutionTimeSummary> getAverageResolutionTime(DashboardRange range);
  Future<FeedbackSummary> getFeedbackSummary(DashboardRange range);
  Future<PagedParts> getLowStockParts();
}
