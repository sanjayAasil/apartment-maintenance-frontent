import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateTechnician {
  const CreateTechnician(this._repository);
  final TechniciansRepository _repository;
  Future<Technician> call(String userId, String phone, int experienceYears) =>
      _repository.createTechnician(
        userId: userId,
        phone: phone,
        experienceYears: experienceYears,
      );
}
