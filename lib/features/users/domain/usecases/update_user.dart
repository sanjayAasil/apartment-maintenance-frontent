import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateUser {
  const UpdateUser(this._repository);
  final UsersRepository _repository;
  Future<AppUser> call(String id, String name, String email, UserRole role) =>
      _repository.updateUser(id: id, name: name, email: email, role: role);
}
