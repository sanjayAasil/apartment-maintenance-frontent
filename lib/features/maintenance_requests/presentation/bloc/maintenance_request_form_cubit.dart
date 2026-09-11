import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/create_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum MaintenanceRequestFormStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
}

class MaintenanceRequestFormState extends Equatable {
  const MaintenanceRequestFormState({
    this.status = MaintenanceRequestFormStatus.initial,
    this.request,
    this.categories = const [],
    this.failure,
  });
  final MaintenanceRequestFormStatus status;
  final MaintenanceRequest? request;
  final List<MaintenanceCategory> categories;
  final Failure? failure;
  @override
  List<Object?> get props => [status, request, categories, failure];
}

@injectable
class MaintenanceRequestFormCubit extends Cubit<MaintenanceRequestFormState> {
  MaintenanceRequestFormCubit(
    this._getRequest,
    this._getCategories,
    this._create,
    this._update,
    this._updateStatus,
  ) : super(const MaintenanceRequestFormState());
  final GetMaintenanceRequest _getRequest;
  final GetMaintenanceCategories _getCategories;
  final CreateMaintenanceRequest _create;
  final UpdateMaintenanceRequest _update;
  final UpdateMaintenanceRequestStatus _updateStatus;

  Future<void> load({String? id}) async {
    emit(
      const MaintenanceRequestFormState(
        status: MaintenanceRequestFormStatus.loading,
      ),
    );
    try {
      final categories = (await _getCategories(
        const MaintenanceCategoryQuery(isActive: true, pageSize: 100),
      )).items;
      final request = id == null ? null : await _getRequest(id);
      emit(
        MaintenanceRequestFormState(
          status: MaintenanceRequestFormStatus.loaded,
          request: request,
          categories: categories,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceRequestFormState(
          status: MaintenanceRequestFormStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> create(
    String categoryId,
    String title,
    String description,
    MaintenancePriority priority,
  ) => _submit(() => _create(categoryId, title, description, priority));
  Future<void> update(
    String id,
    String categoryId,
    String title,
    String description,
    MaintenancePriority priority,
  ) => _submit(
    () => _update(
      id,
      categoryId: categoryId,
      title: title,
      description: description,
      priority: priority,
    ),
  );
  Future<void> updateStatus(String id, MaintenanceRequestStatus status) =>
      _submit(() => _updateStatus(id, status));
  Future<void> _submit(Future<MaintenanceRequest> Function() action) async {
    final previous = state;
    emit(
      MaintenanceRequestFormState(
        status: MaintenanceRequestFormStatus.submitting,
        request: previous.request,
        categories: previous.categories,
      ),
    );
    try {
      emit(
        MaintenanceRequestFormState(
          status: MaintenanceRequestFormStatus.success,
          request: await action(),
          categories: previous.categories,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceRequestFormState(
          status: MaintenanceRequestFormStatus.failure,
          request: previous.request,
          categories: previous.categories,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
