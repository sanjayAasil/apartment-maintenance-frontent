import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_work.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/maintenance_work_usecases.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/entities/part_query.dart';
import 'package:apartment_maintenance_frontent/features/parts/domain/usecases/parts_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum MaintenanceWorkStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
}

class MaintenanceWorkState extends Equatable {
  const MaintenanceWorkState({
    this.status = MaintenanceWorkStatus.initial,
    this.note,
    this.usages = const [],
    this.availableParts = const [],
    this.cost,
    this.failure,
  });
  final MaintenanceWorkStatus status;
  final MaintenanceWorkNote? note;
  final List<MaintenancePartUsage> usages;
  final List<Part> availableParts;
  final MaintenanceCost? cost;
  final Failure? failure;
  @override
  List<Object?> get props => [
    status,
    note,
    usages,
    availableParts,
    cost,
    failure,
  ];
}

@injectable
class MaintenanceWorkCubit extends Cubit<MaintenanceWorkState> {
  MaintenanceWorkCubit(
    this._getNote,
    this._saveNote,
    this._getParts,
    this._addPart,
    this._removePart,
    this._getCost,
    this._getInventory,
  ) : super(const MaintenanceWorkState());
  final GetMaintenanceWorkNote _getNote;
  final SaveMaintenanceWorkNote _saveNote;
  final GetMaintenanceParts _getParts;
  final AddMaintenancePart _addPart;
  final RemoveMaintenancePart _removePart;
  final GetMaintenanceCost _getCost;
  final GetParts _getInventory;
  String? _requestId;

  Future<void> load(String requestId, {required bool loadInventory}) async {
    _requestId = requestId;
    emit(
      MaintenanceWorkState(
        status: MaintenanceWorkStatus.loading,
        note: state.note,
        usages: state.usages,
        availableParts: state.availableParts,
        cost: state.cost,
      ),
    );
    try {
      final values = await Future.wait<dynamic>([
        _getNote(requestId),
        _getParts(requestId),
        _getCost(requestId),
        if (loadInventory)
          _getInventory(const PartQuery(isActive: true, pageSize: 100)),
      ]);
      emit(
        MaintenanceWorkState(
          status: MaintenanceWorkStatus.loaded,
          note: values[0] as MaintenanceWorkNote?,
          usages: values[1] as List<MaintenancePartUsage>,
          cost: values[2] as MaintenanceCost,
          availableParts: loadInventory
              ? (values[3] as dynamic).items as List<Part>
              : const [],
        ),
      );
    } catch (error) {
      emit(
        MaintenanceWorkState(
          status: MaintenanceWorkStatus.failure,
          note: state.note,
          usages: state.usages,
          availableParts: state.availableParts,
          cost: state.cost,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> saveNote({
    required String diagnosis,
    required String workPerformed,
    required double laborCost,
    required double otherCost,
  }) async => _mutate(
    () => _saveNote(
      requestId: _requestId!,
      noteId: state.note?.id,
      diagnosis: diagnosis,
      workPerformed: workPerformed,
      laborCost: laborCost,
      otherCost: otherCost,
    ),
  );
  Future<void> addPart(String partId, int quantity) async =>
      _mutate(() => _addPart(_requestId!, partId, quantity));
  Future<void> removePart(String usageId) async =>
      _mutate(() => _removePart(_requestId!, usageId));
  Future<void> _mutate(Future<dynamic> Function() action) async {
    emit(
      MaintenanceWorkState(
        status: MaintenanceWorkStatus.submitting,
        note: state.note,
        usages: state.usages,
        availableParts: state.availableParts,
        cost: state.cost,
      ),
    );
    try {
      await action();
      final requestId = _requestId!;
      await load(requestId, loadInventory: state.availableParts.isNotEmpty);
      emit(
        MaintenanceWorkState(
          status: MaintenanceWorkStatus.success,
          note: state.note,
          usages: state.usages,
          availableParts: state.availableParts,
          cost: state.cost,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceWorkState(
          status: MaintenanceWorkStatus.failure,
          note: state.note,
          usages: state.usages,
          availableParts: state.availableParts,
          cost: state.cost,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
