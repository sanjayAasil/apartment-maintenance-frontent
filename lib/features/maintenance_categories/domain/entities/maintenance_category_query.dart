import 'package:equatable/equatable.dart';

class MaintenanceCategoryQuery extends Equatable {
  const MaintenanceCategoryQuery({
    this.search = '',
    this.isActive,
    this.page = 1,
    this.pageSize = 20,
  });

  final String search;
  final bool? isActive;
  final int page;
  final int pageSize;

  MaintenanceCategoryQuery copyWith({
    String? search,
    bool? isActive,
    bool clearIsActive = false,
    int? page,
    int? pageSize,
  }) => MaintenanceCategoryQuery(
    search: search ?? this.search,
    isActive: clearIsActive ? null : isActive ?? this.isActive,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, isActive, page, pageSize];
}
