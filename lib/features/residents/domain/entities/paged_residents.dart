import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:equatable/equatable.dart';

class PagedResidents extends Equatable {
  const PagedResidents({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<Resident> items;
  final int total;
  final int page;
  final int pageSize;
  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();

  @override
  List<Object> get props => [items, total, page, pageSize];
}
