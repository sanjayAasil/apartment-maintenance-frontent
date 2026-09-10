import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/create_apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/update_apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/presentation/bloc/apartment_form_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetApartment extends Mock implements GetApartment {}

class MockCreateApartment extends Mock implements CreateApartment {}

class MockUpdateApartment extends Mock implements UpdateApartment {}

const apartment = Apartment(
  id: 'apartment-1',
  block: 'A',
  floor: 2,
  unitNumber: '204',
);

void main() {
  blocTest<ApartmentFormCubit, ApartmentFormState>(
    'creates an apartment',
    build: () {
      final create = MockCreateApartment();
      when(() => create('A', 2, '204')).thenAnswer((_) async => apartment);
      return ApartmentFormCubit(
        MockGetApartment(),
        create,
        MockUpdateApartment(),
      );
    },
    act: (cubit) => cubit.create('A', 2, '204'),
    expect: () => const [
      ApartmentFormState(status: ApartmentFormStatus.creating),
      ApartmentFormState(
        status: ApartmentFormStatus.success,
        apartment: apartment,
      ),
    ],
  );

  blocTest<ApartmentFormCubit, ApartmentFormState>(
    'loads and updates an apartment',
    build: () {
      final getApartment = MockGetApartment();
      final update = MockUpdateApartment();
      when(
        () => getApartment('apartment-1'),
      ).thenAnswer((_) async => apartment);
      when(() => update('apartment-1', 'B', 3, '301')).thenAnswer(
        (_) async => const Apartment(
          id: 'apartment-1',
          block: 'B',
          floor: 3,
          unitNumber: '301',
        ),
      );
      return ApartmentFormCubit(getApartment, MockCreateApartment(), update);
    },
    act: (cubit) async {
      await cubit.load('apartment-1');
      await cubit.update('apartment-1', 'B', 3, '301');
    },
    verify: (cubit) {
      expect(cubit.state.status, ApartmentFormStatus.success);
      expect(cubit.state.apartment?.block, 'B');
    },
  );

  blocTest<ApartmentFormCubit, ApartmentFormState>(
    'maps duplicate create errors for the form',
    build: () {
      final create = MockCreateApartment();
      when(() => create('A', 2, '204')).thenThrow(
        const Failure(
          kind: FailureKind.conflict,
          message: 'Apartment A-204 already exists',
        ),
      );
      return ApartmentFormCubit(
        MockGetApartment(),
        create,
        MockUpdateApartment(),
      );
    },
    act: (cubit) => cubit.create('A', 2, '204'),
    verify: (cubit) {
      expect(cubit.state.status, ApartmentFormStatus.failure);
      expect(cubit.state.failure?.kind, FailureKind.conflict);
    },
  );
}
