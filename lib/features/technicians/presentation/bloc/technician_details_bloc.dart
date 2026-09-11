import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_technician.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class TechnicianDetailsEvent extends Equatable {
  const TechnicianDetailsEvent();
  @override
  List<Object?> get props => [];
}

final class TechnicianDetailsRequested extends TechnicianDetailsEvent {
  const TechnicianDetailsRequested(this.id);
  final String id;
  @override
  List<Object> get props => [id];
}

enum TechnicianDetailsStatus { initial, loading, success, failure }

class TechnicianDetailsState extends Equatable {
  const TechnicianDetailsState({
    this.status = TechnicianDetailsStatus.initial,
    this.technician,
    this.failure,
  });
  final TechnicianDetailsStatus status;
  final Technician? technician;
  final Failure? failure;
  @override
  List<Object?> get props => [status, technician, failure];
}

@injectable
class TechnicianDetailsBloc
    extends Bloc<TechnicianDetailsEvent, TechnicianDetailsState> {
  TechnicianDetailsBloc(this._get) : super(const TechnicianDetailsState()) {
    on<TechnicianDetailsRequested>((event, emit) async {
      emit(
        TechnicianDetailsState(
          status: TechnicianDetailsStatus.loading,
          technician: state.technician,
        ),
      );
      try {
        emit(
          TechnicianDetailsState(
            status: TechnicianDetailsStatus.success,
            technician: await _get(event.id),
          ),
        );
      } catch (error) {
        emit(
          TechnicianDetailsState(
            status: TechnicianDetailsStatus.failure,
            technician: state.technician,
            failure: mapApiError(error),
          ),
        );
      }
    });
  }
  final GetTechnician _get;
}
