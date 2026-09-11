import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_current_resident.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class CurrentResidentEvent extends Equatable {
  const CurrentResidentEvent();
  @override
  List<Object> get props => [];
}

final class CurrentResidentRequested extends CurrentResidentEvent {
  const CurrentResidentRequested();
}

enum CurrentResidentStatus { initial, loading, success, failure }

class CurrentResidentState extends Equatable {
  const CurrentResidentState({
    this.status = CurrentResidentStatus.initial,
    this.resident,
    this.failure,
  });
  final CurrentResidentStatus status;
  final Resident? resident;
  final Failure? failure;
  @override
  List<Object?> get props => [status, resident, failure];
}

@injectable
class CurrentResidentBloc
    extends Bloc<CurrentResidentEvent, CurrentResidentState> {
  CurrentResidentBloc(this._getCurrent) : super(const CurrentResidentState()) {
    on<CurrentResidentRequested>((_, emit) async {
      emit(const CurrentResidentState(status: CurrentResidentStatus.loading));
      try {
        emit(
          CurrentResidentState(
            status: CurrentResidentStatus.success,
            resident: await _getCurrent(),
          ),
        );
      } catch (error) {
        emit(
          CurrentResidentState(
            status: CurrentResidentStatus.failure,
            failure: mapApiError(error),
          ),
        );
      }
    });
  }

  final GetCurrentResident _getCurrent;
}
