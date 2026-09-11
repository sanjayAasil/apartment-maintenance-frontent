import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:equatable/equatable.dart';

class PagedMaintenanceRequests extends Equatable {
  const PagedMaintenanceRequests({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
  final List<MaintenanceRequest> items;
  final int total;
  final int page;
  final int pageSize;
  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();
  @override
  List<Object?> get props => [items, total, page, pageSize];
}
