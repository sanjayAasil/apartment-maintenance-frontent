import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/features/technicians/data/datasources/technicians_remote_data_source.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/paged_technicians.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TechniciansRepository)
class TechniciansRepositoryImpl implements TechniciansRepository {
  const TechniciansRepositoryImpl(this._remote);
  final TechniciansRemoteDataSource _remote;

  @override
  Future<PagedTechnicians> getTechnicians(TechnicianQuery query) async {
    try {
      final result = await _remote.getTechnicians(query);
      return PagedTechnicians(
        items: result.items
            .map((model) => model.toEntity())
            .toList(growable: false),
        total: result.total,
        page: result.page,
        pageSize: result.limit,
      );
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<List<Technician>> getAvailableTechnicians(String? categoryId) async {
    try {
      return (await _remote.getAvailableTechnicians(
        categoryId,
      )).map((model) => model.toEntity()).toList(growable: false);
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Technician> getTechnician(String id) async {
    try {
      return (await _remote.getTechnician(id)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Technician> getCurrentTechnician() async {
    try {
      return (await _remote.getCurrentTechnician()).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Technician> createTechnician({
    required String userId,
    required String phone,
    required int experienceYears,
  }) async {
    try {
      return (await _remote.createTechnician(
        userId,
        phone.trim(),
        experienceYears,
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Technician> updateTechnician({
    required String id,
    required String phone,
    required int experienceYears,
  }) async {
    try {
      return (await _remote.updateTechnician(
        id,
        phone.trim(),
        experienceYears,
      )).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Technician> updateStatus(String id, bool isActive) async {
    try {
      return (await _remote.updateStatus(id, isActive)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<Technician> updateAvailability(String id, bool isAvailable) async {
    try {
      return (await _remote.updateAvailability(id, isAvailable)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<List<TechnicianSkill>> getSkills(String id) async {
    try {
      return (await _remote.getSkills(
        id,
      )).map((model) => model.toEntity()).toList(growable: false);
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<TechnicianSkill> addSkill(String id, String categoryId) async {
    try {
      return (await _remote.addSkill(id, categoryId)).toEntity();
    } catch (error) {
      throw mapApiError(error);
    }
  }

  @override
  Future<void> removeSkill(String id, String categoryId) async {
    try {
      await _remote.removeSkill(id, categoryId);
    } catch (error) {
      throw mapApiError(error);
    }
  }
}
