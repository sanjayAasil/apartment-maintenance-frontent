import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/paged_technicians.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/add_technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/create_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_current_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_technicians.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/remove_technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_availability.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_status.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/current_technician_cubit.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_mutation_cubit.dart';
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technicians_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'technician_fakes.dart';

class MockGetTechnicians extends Mock implements GetTechnicians {}

class MockGetCurrentTechnician extends Mock implements GetCurrentTechnician {}

class MockUpdateAvailability extends Mock
    implements UpdateTechnicianAvailability {}

class MockGetUsers extends Mock implements GetUsers {}

class MockGetCategories extends Mock implements GetMaintenanceCategories {}

class MockCreateTechnician extends Mock implements CreateTechnician {}

class MockUpdateTechnician extends Mock implements UpdateTechnician {}

class MockUpdateStatus extends Mock implements UpdateTechnicianStatus {}

class MockAddSkill extends Mock implements AddTechnicianSkill {}

class MockRemoveSkill extends Mock implements RemoveTechnicianSkill {}

TechnicianMutationCubit mutationCubit({
  MockCreateTechnician? create,
  MockUpdateAvailability? availability,
  MockAddSkill? addSkill,
  MockRemoveSkill? removeSkill,
}) => TechnicianMutationCubit(
  MockGetUsers(),
  MockGetCategories(),
  create ?? MockCreateTechnician(),
  MockUpdateTechnician(),
  MockUpdateStatus(),
  availability ?? MockUpdateAvailability(),
  addSkill ?? MockAddSkill(),
  removeSkill ?? MockRemoveSkill(),
);

void main() {
  setUpAll(() => registerFallbackValue(const TechnicianQuery()));

  blocTest<TechniciansListBloc, TechniciansListState>(
    'loads technicians successfully',
    build: () {
      final get = MockGetTechnicians();
      when(() => get(any())).thenAnswer(
        (_) async => const PagedTechnicians(
          items: [technician],
          total: 1,
          page: 1,
          pageSize: 20,
        ),
      );
      return TechniciansListBloc(get);
    },
    act: (bloc) => bloc.add(const TechniciansRequested()),
    verify: (bloc) => expect(bloc.state.status, TechniciansListStatus.success),
  );

  blocTest<TechniciansListBloc, TechniciansListState>(
    'handles empty and failure results',
    build: () {
      final get = MockGetTechnicians();
      when(
        () => get(any()),
      ).thenThrow(const Failure(kind: FailureKind.server, message: 'Failed'));
      return TechniciansListBloc(get);
    },
    act: (bloc) => bloc.add(const TechniciansRequested()),
    verify: (bloc) => expect(bloc.state.status, TechniciansListStatus.failure),
  );

  blocTest<CurrentTechnicianCubit, CurrentTechnicianState>(
    'loads current technician and updates own availability',
    build: () {
      final get = MockGetCurrentTechnician();
      final update = MockUpdateAvailability();
      when(() => get()).thenAnswer((_) async => technician);
      when(() => update('technician-1', false)).thenAnswer(
        (_) async => Technician(
          id: technician.id,
          userId: technician.userId,
          phone: technician.phone,
          experienceYears: technician.experienceYears,
          isAvailable: false,
          isActive: technician.isActive,
          user: technician.user,
          skills: technician.skills,
        ),
      );
      return CurrentTechnicianCubit(get, update);
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.setAvailability(false);
    },
    verify: (cubit) => expect(cubit.state.technician?.isAvailable, false),
  );

  blocTest<TechnicianMutationCubit, TechnicianMutationState>(
    'creates a technician',
    build: () {
      final create = MockCreateTechnician();
      when(
        () => create('user-1', '9876543210', 3),
      ).thenAnswer((_) async => technician);
      return mutationCubit(create: create);
    },
    act: (cubit) => cubit.create('user-1', '9876543210', 3),
    verify: (cubit) =>
        expect(cubit.state.status, TechnicianMutationStatus.success),
  );

  blocTest<TechnicianMutationCubit, TechnicianMutationState>(
    'adds and removes skills',
    build: () {
      final add = MockAddSkill();
      final remove = MockRemoveSkill();
      when(
        () => add('technician-1', 'category-1'),
      ).thenAnswer((_) async => technicianSkill);
      when(() => remove('technician-1', 'category-1')).thenAnswer((_) async {});
      return mutationCubit(addSkill: add, removeSkill: remove);
    },
    act: (cubit) async {
      await cubit.addSkill('technician-1', 'category-1');
      await cubit.removeSkill('technician-1', 'category-1');
    },
    verify: (cubit) =>
        expect(cubit.state.status, TechnicianMutationStatus.success),
  );
}
