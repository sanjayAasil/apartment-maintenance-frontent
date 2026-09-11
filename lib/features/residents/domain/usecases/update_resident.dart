import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/repositories/residents_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateResident {
  const UpdateResident(this._repository);
  final ResidentsRepository _repository;
  Future<Resident> call(String id, String phone, String moveInDate) =>
      _repository.updateResident(id: id, phone: phone, moveInDate: moveInDate);
}
