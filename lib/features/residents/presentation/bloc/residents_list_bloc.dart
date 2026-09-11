import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/paged_residents.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident_query.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_residents.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class ResidentsListEvent extends Equatable {
  const ResidentsListEvent();
  @override
  List<Object?> get props => [];
}

final class ResidentsRequested extends ResidentsListEvent {
  const ResidentsRequested();
}

final class ResidentsSearchChanged extends ResidentsListEvent {
  const ResidentsSearchChanged(this.value);
  final String value;
  @override
  List<Object> get props => [value];
}

final class ResidentsActiveChanged extends ResidentsListEvent {
  const ResidentsActiveChanged(this.value);
  final bool? value;
  @override
  List<Object?> get props => [value];
}

final class ResidentsPageChanged extends ResidentsListEvent {
  const ResidentsPageChanged(this.page);
  final int page;
  @override
  List<Object> get props => [page];
}

final class ResidentsPageSizeChanged extends ResidentsListEvent {
  const ResidentsPageSizeChanged(this.pageSize);
  final int pageSize;
  @override
  List<Object> get props => [pageSize];
}

enum ResidentsListStatus { initial, loading, success, empty, failure }

class ResidentsListState extends Equatable {
  const ResidentsListState({
    this.status = ResidentsListStatus.initial,
    this.query = const ResidentQuery(),
    this.result,
    this.failure,
  });

  final ResidentsListStatus status;
  final ResidentQuery query;
  final PagedResidents? result;
  final Failure? failure;

  @override
  List<Object?> get props => [status, query, result, failure];
}

@injectable
class ResidentsListBloc extends Bloc<ResidentsListEvent, ResidentsListState> {
  ResidentsListBloc(this._getResidents) : super(const ResidentsListState()) {
    on<ResidentsRequested>((_, emit) => _load(state.query, emit));
    on<ResidentsSearchChanged>(
      (event, emit) =>
          _load(state.query.copyWith(search: event.value, page: 1), emit),
    );
    on<ResidentsActiveChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          isActive: event.value,
          clearActive: event.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<ResidentsPageChanged>(
      (event, emit) => _load(state.query.copyWith(page: event.page), emit),
    );
    on<ResidentsPageSizeChanged>(
      (event, emit) =>
          _load(state.query.copyWith(page: 1, pageSize: event.pageSize), emit),
    );
  }

  final GetResidents _getResidents;

  Future<void> _load(
    ResidentQuery query,
    Emitter<ResidentsListState> emit,
  ) async {
    emit(
      ResidentsListState(
        status: ResidentsListStatus.loading,
        query: query,
        result: state.result,
      ),
    );
    try {
      final result = await _getResidents(query);
      emit(
        ResidentsListState(
          status: result.items.isEmpty
              ? ResidentsListStatus.empty
              : ResidentsListStatus.success,
          query: query,
          result: result,
        ),
      );
    } catch (error) {
      emit(
        ResidentsListState(
          status: ResidentsListStatus.failure,
          query: query,
          result: state.result,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
