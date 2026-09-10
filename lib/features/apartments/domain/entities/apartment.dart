import 'package:equatable/equatable.dart';

class Apartment extends Equatable {
  const Apartment({
    required this.id,
    required this.block,
    required this.floor,
    required this.unitNumber,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String block;
  final int floor;
  final String unitNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    block,
    floor,
    unitNumber,
    createdAt,
    updatedAt,
  ];
}
