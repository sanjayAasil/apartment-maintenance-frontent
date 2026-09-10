import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

class PagedUsers extends Equatable {
  const PagedUsers({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
  final List<AppUser> items;
  final int total;
  final int page;
  final int pageSize;
  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();

  @override
  List<Object> get props => [items, total, page, pageSize];
}
