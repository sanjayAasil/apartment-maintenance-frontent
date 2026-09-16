import 'package:apartment_maintenance_frontent/core/constants/api_paths.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/data/models/dashboard_models.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';
import 'package:apartment_maintenance_frontent/features/parts/data/models/part_model.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/paged_parts.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DashboardRemoteDataSource {
  const DashboardRemoteDataSource(this._dio);
  final Dio _dio;

  Future<dynamic> _get(String report, [DashboardRange? range]) async =>
      (await _dio.get<dynamic>(
        ApiPaths.dashboardReport(report),
        queryParameters: range?.toQuery(),
      )).data;
  Map<String, dynamic> _object(dynamic value) {
    if (value is Map && value.containsKey('data')) value = value['data'];
    if (value is! Map) throw _malformed();
    return Map<String, dynamic>.from(value);
  }

  List<T> _list<T>(dynamic value, T Function(Map<String, dynamic>) decode) {
    if (value is Map && value.containsKey('data')) value = value['data'];
    if (value is! List) throw _malformed();
    return value
        .map((item) => decode(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Failure _malformed() => const Failure(
    kind: FailureKind.malformedResponse,
    message: 'The server returned an unexpected dashboard response.',
  );
  Future<DashboardSummary> getSummary() async =>
      DashboardModels.summary(_object(await _get('summary')));
  Future<List<RequestStatusCount>> getRequestsByStatus(
    DashboardRange range,
  ) async =>
      _list(await _get('requests-by-status', range), DashboardModels.status);
  Future<List<RequestCategoryCount>> getRequestsByCategory(
    DashboardRange range,
  ) async => _list(
    await _get('requests-by-category', range),
    DashboardModels.category,
  );
  Future<List<TechnicianWorkload>> getTechnicianWorkload(
    DashboardRange range,
  ) async =>
      _list(await _get('technician-workload', range), DashboardModels.workload);
  Future<MaintenanceCostSummary> getMonthlyCost(DashboardRange range) async =>
      DashboardModels.cost(_object(await _get('monthly-cost', range)));
  Future<ResolutionTimeSummary> getAverageResolutionTime(
    DashboardRange range,
  ) async => DashboardModels.resolution(
    _object(await _get('average-resolution-time', range)),
  );
  Future<FeedbackSummary> getFeedbackSummary(DashboardRange range) async =>
      DashboardModels.feedback(_object(await _get('feedback-summary', range)));
  Future<PagedParts> getLowStockParts() async {
    final value = await _get('low-stock-parts');
    if (value is! Map || value['data'] is! List || value['meta'] is! Map) {
      throw _malformed();
    }
    final meta = Map<String, dynamic>.from(value['meta'] as Map);
    return PagedParts(
      items: _list(value, (json) => PartModel.fromJson(json).toEntity()),
      total: meta['total'] as int,
      page: meta['page'] as int,
      pageSize: meta['limit'] as int,
    );
  }
}
