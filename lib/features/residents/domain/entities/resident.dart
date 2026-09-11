import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

class Resident extends Equatable {
  const Resident({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.phone,
    required this.moveInDate,
    required this.isActive,
    required this.user,
    required this.apartment,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String apartmentId;
  final String phone;
  final DateTime moveInDate;
  final bool isActive;
  final AppUser user;
  final Apartment apartment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    apartmentId,
    phone,
    moveInDate,
    isActive,
    user,
    apartment,
    createdAt,
    updatedAt,
  ];
}
