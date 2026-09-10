import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });
  Future<AppUser?> restoreSession();
  Future<void> logout();
}
