import 'package:apartment_maintenance_frontent/features/users/domain/entities/paged_users.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/users_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockGetUsers extends Mock implements GetUsers {}

void main() {
  setUpAll(() => registerFallbackValue(const UserQuery()));

  blocTest<UsersListBloc, UsersListState>(
    'loads success and preserves explicit pagination',
    build: () {
      final getUsers = MockGetUsers();
      when(() => getUsers(any())).thenAnswer((invocation) async {
        final query = invocation.positionalArguments.single as UserQuery;
        return PagedUsers(
          items: const [adminUser],
          total: 20,
          page: query.page,
          pageSize: query.pageSize,
        );
      });
      return UsersListBloc(getUsers);
    },
    act: (bloc) => bloc.add(const UsersPageChanged(2)),
    verify: (bloc) {
      expect(bloc.state.status, UsersListStatus.success);
      expect(bloc.state.query.page, 2);
    },
  );

  blocTest<UsersListBloc, UsersListState>(
    'emits empty when no users match filters',
    build: () {
      final getUsers = MockGetUsers();
      when(() => getUsers(any())).thenAnswer(
        (_) async =>
            const PagedUsers(items: [], total: 0, page: 1, pageSize: 10),
      );
      return UsersListBloc(getUsers);
    },
    act: (bloc) => bloc.add(const UsersSearchChanged('nobody')),
    verify: (bloc) => expect(bloc.state.status, UsersListStatus.empty),
  );
}
