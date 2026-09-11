import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class RemoveTechnicianSkill {
  const RemoveTechnicianSkill(this._repository);
  final TechniciansRepository _repository;
  Future<void> call(String id, String categoryId) =>
      _repository.removeSkill(id, categoryId);
}
