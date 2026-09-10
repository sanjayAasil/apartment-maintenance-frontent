import 'package:apartment_maintenance_frontent/features/auth/domain/entities/auth_session.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class Login {
  const Login(this._repository);
  final AuthRepository _repository;
  Future<AuthSession> call(String email, String password) =>
      _repository.login(email: email, password: password);
}
