import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:equatable/equatable.dart';

class PagedParts extends Equatable {
  const PagedParts({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
  final List<Part> items;
  final int total;
  final int page;
  final int pageSize;
  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();
  @override
  List<Object> get props => [items, total, page, pageSize];
}
