import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/paged_parts.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDashboard {
  const GetDashboard(this._repository);
  final DashboardRepository _repository;
  Future<DashboardData> call(DashboardRange range) async {
    final results = await Future.wait<Object>([
      _repository.getSummary(),
      _repository.getRequestsByStatus(range),
      _repository.getRequestsByCategory(range),
      _repository.getTechnicianWorkload(range),
      _repository.getMonthlyCost(range),
      _repository.getAverageResolutionTime(range),
      _repository.getFeedbackSummary(range),
      _repository.getLowStockParts(),
    ]);
    final stock = results[7] as PagedParts;
    return DashboardData(
      summary: results[0] as DashboardSummary,
      statuses: results[1] as List<RequestStatusCount>,
      categories: results[2] as List<RequestCategoryCount>,
      workload: results[3] as List<TechnicianWorkload>,
      cost: results[4] as MaintenanceCostSummary,
      resolution: results[5] as ResolutionTimeSummary,
      feedback: results[6] as FeedbackSummary,
      lowStockParts: stock.items,
      lowStockTotal: stock.total,
    );
  }
}
