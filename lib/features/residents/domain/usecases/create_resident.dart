import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/repositories/residents_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateResident {
  const CreateResident(this._repository);
  final ResidentsRepository _repository;
  Future<Resident> call(
    String userId,
    String apartmentId,
    String phone,
    String moveInDate,
  ) => _repository.createResident(
    userId: userId,
    apartmentId: apartmentId,
    phone: phone,
    moveInDate: moveInDate,
  );
}
