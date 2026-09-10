import 'package:apartment_maintenance_frontent/core/network/session_coordinator.dart';
import 'package:apartment_maintenance_frontent/core/storage/token_storage.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/models/auth_response_model.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/models/user_model.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemote extends Mock implements AuthRemoteDataSource {}

class MockStorage extends Mock implements TokenStorage {}

class MockSessions extends Mock implements SessionCoordinator {}

const model = UserModel(
  id: '1',
  name: 'Admin',
  email: 'admin@example.com',
  role: 'ADMIN',
  isActive: true,
);

void main() {
  late MockAuthRemote remote;
  late MockStorage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockAuthRemote();
    storage = MockStorage();
    final sessions = MockSessions();
    when(() => storage.write(any())).thenAnswer((_) async {});
    when(sessions.reset).thenReturn(null);
    repository = AuthRepositoryImpl(remote, storage, sessions);
  });

  test('login persists token and returns domain session', () async {
    when(() => remote.login('admin@example.com', 'password')).thenAnswer(
      (_) async => const AuthResponseModel(accessToken: 'jwt', user: model),
    );
    final result = await repository.login(
      email: ' admin@example.com ',
      password: 'password',
    );
    expect(result.user.id, '1');
    verify(() => storage.write('jwt')).called(1);
  });

  test('restore returns null without a token and does not call API', () async {
    when(storage.read).thenAnswer((_) async => null);
    expect(await repository.restoreSession(), isNull);
    verifyNever(remote.me);
  });

  test('logout clears local token', () async {
    when(storage.clear).thenAnswer((_) async {});
    await repository.logout();
    verify(storage.clear).called(1);
  });
}
