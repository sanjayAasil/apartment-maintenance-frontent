import 'package:equatable/equatable.dart';

class TechnicianQuery extends Equatable {
  const TechnicianQuery({
    this.search = '',
    this.isActive,
    this.isAvailable,
    this.categoryId,
    this.page = 1,
    this.pageSize = 20,
  });
  final String search;
  final bool? isActive;
  final bool? isAvailable;
  final String? categoryId;
  final int page;
  final int pageSize;

  TechnicianQuery copyWith({
    String? search,
    bool? isActive,
    bool clearIsActive = false,
    bool? isAvailable,
    bool clearIsAvailable = false,
    String? categoryId,
    bool clearCategoryId = false,
    int? page,
    int? pageSize,
  }) => TechnicianQuery(
    search: search ?? this.search,
    isActive: clearIsActive ? null : isActive ?? this.isActive,
    isAvailable: clearIsAvailable ? null : isAvailable ?? this.isAvailable,
    categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [
    search,
    isActive,
    isAvailable,
    categoryId,
    page,
    pageSize,
  ];
}
