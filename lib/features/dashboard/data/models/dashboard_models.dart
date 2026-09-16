import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';

abstract final class DashboardModels {
  static DashboardSummary summary(Map<String, dynamic> json) =>
      DashboardSummary(
        totalRequests: json['totalRequests'] as int,
        openRequests: json['openRequests'] as int,
        assignedRequests: json['assignedRequests'] as int,
        inProgressRequests: json['inProgressRequests'] as int,
        urgentRequests: json['urgentRequests'] as int,
        resolvedToday: json['resolvedToday'] as int,
        closedThisMonth: json['closedThisMonth'] as int,
        activeTechnicians: json['activeTechnicians'] as int,
        availableTechnicians: json['availableTechnicians'] as int,
        activeResidents: json['activeResidents'] as int,
        lowStockParts: json['lowStockParts'] as int,
      );
  static RequestStatusCount status(Map<String, dynamic> json) =>
      RequestStatusCount(
        status: json['status'] as String,
        count: json['count'] as int,
      );
  static RequestCategoryCount category(Map<String, dynamic> json) =>
      RequestCategoryCount(
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        count: json['count'] as int,
      );
  static TechnicianWorkload workload(Map<String, dynamic> json) =>
      TechnicianWorkload(
        technicianId: json['technicianId'] as String,
        name: json['name'] as String,
        activeAssignments: json['activeAssignments'] as int,
        inProgressRequests: json['inProgressRequests'] as int,
        resolvedCount: json['resolvedCount'] as int,
        isAvailable: json['isAvailable'] as bool,
        isActive: json['isActive'] as bool,
      );
  static MaintenanceCostSummary cost(Map<String, dynamic> json) =>
      MaintenanceCostSummary(
        partsCost: (json['partsCost'] as num).toDouble(),
        laborCost: (json['laborCost'] as num).toDouble(),
        otherCost: (json['otherCost'] as num).toDouble(),
        totalCost: (json['totalCost'] as num).toDouble(),
      );
  static ResolutionTimeSummary resolution(Map<String, dynamic> json) =>
      ResolutionTimeSummary(
        averageMinutes: (json['averageMinutes'] as num?)?.toDouble(),
        averageHours: (json['averageHours'] as num?)?.toDouble(),
        resolvedRequests: json['resolvedRequests'] as int,
      );
  static FeedbackSummary feedback(Map<String, dynamic> json) => FeedbackSummary(
    totalFeedback: json['totalFeedback'] as int,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    ratings: Map<String, int>.from(json['ratings'] as Map),
  );
}
