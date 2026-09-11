import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/paged_maintenance_requests.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_requests.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_requests_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_request_fakes.dart';

class MockGetMaintenanceRequests extends Mock
    implements GetMaintenanceRequests {}

void main() {
  setUpAll(() => registerFallbackValue(const MaintenanceRequestQuery()));
  blocTest<MaintenanceRequestsListBloc, MaintenanceRequestsListState>(
    'loads requests successfully',
    build: () {
      final get = MockGetMaintenanceRequests();
      when(() => get(any())).thenAnswer(
        (_) async => PagedMaintenanceRequests(
          items: [maintenanceRequest],
          total: 1,
          page: 1,
          pageSize: 20,
        ),
      );
      return MaintenanceRequestsListBloc(get);
    },
    act: (bloc) => bloc.add(const MaintenanceRequestsRequested()),
    verify: (bloc) =>
        expect(bloc.state.status, MaintenanceRequestsListStatus.success),
  );
  blocTest<MaintenanceRequestsListBloc, MaintenanceRequestsListState>(
    'emits empty for no requests',
    build: () {
      final get = MockGetMaintenanceRequests();
      when(() => get(any())).thenAnswer(
        (_) async => const PagedMaintenanceRequests(
          items: [],
          total: 0,
          page: 1,
          pageSize: 20,
        ),
      );
      return MaintenanceRequestsListBloc(get);
    },
    act: (bloc) => bloc.add(const MaintenanceRequestsRequested()),
    verify: (bloc) =>
        expect(bloc.state.status, MaintenanceRequestsListStatus.empty),
  );
  blocTest<MaintenanceRequestsListBloc, MaintenanceRequestsListState>(
    'maps failures',
    build: () {
      final get = MockGetMaintenanceRequests();
      when(
        () => get(any()),
      ).thenThrow(const Failure(kind: FailureKind.server, message: 'Failed'));
      return MaintenanceRequestsListBloc(get);
    },
    act: (bloc) => bloc.add(const MaintenanceRequestsRequested()),
    verify: (bloc) => expect(bloc.state.failure?.kind, FailureKind.server),
  );
}
