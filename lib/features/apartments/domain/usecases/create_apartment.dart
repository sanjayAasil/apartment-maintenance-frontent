import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/repositories/apartments_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateApartment {
  const CreateApartment(this._repository);
  final ApartmentsRepository _repository;
  Future<Apartment> call(String block, int floor, String unitNumber) =>
      _repository.createApartment(
        block: block,
        floor: floor,
        unitNumber: unitNumber,
      );
}
