import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment_query.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartments.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/change_resident_apartment.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/create_resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/update_resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/update_resident_status.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/entities/user_query.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum ResidentMutationStatus {
  initial,
  loadingOptions,
  ready,
  submitting,
  success,
  failure,
}

class ResidentMutationState extends Equatable {
  const ResidentMutationState({
    this.status = ResidentMutationStatus.initial,
    this.users = const [],
    this.apartments = const [],
    this.resident,
    this.failure,
  });

  final ResidentMutationStatus status;
  final List<AppUser> users;
  final List<Apartment> apartments;
  final Resident? resident;
  final Failure? failure;

  @override
  List<Object?> get props => [status, users, apartments, resident, failure];
}

@injectable
class ResidentMutationCubit extends Cubit<ResidentMutationState> {
  ResidentMutationCubit(
    this._getUsers,
    this._getApartments,
    this._create,
    this._update,
    this._changeApartment,
    this._updateStatus,
  ) : super(const ResidentMutationState());

  final GetUsers _getUsers;
  final GetApartments _getApartments;
  final CreateResident _create;
  final UpdateResident _update;
  final ChangeResidentApartment _changeApartment;
  final UpdateResidentStatus _updateStatus;

  Future<void> loadOptions() async {
    emit(
      ResidentMutationState(
        status: ResidentMutationStatus.loadingOptions,
        users: state.users,
        apartments: state.apartments,
      ),
    );
    try {
      final users = await _getUsers(
        const UserQuery(role: UserRole.resident, isActive: true, pageSize: 100),
      );
      final apartments = await _getApartments(
        const ApartmentQuery(pageSize: 100),
      );
      emit(
        ResidentMutationState(
          status: ResidentMutationStatus.ready,
          users: users.items,
          apartments: apartments.items,
        ),
      );
    } catch (error) {
      emit(
        ResidentMutationState(
          status: ResidentMutationStatus.failure,
          users: state.users,
          apartments: state.apartments,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> create(
    String userId,
    String apartmentId,
    String phone,
    String moveInDate,
  ) async => _submit(() => _create(userId, apartmentId, phone, moveInDate));

  Future<void> update(String id, String phone, String moveInDate) async =>
      _submit(() => _update(id, phone, moveInDate));

  Future<void> changeApartment(String id, String apartmentId) async =>
      _submit(() => _changeApartment(id, apartmentId));

  Future<void> updateStatus(String id, bool isActive) async =>
      _submit(() => _updateStatus(id, isActive));

  Future<void> _submit(Future<Resident> Function() operation) async {
    emit(
      ResidentMutationState(
        status: ResidentMutationStatus.submitting,
        users: state.users,
        apartments: state.apartments,
        resident: state.resident,
      ),
    );
    try {
      emit(
        ResidentMutationState(
          status: ResidentMutationStatus.success,
          users: state.users,
          apartments: state.apartments,
          resident: await operation(),
        ),
      );
    } catch (error) {
      emit(
        ResidentMutationState(
          status: ResidentMutationStatus.failure,
          users: state.users,
          apartments: state.apartments,
          resident: state.resident,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
