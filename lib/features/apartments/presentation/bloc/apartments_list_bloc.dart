import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment_query.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/paged_apartments.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartments.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class ApartmentsListEvent extends Equatable {
  const ApartmentsListEvent();
  @override
  List<Object?> get props => [];
}

final class ApartmentsRequested extends ApartmentsListEvent {
  const ApartmentsRequested();
}

final class ApartmentsSearchChanged extends ApartmentsListEvent {
  const ApartmentsSearchChanged(this.value);
  final String value;
  @override
  List<Object> get props => [value];
}

final class ApartmentsPageChanged extends ApartmentsListEvent {
  const ApartmentsPageChanged(this.page);
  final int page;
  @override
  List<Object> get props => [page];
}

final class ApartmentsPageSizeChanged extends ApartmentsListEvent {
  const ApartmentsPageSizeChanged(this.pageSize);
  final int pageSize;
  @override
  List<Object> get props => [pageSize];
}

enum ApartmentsListStatus { initial, loading, success, empty, failure }

class ApartmentsListState extends Equatable {
  const ApartmentsListState({
    this.status = ApartmentsListStatus.initial,
    this.query = const ApartmentQuery(),
    this.result,
    this.failure,
  });

  final ApartmentsListStatus status;
  final ApartmentQuery query;
  final PagedApartments? result;
  final Failure? failure;

  @override
  List<Object?> get props => [status, query, result, failure];
}

@injectable
class ApartmentsListBloc
    extends Bloc<ApartmentsListEvent, ApartmentsListState> {
  ApartmentsListBloc(this._getApartments) : super(const ApartmentsListState()) {
    on<ApartmentsRequested>((_, emit) => _load(state.query, emit));
    on<ApartmentsSearchChanged>(
      (event, emit) =>
          _load(state.query.copyWith(search: event.value, page: 1), emit),
    );
    on<ApartmentsPageChanged>(
      (event, emit) => _load(state.query.copyWith(page: event.page), emit),
    );
    on<ApartmentsPageSizeChanged>(
      (event, emit) =>
          _load(state.query.copyWith(page: 1, pageSize: event.pageSize), emit),
    );
  }

  final GetApartments _getApartments;

  Future<void> _load(
    ApartmentQuery query,
    Emitter<ApartmentsListState> emit,
  ) async {
    emit(
      ApartmentsListState(
        status: ApartmentsListStatus.loading,
        query: query,
        result: state.result,
      ),
    );
    try {
      final result = await _getApartments(query);
      emit(
        ApartmentsListState(
          status: result.items.isEmpty
              ? ApartmentsListStatus.empty
              : ApartmentsListStatus.success,
          query: query,
          result: result,
        ),
      );
    } catch (error) {
      emit(
        ApartmentsListState(
          status: ApartmentsListStatus.failure,
          query: query,
          result: state.result,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
