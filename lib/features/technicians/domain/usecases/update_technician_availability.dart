import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateTechnicianAvailability {
  const UpdateTechnicianAvailability(this._repository);
  final TechniciansRepository _repository;
  Future<Technician> call(String id, bool isAvailable) =>
      _repository.updateAvailability(id, isAvailable);
}
