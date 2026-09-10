import 'dart:async';

import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/paged_users.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/users_list_bloc.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/pages/users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetUsers extends Mock implements GetUsers {}

void main() {
  setUpAll(() => registerFallbackValue(const UserQuery()));

  tearDown(() async => getIt.reset());

  testWidgets(
    'shows loading safely while the initial users request is pending',
    (tester) async {
      final getUsers = MockGetUsers();
      final pending = Completer<PagedUsers>();
      when(() => getUsers(any())).thenAnswer((_) => pending.future);
      getIt.registerFactory<UsersListBloc>(() => UsersListBloc(getUsers));

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UsersPage())),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
