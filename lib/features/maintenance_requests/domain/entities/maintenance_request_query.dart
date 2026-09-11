import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:equatable/equatable.dart';

class MaintenanceRequestQuery extends Equatable {
  const MaintenanceRequestQuery({
    this.search = '',
    this.status,
    this.priority,
    this.categoryId,
    this.apartmentId,
    this.residentId,
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });
  final String search;
  final MaintenanceRequestStatus? status;
  final MaintenancePriority? priority;
  final String? categoryId;
  final String? apartmentId;
  final String? residentId;
  final int page;
  final int pageSize;
  final String sortBy;
  final String sortOrder;

  MaintenanceRequestQuery copyWith({
    String? search,
    MaintenanceRequestStatus? status,
    bool clearStatus = false,
    MaintenancePriority? priority,
    bool clearPriority = false,
    String? categoryId,
    bool clearCategory = false,
    String? apartmentId,
    bool clearApartment = false,
    String? residentId,
    bool clearResident = false,
    int? page,
    int? pageSize,
  }) => MaintenanceRequestQuery(
    search: search ?? this.search,
    status: clearStatus ? null : status ?? this.status,
    priority: clearPriority ? null : priority ?? this.priority,
    categoryId: clearCategory ? null : categoryId ?? this.categoryId,
    apartmentId: clearApartment ? null : apartmentId ?? this.apartmentId,
    residentId: clearResident ? null : residentId ?? this.residentId,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    sortBy: sortBy,
    sortOrder: sortOrder,
  );
  @override
  List<Object?> get props => [
    search,
    status,
    priority,
    categoryId,
    apartmentId,
    residentId,
    page,
    pageSize,
    sortBy,
    sortOrder,
  ];
}
