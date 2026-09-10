import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/network/session_coordinator.dart';
import 'package:apartment_maintenance_frontent/core/storage/token_storage.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/models/auth_response_model.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/auth_session.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._storage, this._sessions);
  final AuthRemoteDataSource _remote;
  final TokenStorage _storage;
  final SessionCoordinator _sessions;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => _authenticate(() => _remote.login(email.trim(), password));

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) => _authenticate(
    () => _remote.register(name.trim(), email.trim(), password),
  );

  Future<AuthSession> _authenticate(
    Future<AuthResponseModel> Function() request,
  ) async {
    try {
      final model = await request();
      final session = model.toEntity();
      await _storage.write(session.accessToken);
      _sessions.reset();
      return session;
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<AppUser?> restoreSession() async {
    if ((await _storage.read()) case final token? when token.isNotEmpty) {
      try {
        return (await _remote.me()).toEntity();
      } catch (error) {
        await _storage.clear();
        final failure = mapApiError(error);
        if (failure.statusCode == 401) return null;
        rethrow;
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _storage.clear();
    _sessions.reset();
  }
}
