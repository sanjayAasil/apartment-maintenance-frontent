import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/features/residents/data/datasources/residents_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/paged_residents.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/repositories/residents_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ResidentsRepository)
class ResidentsRepositoryImpl implements ResidentsRepository {
  const ResidentsRepositoryImpl(this._remote);
  final ResidentsRemoteDataSource _remote;

  @override
  Future<PagedResidents> getResidents(ResidentQuery query) async {
    try {
      final result = await _remote.getResidents(query);
      return PagedResidents(
        items: result.items.map((model) => model.toEntity()).toList(),
        total: result.total,
        page: result.page,
        pageSize: result.limit,
      );
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Resident> getResident(String id) async {
    try {
      return (await _remote.getResident(id)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Resident> getCurrentResident() async {
    try {
      return (await _remote.getCurrentResident()).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Resident> createResident({
    required String userId,
    required String apartmentId,
    required String phone,
    required String moveInDate,
  }) async {
    try {
      return (await _remote.createResident(
        userId,
        apartmentId,
        phone.trim(),
        moveInDate.trim(),
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Resident> updateResident({
    required String id,
    required String phone,
    required String moveInDate,
  }) async {
    try {
      return (await _remote.updateResident(
        id,
        phone.trim(),
        moveInDate.trim(),
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Resident> changeApartment(String id, String apartmentId) async {
    try {
      return (await _remote.changeApartment(id, apartmentId)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Resident> updateStatus(String id, bool isActive) async {
    try {
      return (await _remote.updateStatus(id, isActive)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }
}
