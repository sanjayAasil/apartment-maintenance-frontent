import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/data/datasources/users_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/users/data/models/user_model.dart';
import 'package:apartment_maintenance_frontent/features/users/data/repositories/users_repository_impl.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUsersRemote extends Mock implements UsersRemoteDataSource {}

const users = [
  UserModel(
    id: '1',
    name: 'Alice Admin',
    email: 'alice@example.com',
    role: 'ADMIN',
    isActive: true,
  ),
  UserModel(
    id: '2',
    name: 'Ravi Resident',
    email: 'ravi@example.com',
    role: 'RESIDENT',
    isActive: true,
  ),
  UserModel(
    id: '3',
    name: 'Tina Tech',
    email: 'tina@example.com',
    role: 'TECHNICIAN',
    isActive: false,
  ),
];

void main() {
  late MockUsersRemote remote;
  late UsersRepositoryImpl repository;
  setUp(() {
    remote = MockUsersRemote();
    repository = UsersRepositoryImpl(remote);
    when(remote.getUsers).thenAnswer((_) async => users);
  });

  test('filters by search, role, and active status', () async {
    final result = await repository.getUsers(
      const UserQuery(
        search: 'tina',
        role: UserRole.technician,
        isActive: false,
      ),
    );
    expect(result.items.single.id, '3');
  });

  test('paginates the API collection locally', () async {
    final result = await repository.getUsers(
      const UserQuery(page: 2, pageSize: 2),
    );
    expect(result.total, 3);
    expect(result.items.single.id, '3');
  });

  test(
    'passes update and status mutations through and decodes users',
    () async {
      when(
        () => remote.updateUser(
          '1',
          'New Name',
          'new@example.com',
          UserRole.admin,
        ),
      ).thenAnswer((_) async => users.first);
      when(
        () => remote.setActive('1', false),
      ).thenAnswer((_) async => users.first);
      await repository.updateUser(
        id: '1',
        name: 'New Name',
        email: 'new@example.com',
        role: UserRole.admin,
      );
      await repository.setActive('1', false);
      verify(() => remote.setActive('1', false)).called(1);
    },
  );
}
