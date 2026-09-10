import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/repositories/apartments_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateApartment {
  const UpdateApartment(this._repository);
  final ApartmentsRepository _repository;
  Future<Apartment> call(
    String id,
    String block,
    int floor,
    String unitNumber,
  ) => _repository.updateApartment(
    id: id,
    block: block,
    floor: floor,
    unitNumber: unitNumber,
  );
}
