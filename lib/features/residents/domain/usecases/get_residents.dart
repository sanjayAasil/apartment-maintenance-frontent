import 'package:apartment_maintenance_frontent/features/residents/domain/entities/paged_residents.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/repositories/residents_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetResidents {
  const GetResidents(this._repository);
  final ResidentsRepository _repository;
  Future<PagedResidents> call(ResidentQuery query) =>
      _repository.getResidents(query);
}
