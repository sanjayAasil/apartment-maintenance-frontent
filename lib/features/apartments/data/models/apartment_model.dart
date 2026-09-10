import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';

class ApartmentModel {
  const ApartmentModel({
    required this.id,
    required this.block,
    required this.floor,
    required this.unitNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory ApartmentModel.fromJson(Map<String, dynamic> json) => ApartmentModel(
    id: json['id'] as String,
    block: json['block'] as String,
    floor: json['floor'] as int,
    unitNumber: json['unitNumber'] as String,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
  );

  final String id;
  final String block;
  final int floor;
  final String unitNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Apartment toEntity() => Apartment(
    id: id,
    block: block,
    floor: floor,
    unitNumber: unitNumber,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class PagedApartmentModels {
  const PagedApartmentModels({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<ApartmentModel> items;
  final int total;
  final int page;
  final int limit;
}
