import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartments.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/change_resident_apartment.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/create_resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/update_resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/update_resident_status.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_mutation_cubit.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'resident_fakes.dart';

class MockGetUsers extends Mock implements GetUsers {}

class MockGetApartments extends Mock implements GetApartments {}

class MockCreateResident extends Mock implements CreateResident {}

class MockUpdateResident extends Mock implements UpdateResident {}

class MockChangeResidentApartment extends Mock
    implements ChangeResidentApartment {}

class MockUpdateResidentStatus extends Mock implements UpdateResidentStatus {}

ResidentMutationCubit buildCubit({
  MockCreateResident? create,
  MockUpdateResident? update,
  MockChangeResidentApartment? changeApartment,
  MockUpdateResidentStatus? updateStatus,
}) => ResidentMutationCubit(
  MockGetUsers(),
  MockGetApartments(),
  create ?? MockCreateResident(),
  update ?? MockUpdateResident(),
  changeApartment ?? MockChangeResidentApartment(),
  updateStatus ?? MockUpdateResidentStatus(),
);

void main() {
  blocTest<ResidentMutationCubit, ResidentMutationState>(
    'creates a resident',
    build: () {
      final create = MockCreateResident();
      when(
        () => create('user-1', 'apartment-1', '9876543210', '2026-09-01'),
      ).thenAnswer((_) async => resident);
      return buildCubit(create: create);
    },
    act: (cubit) =>
        cubit.create('user-1', 'apartment-1', '9876543210', '2026-09-01'),
    verify: (cubit) {
      expect(cubit.state.status, ResidentMutationStatus.success);
      expect(cubit.state.resident, resident);
    },
  );

  blocTest<ResidentMutationCubit, ResidentMutationState>(
    'exposes create conflicts',
    build: () {
      final create = MockCreateResident();
      when(() => create(any(), any(), any(), any())).thenThrow(
        const Failure(
          kind: FailureKind.conflict,
          message: 'Resident already exists',
        ),
      );
      return buildCubit(create: create);
    },
    act: (cubit) => cubit.create('u', 'a', '9999999', '2026-09-01'),
    verify: (cubit) {
      expect(cubit.state.status, ResidentMutationStatus.failure);
      expect(cubit.state.failure?.kind, FailureKind.conflict);
    },
  );

  blocTest<ResidentMutationCubit, ResidentMutationState>(
    'changes apartment',
    build: () {
      final change = MockChangeResidentApartment();
      when(
        () => change('resident-1', 'apartment-2'),
      ).thenAnswer((_) async => resident);
      return buildCubit(changeApartment: change);
    },
    act: (cubit) => cubit.changeApartment('resident-1', 'apartment-2'),
    verify: (cubit) =>
        expect(cubit.state.status, ResidentMutationStatus.success),
  );

  blocTest<ResidentMutationCubit, ResidentMutationState>(
    'updates resident profile fields',
    build: () {
      final update = MockUpdateResident();
      when(
        () => update('resident-1', '9999999999', '2026-09-02'),
      ).thenAnswer((_) async => resident);
      return buildCubit(update: update);
    },
    act: (cubit) => cubit.update('resident-1', '9999999999', '2026-09-02'),
    verify: (cubit) =>
        expect(cubit.state.status, ResidentMutationStatus.success),
  );

  blocTest<ResidentMutationCubit, ResidentMutationState>(
    'updates resident status',
    build: () {
      final updateStatus = MockUpdateResidentStatus();
      when(
        () => updateStatus('resident-1', false),
      ).thenAnswer((_) async => resident);
      return buildCubit(updateStatus: updateStatus);
    },
    act: (cubit) => cubit.updateStatus('resident-1', false),
    verify: (cubit) =>
        expect(cubit.state.status, ResidentMutationStatus.success),
  );
}
