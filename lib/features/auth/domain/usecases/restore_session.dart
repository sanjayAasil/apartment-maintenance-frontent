import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RestoreSession {
  const RestoreSession(this._repository);
  final AuthRepository _repository;
  Future<AppUser?> call() => _repository.restoreSession();
}
