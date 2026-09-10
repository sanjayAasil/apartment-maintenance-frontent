import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment_query.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/paged_apartments.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartments.dart';
import 'package:apartment_maintenance_frontent/features/apartments/presentation/bloc/apartments_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetApartments extends Mock implements GetApartments {}

const apartment = Apartment(
  id: 'apartment-1',
  block: 'A',
  floor: 2,
  unitNumber: '204',
);

void main() {
  setUpAll(() => registerFallbackValue(const ApartmentQuery()));

  blocTest<ApartmentsListBloc, ApartmentsListState>(
    'loads a paginated apartment list',
    build: () {
      final getApartments = MockGetApartments();
      when(() => getApartments(any())).thenAnswer(
        (_) async => const PagedApartments(
          items: [apartment],
          total: 1,
          page: 1,
          pageSize: 20,
        ),
      );
      return ApartmentsListBloc(getApartments);
    },
    act: (bloc) => bloc.add(const ApartmentsRequested()),
    expect: () => const [
      ApartmentsListState(status: ApartmentsListStatus.loading),
      ApartmentsListState(
        status: ApartmentsListStatus.success,
        result: PagedApartments(
          items: [apartment],
          total: 1,
          page: 1,
          pageSize: 20,
        ),
      ),
    ],
  );

  blocTest<ApartmentsListBloc, ApartmentsListState>(
    'exposes list loading errors',
    build: () {
      final getApartments = MockGetApartments();
      when(() => getApartments(any())).thenThrow(
        const Failure(
          kind: FailureKind.connection,
          message: 'Could not connect.',
        ),
      );
      return ApartmentsListBloc(getApartments);
    },
    act: (bloc) => bloc.add(const ApartmentsRequested()),
    verify: (bloc) {
      expect(bloc.state.status, ApartmentsListStatus.failure);
      expect(bloc.state.failure?.kind, FailureKind.connection);
    },
  );
}
