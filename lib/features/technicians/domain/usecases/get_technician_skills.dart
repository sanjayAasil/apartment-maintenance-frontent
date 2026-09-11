import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTechnicianSkills {
  const GetTechnicianSkills(this._repository);
  final TechniciansRepository _repository;
  Future<List<TechnicianSkill>> call(String id) => _repository.getSkills(id);
}
