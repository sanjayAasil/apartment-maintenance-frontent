import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment_query.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/paged_apartments.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartments.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/change_resident_apartment.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/create_resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/update_resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/update_resident_status.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_mutation_cubit.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/pages/add_resident_page.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/paged_users.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:flutter/material.dart';
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

void main() {
  setUpAll(() {
    registerFallbackValue(const UserQuery());
    registerFallbackValue(const ApartmentQuery());
  });
  tearDown(() async => getIt.reset());

  testWidgets('validates required resident form fields', (tester) async {
    final getUsers = MockGetUsers();
    final getApartments = MockGetApartments();
    when(() => getUsers(any())).thenAnswer(
      (_) async => const PagedUsers(
        items: [residentUser],
        total: 1,
        page: 1,
        pageSize: 100,
      ),
    );
    when(() => getApartments(any())).thenAnswer(
      (_) async => const PagedApartments(
        items: [residentApartment],
        total: 1,
        page: 1,
        pageSize: 100,
      ),
    );
    getIt.registerFactory<ResidentMutationCubit>(
      () => ResidentMutationCubit(
        getUsers,
        getApartments,
        MockCreateResident(),
        MockUpdateResident(),
        MockChangeResidentApartment(),
        MockUpdateResidentStatus(),
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AddResidentPage())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saveResidentButton')));
    await tester.pump();

    expect(find.text('Select a resident user.'), findsOneWidget);
    expect(find.text('Select an apartment.'), findsOneWidget);
    expect(find.text('Phone is required.'), findsOneWidget);
    expect(find.text('Move-in date is required.'), findsOneWidget);
  });
}
