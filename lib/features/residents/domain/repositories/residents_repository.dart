import 'package:apartment_maintenance_frontent/features/residents/domain/entities/paged_residents.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';

abstract interface class ResidentsRepository {
  Future<PagedResidents> getResidents(ResidentQuery query);
  Future<Resident> getResident(String id);
  Future<Resident> getCurrentResident();
  Future<Resident> createResident({
    required String userId,
    required String apartmentId,
    required String phone,
    required String moveInDate,
  });
  Future<Resident> updateResident({
    required String id,
    required String phone,
    required String moveInDate,
  });
  Future<Resident> changeApartment(String id, String apartmentId);
  Future<Resident> updateStatus(String id, bool isActive);
}
