import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/repositories/residents_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateResidentStatus {
  const UpdateResidentStatus(this._repository);
  final ResidentsRepository _repository;
  Future<Resident> call(String id, bool isActive) =>
      _repository.updateStatus(id, isActive);
}
