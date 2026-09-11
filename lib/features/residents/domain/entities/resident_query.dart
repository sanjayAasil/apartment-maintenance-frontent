import 'package:equatable/equatable.dart';

class ResidentQuery extends Equatable {
  const ResidentQuery({
    this.search = '',
    this.apartmentId,
    this.isActive,
    this.page = 1,
    this.pageSize = 20,
  });

  final String search;
  final String? apartmentId;
  final bool? isActive;
  final int page;
  final int pageSize;

  ResidentQuery copyWith({
    String? search,
    String? apartmentId,
    bool clearApartment = false,
    bool? isActive,
    bool clearActive = false,
    int? page,
    int? pageSize,
  }) => ResidentQuery(
    search: search ?? this.search,
    apartmentId: clearApartment ? null : apartmentId ?? this.apartmentId,
    isActive: clearActive ? null : isActive ?? this.isActive,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, apartmentId, isActive, page, pageSize];
}
