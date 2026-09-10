import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/repositories/apartments_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetApartment {
  const GetApartment(this._repository);
  final ApartmentsRepository _repository;
  Future<Apartment> call(String id) => _repository.getApartment(id);
}
