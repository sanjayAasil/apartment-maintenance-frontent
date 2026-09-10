import 'package:apartment_maintenance_frontent/features/users/domain/entities/paged_users.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/repositories/users_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUsers {
  const GetUsers(this._repository);
  final UsersRepository _repository;
  Future<PagedUsers> call(UserQuery query) => _repository.getUsers(query);
}
