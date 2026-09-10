import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:equatable/equatable.dart';

class PagedApartments extends Equatable {
  const PagedApartments({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<Apartment> items;
  final int total;
  final int page;
  final int pageSize;
  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();

  @override
  List<Object> get props => [items, total, page, pageSize];
}
