import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/assign_technician.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_assignment_history.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/reassign_technician.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/unassign_technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_available_technicians.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum MaintenanceAssignmentStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

class MaintenanceAssignmentState extends Equatable {
  const MaintenanceAssignmentState({
    this.status = MaintenanceAssignmentStatus.initial,
    this.availableTechnicians = const [],
    this.history = const [],
    this.assignment,
    this.failure,
  });
  final MaintenanceAssignmentStatus status;
  final List<Technician> availableTechnicians;
  final List<MaintenanceAssignment> history;
  final MaintenanceAssignment? assignment;
  final Failure? failure;
  @override
  List<Object?> get props => [
    status,
    availableTechnicians,
    history,
    assignment,
    failure,
  ];
}

@injectable
class MaintenanceAssignmentCubit extends Cubit<MaintenanceAssignmentState> {
  MaintenanceAssignmentCubit(
    this._getAvailable,
    this._getHistory,
    this._assign,
    this._reassign,
    this._unassign,
  ) : super(const MaintenanceAssignmentState());

  final GetAvailableTechnicians _getAvailable;
  final GetAssignmentHistory _getHistory;
  final AssignTechnician _assign;
  final ReassignTechnician _reassign;
  final UnassignTechnician _unassign;

  Future<void> load(MaintenanceRequest request) async {
    emit(
      const MaintenanceAssignmentState(
        status: MaintenanceAssignmentStatus.loading,
      ),
    );
    try {
      final results = await Future.wait<Object>([
        _getAvailable(request.categoryId),
        _getHistory(request.id),
      ]);
      emit(
        MaintenanceAssignmentState(
          status: MaintenanceAssignmentStatus.ready,
          availableTechnicians: results[0] as List<Technician>,
          history: results[1] as List<MaintenanceAssignment>,
          assignment: request.activeAssignment,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceAssignmentState(
          status: MaintenanceAssignmentStatus.failure,
          assignment: request.activeAssignment,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> assign(String requestId, String technicianId) =>
      _submit(() => _assign(requestId, technicianId));

  Future<void> reassign(String requestId, String technicianId) =>
      _submit(() => _reassign(requestId, technicianId));

  Future<void> unassign(String requestId) async {
    final previous = state;
    emit(
      MaintenanceAssignmentState(
        status: MaintenanceAssignmentStatus.submitting,
        availableTechnicians: previous.availableTechnicians,
        history: previous.history,
        assignment: previous.assignment,
      ),
    );
    try {
      await _unassign(requestId);
      emit(
        MaintenanceAssignmentState(
          status: MaintenanceAssignmentStatus.success,
          availableTechnicians: previous.availableTechnicians,
          history: previous.history,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceAssignmentState(
          status: MaintenanceAssignmentStatus.failure,
          availableTechnicians: previous.availableTechnicians,
          history: previous.history,
          assignment: previous.assignment,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> _submit(
    Future<MaintenanceAssignment> Function() operation,
  ) async {
    final previous = state;
    emit(
      MaintenanceAssignmentState(
        status: MaintenanceAssignmentStatus.submitting,
        availableTechnicians: previous.availableTechnicians,
        history: previous.history,
        assignment: previous.assignment,
      ),
    );
    try {
      final assignment = await operation();
      emit(
        MaintenanceAssignmentState(
          status: MaintenanceAssignmentStatus.success,
          availableTechnicians: previous.availableTechnicians,
          history: previous.history,
          assignment: assignment,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceAssignmentState(
          status: MaintenanceAssignmentStatus.failure,
          availableTechnicians: previous.availableTechnicians,
          history: previous.history,
          assignment: previous.assignment,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
