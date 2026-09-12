import 'package:equatable/equatable.dart';

class PartQuery extends Equatable {
  const PartQuery({
    this.search = '',
    this.isActive,
    this.lowStock,
    this.page = 1,
    this.pageSize = 20,
  });
  final String search;
  final bool? isActive;
  final bool? lowStock;
  final int page;
  final int pageSize;

  PartQuery copyWith({
    String? search,
    bool? isActive,
    bool clearIsActive = false,
    bool? lowStock,
    bool clearLowStock = false,
    int? page,
    int? pageSize,
  }) => PartQuery(
    search: search ?? this.search,
    isActive: clearIsActive ? null : isActive ?? this.isActive,
    lowStock: clearLowStock ? null : lowStock ?? this.lowStock,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, isActive, lowStock, page, pageSize];
}
