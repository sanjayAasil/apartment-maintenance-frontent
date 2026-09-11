import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_skill.dart';
import 'package:equatable/equatable.dart';

class Technician extends Equatable {
  const Technician({
    required this.id,
    required this.userId,
    required this.phone,
    required this.experienceYears,
    required this.isAvailable,
    required this.isActive,
    required this.user,
    required this.skills,
    this.createdAt,
    this.updatedAt,
  });
  final String id;
  final String userId;
  final String phone;
  final int experienceYears;
  final bool isAvailable;
  final bool isActive;
  final AppUser user;
  final List<TechnicianSkill> skills;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  @override
  List<Object?> get props => [
    id,
    userId,
    phone,
    experienceYears,
    isAvailable,
    isActive,
    user,
    skills,
    createdAt,
    updatedAt,
  ];
}
