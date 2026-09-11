import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class MaintenanceCategoriesListEvent extends Equatable {
  const MaintenanceCategoriesListEvent();
  @override
  List<Object?> get props => [];
}

final class MaintenanceCategoriesRequested
    extends MaintenanceCategoriesListEvent {
  const MaintenanceCategoriesRequested();
}

final class MaintenanceCategoriesSearchChanged
    extends MaintenanceCategoriesListEvent {
  const MaintenanceCategoriesSearchChanged(this.value);
  final String value;
  @override
  List<Object> get props => [value];
}

final class MaintenanceCategoriesStatusFilterChanged
    extends MaintenanceCategoriesListEvent {
  const MaintenanceCategoriesStatusFilterChanged(this.value);
  final bool? value;
  @override
  List<Object?> get props => [value];
}

final class MaintenanceCategoriesPageChanged
    extends MaintenanceCategoriesListEvent {
  const MaintenanceCategoriesPageChanged(this.page);
  final int page;
  @override
  List<Object> get props => [page];
}

final class MaintenanceCategoriesPageSizeChanged
    extends MaintenanceCategoriesListEvent {
  const MaintenanceCategoriesPageSizeChanged(this.pageSize);
  final int pageSize;
  @override
  List<Object> get props => [pageSize];
}

enum MaintenanceCategoriesListStatus {
  initial,
  loading,
  success,
  empty,
  failure,
}

class MaintenanceCategoriesListState extends Equatable {
  const MaintenanceCategoriesListState({
    this.status = MaintenanceCategoriesListStatus.initial,
    this.query = const MaintenanceCategoryQuery(),
    this.result,
    this.failure,
  });
  final MaintenanceCategoriesListStatus status;
  final MaintenanceCategoryQuery query;
  final PagedMaintenanceCategories? result;
  final Failure? failure;
  @override
  List<Object?> get props => [status, query, result, failure];
}

@injectable
class MaintenanceCategoriesListBloc
    extends
        Bloc<MaintenanceCategoriesListEvent, MaintenanceCategoriesListState> {
  MaintenanceCategoriesListBloc(this._getCategories)
    : super(const MaintenanceCategoriesListState()) {
    on<MaintenanceCategoriesRequested>((_, emit) => _load(state.query, emit));
    on<MaintenanceCategoriesSearchChanged>(
      (event, emit) =>
          _load(state.query.copyWith(search: event.value, page: 1), emit),
    );
    on<MaintenanceCategoriesStatusFilterChanged>(
      (event, emit) => _load(
        state.query.copyWith(
          isActive: event.value,
          clearIsActive: event.value == null,
          page: 1,
        ),
        emit,
      ),
    );
    on<MaintenanceCategoriesPageChanged>(
      (event, emit) => _load(state.query.copyWith(page: event.page), emit),
    );
    on<MaintenanceCategoriesPageSizeChanged>(
      (event, emit) =>
          _load(state.query.copyWith(page: 1, pageSize: event.pageSize), emit),
    );
  }

  final GetMaintenanceCategories _getCategories;

  Future<void> _load(
    MaintenanceCategoryQuery query,
    Emitter<MaintenanceCategoriesListState> emit,
  ) async {
    emit(
      MaintenanceCategoriesListState(
        status: MaintenanceCategoriesListStatus.loading,
        query: query,
        result: state.result,
      ),
    );
    try {
      final result = await _getCategories(query);
      emit(
        MaintenanceCategoriesListState(
          status: result.items.isEmpty
              ? MaintenanceCategoriesListStatus.empty
              : MaintenanceCategoriesListStatus.success,
          query: query,
          result: result,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceCategoriesListState(
          status: MaintenanceCategoriesListStatus.failure,
          query: query,
          result: state.result,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
