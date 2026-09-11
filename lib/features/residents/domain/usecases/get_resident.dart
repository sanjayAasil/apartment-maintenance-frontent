import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/repositories/residents_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetResident {
  const GetResident(this._repository);
  final ResidentsRepository _repository;
  Future<Resident> call(String id) => _repository.getResident(id);
}
