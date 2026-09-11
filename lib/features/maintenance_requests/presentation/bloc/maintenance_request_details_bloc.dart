import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_request.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class MaintenanceRequestDetailsEvent extends Equatable {
  const MaintenanceRequestDetailsEvent();
  @override
  List<Object> get props => [];
}

final class MaintenanceRequestDetailsRequested
    extends MaintenanceRequestDetailsEvent {
  const MaintenanceRequestDetailsRequested(this.id);
  final String id;
  @override
  List<Object> get props => [id];
}

enum MaintenanceRequestDetailsStatus { initial, loading, success, failure }

class MaintenanceRequestDetailsState extends Equatable {
  const MaintenanceRequestDetailsState({
    this.status = MaintenanceRequestDetailsStatus.initial,
    this.request,
    this.failure,
  });
  final MaintenanceRequestDetailsStatus status;
  final MaintenanceRequest? request;
  final Failure? failure;
  @override
  List<Object?> get props => [status, request, failure];
}

@injectable
class MaintenanceRequestDetailsBloc
    extends
        Bloc<MaintenanceRequestDetailsEvent, MaintenanceRequestDetailsState> {
  MaintenanceRequestDetailsBloc(this._get)
    : super(const MaintenanceRequestDetailsState()) {
    on<MaintenanceRequestDetailsRequested>((event, emit) async {
      emit(
        const MaintenanceRequestDetailsState(
          status: MaintenanceRequestDetailsStatus.loading,
        ),
      );
      try {
        emit(
          MaintenanceRequestDetailsState(
            status: MaintenanceRequestDetailsStatus.success,
            request: await _get(event.id),
          ),
        );
      } catch (error) {
        emit(
          MaintenanceRequestDetailsState(
            status: MaintenanceRequestDetailsStatus.failure,
            failure: mapApiError(error),
          ),
        );
      }
    });
  }
  final GetMaintenanceRequest _get;
}
