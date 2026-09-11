import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/create_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum MaintenanceCategoryFormStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
}

class MaintenanceCategoryFormState extends Equatable {
  const MaintenanceCategoryFormState({
    this.status = MaintenanceCategoryFormStatus.initial,
    this.category,
    this.failure,
  });
  final MaintenanceCategoryFormStatus status;
  final MaintenanceCategory? category;
  final Failure? failure;
  @override
  List<Object?> get props => [status, category, failure];
}

@injectable
class MaintenanceCategoryFormCubit extends Cubit<MaintenanceCategoryFormState> {
  MaintenanceCategoryFormCubit(
    this._get,
    this._create,
    this._update,
    this._updateStatus,
  ) : super(const MaintenanceCategoryFormState());

  final GetMaintenanceCategory _get;
  final CreateMaintenanceCategory _create;
  final UpdateMaintenanceCategory _update;
  final UpdateMaintenanceCategoryStatus _updateStatus;

  Future<void> load(String id) async {
    emit(
      const MaintenanceCategoryFormState(
        status: MaintenanceCategoryFormStatus.loading,
      ),
    );
    try {
      emit(
        MaintenanceCategoryFormState(
          status: MaintenanceCategoryFormStatus.loaded,
          category: await _get(id),
        ),
      );
    } catch (error) {
      emit(
        MaintenanceCategoryFormState(
          status: MaintenanceCategoryFormStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> create(String name, String? description) =>
      _submit(() => _create(name, description));

  Future<void> update(String id, String name, String? description) =>
      _submit(() => _update(id, name, description));

  Future<void> updateStatus(String id, bool isActive) =>
      _submit(() => _updateStatus(id, isActive));

  Future<void> _submit(Future<MaintenanceCategory> Function() action) async {
    final previous = state.category;
    emit(
      MaintenanceCategoryFormState(
        status: MaintenanceCategoryFormStatus.submitting,
        category: previous,
      ),
    );
    try {
      emit(
        MaintenanceCategoryFormState(
          status: MaintenanceCategoryFormStatus.success,
          category: await action(),
        ),
      );
    } catch (error) {
      emit(
        MaintenanceCategoryFormState(
          status: MaintenanceCategoryFormStatus.failure,
          category: previous,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
