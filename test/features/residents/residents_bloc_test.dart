import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/paged_residents.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_current_resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_residents.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/current_resident_bloc.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/residents_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'resident_fakes.dart';

class MockGetResidents extends Mock implements GetResidents {}

class MockGetResident extends Mock implements GetResident {}

class MockGetCurrentResident extends Mock implements GetCurrentResident {}

void main() {
  setUpAll(() => registerFallbackValue(const ResidentQuery()));

  blocTest<ResidentsListBloc, ResidentsListState>(
    'loads residents successfully',
    build: () {
      final getResidents = MockGetResidents();
      when(() => getResidents(any())).thenAnswer(
        (_) async =>
            PagedResidents(items: [resident], total: 1, page: 1, pageSize: 20),
      );
      return ResidentsListBloc(getResidents);
    },
    act: (bloc) => bloc.add(const ResidentsRequested()),
    verify: (bloc) {
      expect(bloc.state.status, ResidentsListStatus.success);
      expect(bloc.state.result?.items.single, resident);
    },
  );

  blocTest<ResidentsListBloc, ResidentsListState>(
    'emits empty for an empty list',
    build: () {
      final getResidents = MockGetResidents();
      when(() => getResidents(any())).thenAnswer(
        (_) async =>
            const PagedResidents(items: [], total: 0, page: 1, pageSize: 20),
      );
      return ResidentsListBloc(getResidents);
    },
    act: (bloc) => bloc.add(const ResidentsRequested()),
    verify: (bloc) => expect(bloc.state.status, ResidentsListStatus.empty),
  );

  blocTest<ResidentsListBloc, ResidentsListState>(
    'emits failure when loading fails',
    build: () {
      final getResidents = MockGetResidents();
      when(() => getResidents(any())).thenThrow(
        const Failure(kind: FailureKind.server, message: 'Server failed'),
      );
      return ResidentsListBloc(getResidents);
    },
    act: (bloc) => bloc.add(const ResidentsRequested()),
    verify: (bloc) => expect(bloc.state.status, ResidentsListStatus.failure),
  );

  blocTest<ResidentDetailsBloc, ResidentDetailsState>(
    'loads resident details',
    build: () {
      final getResident = MockGetResident();
      when(() => getResident('resident-1')).thenAnswer((_) async => resident);
      return ResidentDetailsBloc(getResident);
    },
    act: (bloc) => bloc.add(const ResidentDetailsRequested('resident-1')),
    verify: (bloc) => expect(bloc.state.resident, resident),
  );

  blocTest<CurrentResidentBloc, CurrentResidentState>(
    'loads the current resident profile',
    build: () {
      final getCurrent = MockGetCurrentResident();
      when(getCurrent.call).thenAnswer((_) async => resident);
      return CurrentResidentBloc(getCurrent);
    },
    act: (bloc) => bloc.add(const CurrentResidentRequested()),
    verify: (bloc) {
      expect(bloc.state.status, CurrentResidentStatus.success);
      expect(bloc.state.resident, resident);
    },
  );
}
