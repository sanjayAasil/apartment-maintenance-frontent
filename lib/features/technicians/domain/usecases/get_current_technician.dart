import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCurrentTechnician {
  const GetCurrentTechnician(this._repository);
  final TechniciansRepository _repository;
  Future<Technician> call() => _repository.getCurrentTechnician();
}
