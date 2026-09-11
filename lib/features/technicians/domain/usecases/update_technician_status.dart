import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateTechnicianStatus {
  const UpdateTechnicianStatus(this._repository);
  final TechniciansRepository _repository;
  Future<Technician> call(String id, bool isActive) =>
      _repository.updateStatus(id, isActive);
}
