import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_current_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_availability.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum CurrentTechnicianStatus { initial, loading, success, submitting, failure }

class CurrentTechnicianState extends Equatable {
  const CurrentTechnicianState({
    this.status = CurrentTechnicianStatus.initial,
    this.technician,
    this.failure,
  });
  final CurrentTechnicianStatus status;
  final Technician? technician;
  final Failure? failure;
  @override
  List<Object?> get props => [status, technician, failure];
}

@injectable
class CurrentTechnicianCubit extends Cubit<CurrentTechnicianState> {
  CurrentTechnicianCubit(this._get, this._updateAvailability)
    : super(const CurrentTechnicianState());
  final GetCurrentTechnician _get;
  final UpdateTechnicianAvailability _updateAvailability;

  Future<void> load() async {
    emit(
      CurrentTechnicianState(
        status: CurrentTechnicianStatus.loading,
        technician: state.technician,
      ),
    );
    try {
      emit(
        CurrentTechnicianState(
          status: CurrentTechnicianStatus.success,
          technician: await _get(),
        ),
      );
    } catch (error) {
      emit(
        CurrentTechnicianState(
          status: CurrentTechnicianStatus.failure,
          technician: state.technician,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> setAvailability(bool value) async {
    final technician = state.technician;
    if (technician == null) return;
    emit(
      CurrentTechnicianState(
        status: CurrentTechnicianStatus.submitting,
        technician: technician,
      ),
    );
    try {
      emit(
        CurrentTechnicianState(
          status: CurrentTechnicianStatus.success,
          technician: await _updateAvailability(technician.id, value),
        ),
      );
    } catch (error) {
      emit(
        CurrentTechnicianState(
          status: CurrentTechnicianStatus.failure,
          technician: technician,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
