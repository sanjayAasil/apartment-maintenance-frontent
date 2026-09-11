import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/paged_technicians.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTechnicians {
  const GetTechnicians(this._repository);
  final TechniciansRepository _repository;
  Future<PagedTechnicians> call(TechnicianQuery query) =>
      _repository.getTechnicians(query);
}
