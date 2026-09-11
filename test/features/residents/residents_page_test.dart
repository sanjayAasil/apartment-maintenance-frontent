import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/paged_residents.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_residents.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/residents_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/residents/presentation/pages/residents_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'resident_fakes.dart';

class MockGetResidents extends Mock implements GetResidents {}

void main() {
  setUpAll(() => registerFallbackValue(const ResidentQuery()));
  tearDown(() async => getIt.reset());

  testWidgets('shows resident list loading', (tester) async {
    final getResidents = MockGetResidents();
    final pending = Completer<PagedResidents>();
    when(() => getResidents(any())).thenAnswer((_) => pending.future);
    getIt.registerFactory<ResidentsListBloc>(
      () => ResidentsListBloc(getResidents),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ResidentsPage())),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows loaded residents', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final getResidents = MockGetResidents();
    when(() => getResidents(any())).thenAnswer(
      (_) async =>
          PagedResidents(items: [resident], total: 1, page: 1, pageSize: 20),
    );
    getIt.registerFactory<ResidentsListBloc>(
      () => ResidentsListBloc(getResidents),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ResidentsPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ravi Resident'), findsOneWidget);
    expect(find.text('A-204'), findsOneWidget);
  });

  testWidgets('shows resident empty state', (tester) async {
    final getResidents = MockGetResidents();
    when(() => getResidents(any())).thenAnswer(
      (_) async =>
          const PagedResidents(items: [], total: 0, page: 1, pageSize: 20),
    );
    getIt.registerFactory<ResidentsListBloc>(
      () => ResidentsListBloc(getResidents),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ResidentsPage())),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No residents match the selected filters.'),
      findsOneWidget,
    );
  });

  testWidgets('shows resident error state', (tester) async {
    final getResidents = MockGetResidents();
    when(() => getResidents(any())).thenThrow(
      const Failure(kind: FailureKind.server, message: 'Residents failed'),
    );
    getIt.registerFactory<ResidentsListBloc>(
      () => ResidentsListBloc(getResidents),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ResidentsPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Residents failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
