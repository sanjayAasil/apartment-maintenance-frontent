import 'package:equatable/equatable.dart';

class Part extends Equatable {
  const Part({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.minimumStock,
    required this.isActive,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final int quantity;
  final double unitPrice;
  final int minimumStock;
  final bool isActive;
  bool get isLowStock => quantity <= minimumStock;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    quantity,
    unitPrice,
    minimumStock,
    isActive,
  ];
}
