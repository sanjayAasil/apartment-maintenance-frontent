import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/paged_users.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class UsersListEvent extends Equatable {
  const UsersListEvent();
  @override
  List<Object?> get props => [];
}

final class UsersRequested extends UsersListEvent {
  const UsersRequested();
}

final class UsersSearchChanged extends UsersListEvent {
  const UsersSearchChanged(this.value);
  final String value;
  @override
  List<Object> get props => [value];
}

final class UsersRoleChanged extends UsersListEvent {
  const UsersRoleChanged(this.role);
  final UserRole? role;
  @override
  List<Object?> get props => [role];
}

final class UsersActiveChanged extends UsersListEvent {
  const UsersActiveChanged(this.isActive);
  final bool? isActive;
  @override
  List<Object?> get props => [isActive];
}

final class UsersPageChanged extends UsersListEvent {
  const UsersPageChanged(this.page);
  final int page;
  @override
  List<Object> get props => [page];
}

final class UsersPageSizeChanged extends UsersListEvent {
  const UsersPageSizeChanged(this.pageSize);
  final int pageSize;
  @override
  List<Object> get props => [pageSize];
}

enum UsersListStatus { initial, loading, success, empty, failure }

class UsersListState extends Equatable {
  const UsersListState({
    this.status = UsersListStatus.initial,
    this.query = const UserQuery(),
    this.result,
    this.failure,
  });
  final UsersListStatus status;
  final UserQuery query;
  final PagedUsers? result;
  final Failure? failure;

  @override
  List<Object?> get props => [status, query, result, failure];
}

@injectable
class UsersListBloc extends Bloc<UsersListEvent, UsersListState> {
  UsersListBloc(this._getUsers) : super(const UsersListState()) {
    on<UsersRequested>((_, emit) => _load(state.query, emit));
    on<UsersSearchChanged>(_onSearch);
    on<UsersRoleChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          role: event.role,
          clearRole: event.role == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<UsersActiveChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          isActive: event.isActive,
          clearActive: event.isActive == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<UsersPageChanged>(
      (event, emit) => _load(state.query.copyWith(page: event.page), emit),
    );
    on<UsersPageSizeChanged>(
      (event, emit) =>
          _load(state.query.copyWith(page: 1, pageSize: event.pageSize), emit),
    );
  }

  final GetUsers _getUsers;
  Future<void> _onSearch(
    UsersSearchChanged event,
    Emitter<UsersListState> emit,
  ) async {
    await _load(state.query.copyWith(search: event.value, page: 1), emit);
  }

  Future<void> _load(UserQuery query, Emitter<UsersListState> emit) async {
    emit(
      UsersListState(
        status: UsersListStatus.loading,
        query: query,
        result: state.result,
      ),
    );
    try {
      final result = await _getUsers(query);
      emit(
        UsersListState(
          status: result.items.isEmpty
              ? UsersListStatus.empty
              : UsersListStatus.success,
          query: query,
          result: result,
        ),
      );
    } catch (error) {
      emit(
        UsersListState(
          status: UsersListStatus.failure,
          query: query,
          result: state.result,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
