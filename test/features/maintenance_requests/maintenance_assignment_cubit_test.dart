import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/assign_technician.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_assignment_history.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/reassign_technician.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/unassign_technician.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_assignment_cubit.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_available_technicians.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../technicians/technician_fakes.dart';
import 'maintenance_request_fakes.dart';

class MockGetAvailable extends Mock implements GetAvailableTechnicians {}

class MockGetHistory extends Mock implements GetAssignmentHistory {}

class MockAssign extends Mock implements AssignTechnician {}

class MockReassign extends Mock implements ReassignTechnician {}

class MockUnassign extends Mock implements UnassignTechnician {}

void main() {
  late MockGetAvailable getAvailable;
  late MockGetHistory getHistory;
  late MockAssign assign;
  late MockReassign reassign;
  late MockUnassign unassign;

  MaintenanceAssignmentCubit buildCubit() => MaintenanceAssignmentCubit(
    getAvailable,
    getHistory,
    assign,
    reassign,
    unassign,
  );

  setUp(() {
    getAvailable = MockGetAvailable();
    getHistory = MockGetHistory();
    assign = MockAssign();
    reassign = MockReassign();
    unassign = MockUnassign();
  });

  blocTest<MaintenanceAssignmentCubit, MaintenanceAssignmentState>(
    'loads available matching technicians and assignment history',
    build: () {
      when(
        () => getAvailable('category-1'),
      ).thenAnswer((_) async => [technician]);
      when(
        () => getHistory('request-1'),
      ).thenAnswer((_) async => [maintenanceAssignment]);
      return buildCubit();
    },
    act: (cubit) => cubit.load(assignedMaintenanceRequest),
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceAssignmentStatus.ready);
      expect(cubit.state.availableTechnicians, [technician]);
      expect(cubit.state.history, [maintenanceAssignment]);
    },
  );

  blocTest<MaintenanceAssignmentCubit, MaintenanceAssignmentState>(
    'assigns and reassigns successfully',
    build: () {
      when(
        () => assign('request-1', 'technician-1'),
      ).thenAnswer((_) async => maintenanceAssignment);
      when(
        () => reassign('request-1', 'technician-2'),
      ).thenAnswer((_) async => maintenanceAssignment);
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.assign('request-1', 'technician-1');
      await cubit.reassign('request-1', 'technician-2');
    },
    verify: (cubit) =>
        expect(cubit.state.status, MaintenanceAssignmentStatus.success),
  );

  blocTest<MaintenanceAssignmentCubit, MaintenanceAssignmentState>(
    'unassigns successfully',
    build: () {
      when(() => unassign('request-1')).thenAnswer((_) async {});
      return buildCubit();
    },
    act: (cubit) => cubit.unassign('request-1'),
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceAssignmentStatus.success);
      expect(cubit.state.assignment, isNull);
    },
  );

  blocTest<MaintenanceAssignmentCubit, MaintenanceAssignmentState>(
    'maps assignment failures',
    build: () {
      when(() => assign('request-1', 'technician-1')).thenThrow(
        const Failure(kind: FailureKind.conflict, message: 'Already assigned'),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.assign('request-1', 'technician-1'),
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceAssignmentStatus.failure);
      expect(cubit.state.failure?.kind, FailureKind.conflict);
    },
  );
}
