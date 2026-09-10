import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment_query.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/paged_apartments.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/repositories/apartments_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetApartments {
  const GetApartments(this._repository);
  final ApartmentsRepository _repository;
  Future<PagedApartments> call(ApartmentQuery query) =>
      _repository.getApartments(query);
}
