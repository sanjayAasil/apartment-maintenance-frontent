import 'package:apartment_maintenance_frontent/features/apartments/data/models/apartment_model.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/users/data/models/user_model.dart';

class ResidentModel {
  const ResidentModel({
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

  factory ResidentModel.fromJson(Map<String, dynamic> json) => ResidentModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    apartmentId: json['apartmentId'] as String,
    phone: json['phone'] as String,
    moveInDate: DateTime.parse(json['moveInDate'] as String),
    isActive: json['isActive'] as bool,
    user: UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    apartment: ApartmentModel.fromJson(
      Map<String, dynamic>.from(json['apartment'] as Map),
    ),
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
  );

  final String id;
  final String userId;
  final String apartmentId;
  final String phone;
  final DateTime moveInDate;
  final bool isActive;
  final UserModel user;
  final ApartmentModel apartment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Resident toEntity() => Resident(
    id: id,
    userId: userId,
    apartmentId: apartmentId,
    phone: phone,
    moveInDate: moveInDate,
    isActive: isActive,
    user: user.toEntity(),
    apartment: apartment.toEntity(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class PagedResidentModels {
  const PagedResidentModels({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<ResidentModel> items;
  final int total;
  final int page;
  final int limit;
}
