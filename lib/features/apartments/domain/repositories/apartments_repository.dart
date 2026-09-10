import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment_query.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/paged_apartments.dart';

abstract interface class ApartmentsRepository {
  Future<PagedApartments> getApartments(ApartmentQuery query);
  Future<Apartment> getApartment(String id);
  Future<Apartment> createApartment({
    required String block,
    required int floor,
    required String unitNumber,
  });
  Future<Apartment> updateApartment({
    required String id,
    required String block,
    required int floor,
    required String unitNumber,
  });
}
