import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUser {
  const GetUser(this._repository);
  final UsersRepository _repository;
  Future<AppUser> call(String id) => _repository.getUser(id);
}
