import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/paged_technicians.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_query.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_technicians.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class TechniciansListEvent extends Equatable {
  const TechniciansListEvent();
  @override
  List<Object?> get props => [];
}

final class TechniciansRequested extends TechniciansListEvent {
  const TechniciansRequested();
}

final class TechniciansSearchChanged extends TechniciansListEvent {
  const TechniciansSearchChanged(this.value);
  final String value;
  @override
  List<Object> get props => [value];
}

final class TechniciansActiveFilterChanged extends TechniciansListEvent {
  const TechniciansActiveFilterChanged(this.value);
  final bool? value;
  @override
  List<Object?> get props => [value];
}

final class TechniciansAvailabilityFilterChanged extends TechniciansListEvent {
  const TechniciansAvailabilityFilterChanged(this.value);
  final bool? value;
  @override
  List<Object?> get props => [value];
}

final class TechniciansCategoryFilterChanged extends TechniciansListEvent {
  const TechniciansCategoryFilterChanged(this.value);
  final String? value;
  @override
  List<Object?> get props => [value];
}

final class TechniciansPageChanged extends TechniciansListEvent {
  const TechniciansPageChanged(this.page);
  final int page;
  @override
  List<Object> get props => [page];
}

final class TechniciansPageSizeChanged extends TechniciansListEvent {
  const TechniciansPageSizeChanged(this.pageSize);
  final int pageSize;
  @override
  List<Object> get props => [pageSize];
}

enum TechniciansListStatus { initial, loading, success, empty, failure }

class TechniciansListState extends Equatable {
  const TechniciansListState({
    this.status = TechniciansListStatus.initial,
    this.query = const TechnicianQuery(),
    this.result,
    this.failure,
  });
  final TechniciansListStatus status;
  final TechnicianQuery query;
  final PagedTechnicians? result;
  final Failure? failure;
  @override
  List<Object?> get props => [status, query, result, failure];
}

@injectable
class TechniciansListBloc
    extends Bloc<TechniciansListEvent, TechniciansListState> {
  TechniciansListBloc(this._getTechnicians)
    : super(const TechniciansListState()) {
    on<TechniciansRequested>((_, emit) => _load(state.query, emit));
    on<TechniciansSearchChanged>(
      (event, emit) =>
          _load(state.query.copyWith(search: event.value, page: 1), emit),
    );
    on<TechniciansActiveFilterChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          isActive: event.value,
          clearIsActive: event.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<TechniciansAvailabilityFilterChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          isAvailable: event.value,
          clearIsAvailable: event.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<TechniciansCategoryFilterChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          categoryId: event.value,
          clearCategoryId: event.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<TechniciansPageChanged>(
      (event, emit) => _load(state.query.copyWith(page: event.page), emit),
    );
    on<TechniciansPageSizeChanged>(
      (event, emit) =>
          _load(state.query.copyWith(page: 1, pageSize: event.pageSize), emit),
    );
  }
  final GetTechnicians _getTechnicians;
  Future<void> _load(
    TechnicianQuery query,
    Emitter<TechniciansListState> emit,
  ) async {
    emit(
      TechniciansListState(
        status: TechniciansListStatus.loading,
        query: query,
        result: state.result,
      ),
    );
    try {
      final result = await _getTechnicians(query);
      emit(
        TechniciansListState(
          status: result.items.isEmpty
              ? TechniciansListStatus.empty
              : TechniciansListStatus.success,
          query: query,
          result: result,
        ),
      );
    } catch (error) {
      emit(
        TechniciansListState(
          status: TechniciansListStatus.failure,
          query: query,
          result: state.result,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
