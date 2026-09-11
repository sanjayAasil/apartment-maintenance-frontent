import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTechnician {
  const GetTechnician(this._repository);
  final TechniciansRepository _repository;
  Future<Technician> call(String id) => _repository.getTechnician(id);
}
