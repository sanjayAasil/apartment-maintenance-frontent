import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:equatable/equatable.dart';

class PagedMaintenanceCategories extends Equatable {
  const PagedMaintenanceCategories({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<MaintenanceCategory> items;
  final int total;
  final int page;
  final int pageSize;
  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();

  @override
  List<Object> get props => [items, total, page, pageSize];
}
