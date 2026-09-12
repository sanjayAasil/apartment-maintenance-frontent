import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';

double _money(dynamic value) =>
    value is num ? value.toDouble() : double.parse(value.toString());

class PartModel {
  const PartModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.minimumStock,
    required this.isActive,
    this.description,
  });
  factory PartModel.fromJson(Map<String, dynamic> json) => PartModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    quantity: json['quantity'] as int,
    unitPrice: _money(json['unitPrice']),
    minimumStock: json['minimumStock'] as int,
    isActive: json['isActive'] as bool,
  );
  final String id;
  final String name;
  final String? description;
  final int quantity;
  final double unitPrice;
  final int minimumStock;
  final bool isActive;
  Part toEntity() => Part(
    id: id,
    name: name,
    description: description,
    quantity: quantity,
    unitPrice: unitPrice,
    minimumStock: minimumStock,
    isActive: isActive,
  );
}

class PagedPartModels {
  const PagedPartModels({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
  final List<PartModel> items;
  final int total;
  final int page;
  final int limit;
}
