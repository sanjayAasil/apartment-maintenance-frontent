import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateTechnician {
  const UpdateTechnician(this._repository);
  final TechniciansRepository _repository;
  Future<Technician> call(String id, String phone, int experienceYears) =>
      _repository.updateTechnician(
        id: id,
        phone: phone,
        experienceYears: experienceYears,
      );
}
