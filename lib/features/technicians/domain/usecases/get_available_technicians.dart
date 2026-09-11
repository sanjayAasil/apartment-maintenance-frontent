import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAvailableTechnicians {
  const GetAvailableTechnicians(this._repository);
  final TechniciansRepository _repository;
  Future<List<Technician>> call([String? categoryId]) =>
      _repository.getAvailableTechnicians(categoryId);
}
