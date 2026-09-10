import 'package:equatable/equatable.dart';

class ApartmentQuery extends Equatable {
  const ApartmentQuery({
    this.block = '',
    this.floor,
    this.search = '',
    this.page = 1,
    this.pageSize = 20,
  });

  final String block;
  final int? floor;
  final String search;
  final int page;
  final int pageSize;

  ApartmentQuery copyWith({
    String? block,
    int? floor,
    bool clearFloor = false,
    String? search,
    int? page,
    int? pageSize,
  }) => ApartmentQuery(
    block: block ?? this.block,
    floor: clearFloor ? null : floor ?? this.floor,
    search: search ?? this.search,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [block, floor, search, page, pageSize];
}
