import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/features/apartments/data/datasources/apartments_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment_query.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/paged_apartments.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/repositories/apartments_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ApartmentsRepository)
class ApartmentsRepositoryImpl implements ApartmentsRepository {
  const ApartmentsRepositoryImpl(this._remote);
  final ApartmentsRemoteDataSource _remote;

  @override
  Future<PagedApartments> getApartments(ApartmentQuery query) async {
    try {
      final result = await _remote.getApartments(query);
      return PagedApartments(
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
  Future<Apartment> getApartment(String id) async {
    try {
      return (await _remote.getApartment(id)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Apartment> createApartment({
    required String block,
    required int floor,
    required String unitNumber,
  }) async {
    try {
      return (await _remote.createApartment(
        block.trim(),
        floor,
        unitNumber.trim(),
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Apartment> updateApartment({
    required String id,
    required String block,
    required int floor,
    required String unitNumber,
  }) async {
    try {
      return (await _remote.updateApartment(
        id,
        block.trim(),
        floor,
        unitNumber.trim(),
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }
}
