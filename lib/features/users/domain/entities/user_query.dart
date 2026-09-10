import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

class UserQuery extends Equatable {
  const UserQuery({
    this.search = '',
    this.role,
    this.isActive,
    this.page = 1,
    this.pageSize = 10,
  });
  final String search;
  final UserRole? role;
  final bool? isActive;
  final int page;
  final int pageSize;

  UserQuery copyWith({
    String? search,
    UserRole? role,
    bool clearRole = false,
    bool? isActive,
    bool clearActive = false,
    int? page,
    int? pageSize,
  }) => UserQuery(
    search: search ?? this.search,
    role: clearRole ? null : role ?? this.role,
    isActive: clearActive ? null : isActive ?? this.isActive,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => [search, role, isActive, page, pageSize];
}
