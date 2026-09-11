import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/add_technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/create_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/remove_technician_skill.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_availability.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_status.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum TechnicianMutationStatus {
  initial,
  loadingOptions,
  ready,
  submitting,
  success,
  failure,
}

class TechnicianMutationState extends Equatable {
  const TechnicianMutationState({
    this.status = TechnicianMutationStatus.initial,
    this.users = const [],
    this.categories = const [],
    this.technician,
    this.failure,
  });
  final TechnicianMutationStatus status;
  final List<AppUser> users;
  final List<MaintenanceCategory> categories;
  final Technician? technician;
  final Failure? failure;
  @override
  List<Object?> get props => [status, users, categories, technician, failure];
}

@injectable
class TechnicianMutationCubit extends Cubit<TechnicianMutationState> {
  TechnicianMutationCubit(
    this._getUsers,
    this._getCategories,
    this._create,
    this._update,
    this._updateStatus,
    this._updateAvailability,
    this._addSkill,
    this._removeSkill,
  ) : super(const TechnicianMutationState());

  final GetUsers _getUsers;
  final GetMaintenanceCategories _getCategories;
  final CreateTechnician _create;
  final UpdateTechnician _update;
  final UpdateTechnicianStatus _updateStatus;
  final UpdateTechnicianAvailability _updateAvailability;
  final AddTechnicianSkill _addSkill;
  final RemoveTechnicianSkill _removeSkill;

  Future<void> loadOptions() async {
    emit(
      const TechnicianMutationState(
        status: TechnicianMutationStatus.loadingOptions,
      ),
    );
    try {
      final users = await _getUsers(
        const UserQuery(
          role: UserRole.technician,
          isActive: true,
          pageSize: 100,
        ),
      );
      final categories = await _getCategories(
        const MaintenanceCategoryQuery(isActive: true, pageSize: 100),
      );
      emit(
        TechnicianMutationState(
          status: TechnicianMutationStatus.ready,
          users: users.items,
          categories: categories.items,
        ),
      );
    } catch (error) {
      emit(
        TechnicianMutationState(
          status: TechnicianMutationStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> create(String userId, String phone, int years) =>
      _submit(() => _create(userId, phone, years));
  Future<void> update(String id, String phone, int years) =>
      _submit(() => _update(id, phone, years));
  Future<void> updateStatus(String id, bool value) =>
      _submit(() => _updateStatus(id, value));
  Future<void> updateAvailability(String id, bool value) =>
      _submit(() => _updateAvailability(id, value));

  Future<void> addSkill(String id, String categoryId) async {
    await _submit(() async {
      await _addSkill(id, categoryId);
      return state.technician;
    });
  }

  Future<void> removeSkill(String id, String categoryId) async {
    await _submit(() async {
      await _removeSkill(id, categoryId);
      return state.technician;
    });
  }

  Future<void> _submit(Future<Technician?> Function() action) async {
    final previous = state;
    emit(
      TechnicianMutationState(
        status: TechnicianMutationStatus.submitting,
        users: previous.users,
        categories: previous.categories,
        technician: previous.technician,
      ),
    );
    try {
      emit(
        TechnicianMutationState(
          status: TechnicianMutationStatus.success,
          users: previous.users,
          categories: previous.categories,
          technician: await action(),
        ),
      );
    } catch (error) {
      emit(
        TechnicianMutationState(
          status: TechnicianMutationStatus.failure,
          users: previous.users,
          categories: previous.categories,
          technician: previous.technician,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
