import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/paged_maintenance_requests.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_requests.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class MaintenanceRequestsListEvent extends Equatable {
  const MaintenanceRequestsListEvent();
  @override
  List<Object?> get props => [];
}

final class MaintenanceRequestsRequested extends MaintenanceRequestsListEvent {
  const MaintenanceRequestsRequested();
}

final class MaintenanceRequestsSearchChanged
    extends MaintenanceRequestsListEvent {
  const MaintenanceRequestsSearchChanged(this.value);
  final String value;
  @override
  List<Object> get props => [value];
}

final class MaintenanceRequestsStatusChanged
    extends MaintenanceRequestsListEvent {
  const MaintenanceRequestsStatusChanged(this.value);
  final MaintenanceRequestStatus? value;
  @override
  List<Object?> get props => [value];
}

final class MaintenanceRequestsPriorityChanged
    extends MaintenanceRequestsListEvent {
  const MaintenanceRequestsPriorityChanged(this.value);
  final MaintenancePriority? value;
  @override
  List<Object?> get props => [value];
}

final class MaintenanceRequestsCategoryChanged
    extends MaintenanceRequestsListEvent {
  const MaintenanceRequestsCategoryChanged(this.value);
  final String? value;
  @override
  List<Object?> get props => [value];
}

final class MaintenanceRequestsPageChanged
    extends MaintenanceRequestsListEvent {
  const MaintenanceRequestsPageChanged(this.page);
  final int page;
  @override
  List<Object> get props => [page];
}

final class MaintenanceRequestsPageSizeChanged
    extends MaintenanceRequestsListEvent {
  const MaintenanceRequestsPageSizeChanged(this.size);
  final int size;
  @override
  List<Object> get props => [size];
}

enum MaintenanceRequestsListStatus { initial, loading, success, empty, failure }

class MaintenanceRequestsListState extends Equatable {
  const MaintenanceRequestsListState({
    this.status = MaintenanceRequestsListStatus.initial,
    this.query = const MaintenanceRequestQuery(),
    this.result,
    this.failure,
  });
  final MaintenanceRequestsListStatus status;
  final MaintenanceRequestQuery query;
  final PagedMaintenanceRequests? result;
  final Failure? failure;
  @override
  List<Object?> get props => [status, query, result, failure];
}

@injectable
class MaintenanceRequestsListBloc
    extends Bloc<MaintenanceRequestsListEvent, MaintenanceRequestsListState> {
  MaintenanceRequestsListBloc(this._get)
    : super(const MaintenanceRequestsListState()) {
    on<MaintenanceRequestsRequested>((_, emit) => _load(state.query, emit));
    on<MaintenanceRequestsSearchChanged>(
      (event, emit) =>
          _load(state.query.copyWith(search: event.value, page: 1), emit),
    );
    on<MaintenanceRequestsStatusChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          status: event.value,
          clearStatus: event.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<MaintenanceRequestsPriorityChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          priority: event.value,
          clearPriority: event.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<MaintenanceRequestsCategoryChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          categoryId: event.value,
          clearCategory: event.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<MaintenanceRequestsPageChanged>(
      (event, emit) => _load(state.query.copyWith(page: event.page), emit),
    );
    on<MaintenanceRequestsPageSizeChanged>(
      (event, emit) =>
          _load(state.query.copyWith(page: 1, pageSize: event.size), emit),
    );
  }
  final GetMaintenanceRequests _get;
  Future<void> _load(
    MaintenanceRequestQuery query,
    Emitter<MaintenanceRequestsListState> emit,
  ) async {
    emit(
      MaintenanceRequestsListState(
        status: MaintenanceRequestsListStatus.loading,
        query: query,
        result: state.result,
      ),
    );
    try {
      final result = await _get(query);
      emit(
        MaintenanceRequestsListState(
          status: result.items.isEmpty
              ? MaintenanceRequestsListStatus.empty
              : MaintenanceRequestsListStatus.success,
          query: query,
          result: result,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceRequestsListState(
          status: MaintenanceRequestsListStatus.failure,
          query: query,
          result: state.result,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
