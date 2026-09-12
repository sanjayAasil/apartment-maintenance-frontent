import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/paged_parts.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part_query.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/usecases/parts_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class PartsListEvent extends Equatable {
  const PartsListEvent();
  @override
  List<Object?> get props => [];
}

final class PartsRequested extends PartsListEvent {
  const PartsRequested();
}

final class PartsSearchChanged extends PartsListEvent {
  const PartsSearchChanged(this.value);
  final String value;
  @override
  List<Object> get props => [value];
}

final class PartsStatusChanged extends PartsListEvent {
  const PartsStatusChanged(this.value);
  final bool? value;
  @override
  List<Object?> get props => [value];
}

final class PartsLowStockChanged extends PartsListEvent {
  const PartsLowStockChanged(this.value);
  final bool? value;
  @override
  List<Object?> get props => [value];
}

final class PartsPageChanged extends PartsListEvent {
  const PartsPageChanged(this.value);
  final int value;
  @override
  List<Object> get props => [value];
}

final class PartsPageSizeChanged extends PartsListEvent {
  const PartsPageSizeChanged(this.value);
  final int value;
  @override
  List<Object> get props => [value];
}

enum PartsListStatus { initial, loading, success, empty, failure }

class PartsListState extends Equatable {
  const PartsListState({
    this.status = PartsListStatus.initial,
    this.query = const PartQuery(),
    this.result,
    this.failure,
  });
  final PartsListStatus status;
  final PartQuery query;
  final PagedParts? result;
  final Failure? failure;
  @override
  List<Object?> get props => [status, query, result, failure];
}

@injectable
class PartsListBloc extends Bloc<PartsListEvent, PartsListState> {
  PartsListBloc(this._get) : super(const PartsListState()) {
    on<PartsRequested>((_, emit) => _load(state.query, emit));
    on<PartsSearchChanged>(
      (e, emit) => _load(state.query.copyWith(search: e.value, page: 1), emit),
    );
    on<PartsStatusChanged>(
      (e, emit) => _load(
        state.query.copyWith(
          isActive: e.value,
          clearIsActive: e.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<PartsLowStockChanged>(
      (e, emit) => _load(
        state.query.copyWith(
          lowStock: e.value,
          clearLowStock: e.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<PartsPageChanged>(
      (e, emit) => _load(state.query.copyWith(page: e.value), emit),
    );
    on<PartsPageSizeChanged>(
      (e, emit) =>
          _load(state.query.copyWith(page: 1, pageSize: e.value), emit),
    );
  }
  final GetParts _get;
  Future<void> _load(PartQuery query, Emitter<PartsListState> emit) async {
    emit(
      PartsListState(
        status: PartsListStatus.loading,
        query: query,
        result: state.result,
      ),
    );
    try {
      final result = await _get(query);
      emit(
        PartsListState(
          status: result.items.isEmpty
              ? PartsListStatus.empty
              : PartsListStatus.success,
          query: query,
          result: result,
        ),
      );
    } catch (error) {
      emit(
        PartsListState(
          status: PartsListStatus.failure,
          query: query,
          result: state.result,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
