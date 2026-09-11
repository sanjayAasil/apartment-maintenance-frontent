import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:equatable/equatable.dart';

class PagedTechnicians extends Equatable {
  const PagedTechnicians({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
  final List<Technician> items;
  final int total;
  final int page;
  final int pageSize;
  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();
  @override
  List<Object> get props => [items, total, page, pageSize];
}
