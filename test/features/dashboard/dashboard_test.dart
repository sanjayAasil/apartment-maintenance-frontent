import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/data/models/dashboard_models.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/usecases/get_dashboard.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class UnusedRepository implements DashboardRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeReport extends GetDashboard {
  FakeReport() : super(UnusedRepository());
  bool fail = false;
  @override
  Future<DashboardData> call(DashboardRange range) async {
    if (fail) {
      throw const Failure(
        kind: FailureKind.server,
        message: 'Report unavailable',
      );
    }
    return DashboardData(
      summary: DashboardModels.summary({
        for (final key in [
          'totalRequests',
          'openRequests',
          'assignedRequests',
          'inProgressRequests',
          'urgentRequests',
          'resolvedToday',
          'closedThisMonth',
          'activeTechnicians',
          'availableTechnicians',
          'activeResidents',
          'lowStockParts',
        ])
          key: 0,
      }),
      statuses: const [],
      categories: const [],
      workload: const [],
      cost: const MaintenanceCostSummary(
        partsCost: 0,
        laborCost: 0,
        otherCost: 0,
        totalCost: 0,
      ),
      resolution: const ResolutionTimeSummary(
        averageMinutes: null,
        averageHours: null,
        resolvedRequests: 0,
      ),
      feedback: const FeedbackSummary(
        totalFeedback: 0,
        averageRating: null,
        ratings: {},
      ),
      lowStockParts: const [],
      lowStockTotal: 0,
    );
  }
}

void main() {
  final range = DashboardRange(
    from: DateTime.utc(2026, 9, 1),
    to: DateTime.utc(2026, 9, 30),
  );
  test('maps all report models and nullable empty metrics', () {
    expect(
      DashboardModels.status({'status': 'IN_PROGRESS', 'count': 3}).label,
      'In Progress',
    );
    expect(
      DashboardModels.category({
        'categoryId': 'c',
        'categoryName': 'Plumbing',
        'count': 4,
      }).count,
      4,
    );
    expect(
      DashboardModels.workload({
        'technicianId': 't',
        'name': 'Ravi',
        'activeAssignments': 3,
        'inProgressRequests': 2,
        'resolvedCount': 4,
        'isAvailable': true,
        'isActive': true,
      }).name,
      'Ravi',
    );
    expect(
      DashboardModels.cost({
        'partsCost': 20,
        'laborCost': 10,
        'otherCost': 5,
        'totalCost': 35,
      }).totalCost,
      35,
    );
    expect(
      DashboardModels.feedback({
        'totalFeedback': 0,
        'averageRating': null,
        'ratings': {'1': 0},
      }).averageRating,
      isNull,
    );
    expect(
      DashboardModels.resolution({
        'averageMinutes': null,
        'averageHours': null,
        'resolvedRequests': 0,
      }).resolvedRequests,
      0,
    );
  });
  test('remote forwards calendar date filter and unwraps report', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test'));
    DioAdapter(dio: dio).onGet(
      '/dashboard/requests-by-status',
      (server) => server.reply(200, {
        'success': true,
        'data': [
          {'status': 'OPEN', 'count': 2},
        ],
      }),
      queryParameters: range.toQuery(),
    );
    final result = await DashboardRemoteDataSource(
      dio,
    ).getRequestsByStatus(range);
    expect(result.single.count, 2);
    expect(range.toQuery(), {'from': '2026-09-01', 'to': '2026-09-30'});
  });
  test(
    'load and refresh preserve successful data on explicit failure',
    () async {
      final report = FakeReport();
      final cubit = DashboardCubit(report);
      final statuses = <DashboardStatus>[];
      final subscription = cubit.stream.listen(
        (state) => statuses.add(state.status),
      );
      await cubit.load(range);
      expect(cubit.state.data, isNotNull);
      report.fail = true;
      await cubit.load();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.failure?.message, 'Report unavailable');
      expect(cubit.state.data, isNotNull);
      expect(cubit.state.range, range);
      expect(statuses, [
        DashboardStatus.loading,
        DashboardStatus.loaded,
        DashboardStatus.refreshing,
        DashboardStatus.failure,
      ]);
      await subscription.cancel();
      await cubit.close();
    },
  );
  test('initial failure does not manufacture zero metrics', () async {
    final report = FakeReport()..fail = true;
    final cubit = DashboardCubit(report);
    await cubit.load(range);
    expect(cubit.state.status, DashboardStatus.failure);
    expect(cubit.state.data, isNull);
    await cubit.close();
  });
  testWidgets('renders summary and empty reports responsively', (tester) async {
    final cubit = DashboardCubit(FakeReport());
    await cubit.load(range);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(value: cubit, child: const DashboardView()),
        ),
      ),
    );
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Open Requests'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await cubit.close();
  });
}
