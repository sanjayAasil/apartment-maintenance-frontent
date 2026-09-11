import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_resident.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class ResidentDetailsEvent extends Equatable {
  const ResidentDetailsEvent();
  @override
  List<Object> get props => [];
}

final class ResidentDetailsRequested extends ResidentDetailsEvent {
  const ResidentDetailsRequested(this.id);
  final String id;
  @override
  List<Object> get props => [id];
}

enum ResidentDetailsStatus { initial, loading, success, failure }

class ResidentDetailsState extends Equatable {
  const ResidentDetailsState({
    this.status = ResidentDetailsStatus.initial,
    this.resident,
    this.failure,
  });
  final ResidentDetailsStatus status;
  final Resident? resident;
  final Failure? failure;
  @override
  List<Object?> get props => [status, resident, failure];
}

@injectable
class ResidentDetailsBloc
    extends Bloc<ResidentDetailsEvent, ResidentDetailsState> {
  ResidentDetailsBloc(this._getResident) : super(const ResidentDetailsState()) {
    on<ResidentDetailsRequested>((event, emit) async {
      emit(const ResidentDetailsState(status: ResidentDetailsStatus.loading));
      try {
        emit(
          ResidentDetailsState(
            status: ResidentDetailsStatus.success,
            resident: await _getResident(event.id),
          ),
        );
      } catch (error) {
        emit(
          ResidentDetailsState(
            status: ResidentDetailsStatus.failure,
            failure: mapApiError(error),
          ),
        );
      }
    });
  }

  final GetResident _getResident;
}
