import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddTechnicianSkill {
  const AddTechnicianSkill(this._repository);
  final TechniciansRepository _repository;
  Future<TechnicianSkill> call(String id, String categoryId) =>
      _repository.addSkill(id, categoryId);
}
