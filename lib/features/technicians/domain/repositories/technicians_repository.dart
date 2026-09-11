import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/paged_technicians.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_skill.dart';

abstract interface class TechniciansRepository {
  Future<PagedTechnicians> getTechnicians(TechnicianQuery query);
  Future<List<Technician>> getAvailableTechnicians(String? categoryId);
  Future<Technician> getTechnician(String id);
  Future<Technician> getCurrentTechnician();
  Future<Technician> createTechnician({
    required String userId,
    required String phone,
    required int experienceYears,
  });
  Future<Technician> updateTechnician({
    required String id,
    required String phone,
    required int experienceYears,
  });
  Future<Technician> updateStatus(String id, bool isActive);
  Future<Technician> updateAvailability(String id, bool isAvailable);
  Future<List<TechnicianSkill>> getSkills(String id);
  Future<TechnicianSkill> addSkill(String id, String categoryId);
  Future<void> removeSkill(String id, String categoryId);
}
