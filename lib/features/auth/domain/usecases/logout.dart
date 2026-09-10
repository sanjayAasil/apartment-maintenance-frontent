import 'package:apartment_maintenance_frontent/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class Logout {
  const Logout(this._repository);
  final AuthRepository _repository;
  Future<void> call() => _repository.logout();
}
