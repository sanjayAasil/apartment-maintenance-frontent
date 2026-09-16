import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';

class DashboardRange {
  const DashboardRange({required this.from, required this.to});
  factory DashboardRange.thisMonth() {
    final now = DateTime.now().toUtc();
    return DashboardRange(
      from: DateTime.utc(now.year, now.month),
      to: DateTime.utc(now.year, now.month + 1, 0),
    );
  }
  final DateTime from;
  final DateTime to;
  Map<String, String> toQuery() => {'from': date(from), 'to': date(to)};
  static String date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalRequests,
    required this.openRequests,
    required this.assignedRequests,
    required this.inProgressRequests,
    required this.urgentRequests,
    required this.resolvedToday,
    required this.closedThisMonth,
    required this.activeTechnicians,
    required this.availableTechnicians,
    required this.activeResidents,
    required this.lowStockParts,
  });
  final int totalRequests,
      openRequests,
      assignedRequests,
      inProgressRequests,
      urgentRequests,
      resolvedToday,
      closedThisMonth,
      activeTechnicians,
      availableTechnicians,
      activeResidents,
      lowStockParts;
}

class RequestStatusCount {
  const RequestStatusCount({required this.status, required this.count});
  final String status;
  final int count;
  String get label => status
      .toLowerCase()
      .split('_')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

class RequestCategoryCount {
  const RequestCategoryCount({
    required this.categoryId,
    required this.categoryName,
    required this.count,
  });
  final String categoryId, categoryName;
  final int count;
}

class TechnicianWorkload {
  const TechnicianWorkload({
    required this.technicianId,
    required this.name,
    required this.activeAssignments,
    required this.inProgressRequests,
    required this.resolvedCount,
    required this.isAvailable,
    required this.isActive,
  });
  final String technicianId, name;
  final int activeAssignments, inProgressRequests, resolvedCount;
  final bool isAvailable, isActive;
}

class MaintenanceCostSummary {
  const MaintenanceCostSummary({
    required this.partsCost,
    required this.laborCost,
    required this.otherCost,
    required this.totalCost,
  });
  final double partsCost, laborCost, otherCost, totalCost;
}

class ResolutionTimeSummary {
  const ResolutionTimeSummary({
    required this.averageMinutes,
    required this.averageHours,
    required this.resolvedRequests,
  });
  final double? averageMinutes, averageHours;
  final int resolvedRequests;
}

class FeedbackSummary {
  const FeedbackSummary({
    required this.totalFeedback,
    required this.averageRating,
    required this.ratings,
  });
  final int totalFeedback;
  final double? averageRating;
  final Map<String, int> ratings;
}

class DashboardData {
  const DashboardData({
    required this.summary,
    required this.statuses,
    required this.categories,
    required this.workload,
    required this.cost,
    required this.resolution,
    required this.feedback,
    required this.lowStockParts,
    required this.lowStockTotal,
  });
  final DashboardSummary summary;
  final List<RequestStatusCount> statuses;
  final List<RequestCategoryCount> categories;
  final List<TechnicianWorkload> workload;
  final MaintenanceCostSummary cost;
  final ResolutionTimeSummary resolution;
  final FeedbackSummary feedback;
  final List<Part> lowStockParts;
  final int lowStockTotal;
}
