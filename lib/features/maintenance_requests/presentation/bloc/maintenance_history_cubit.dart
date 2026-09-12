import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_history.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum MaintenanceHistoryStatus { initial, loading, loaded, failure }

class MaintenanceHistoryState extends Equatable {
  const MaintenanceHistoryState({
    this.status = MaintenanceHistoryStatus.initial,
    this.entries = const [],
    this.failure,
  });
  final MaintenanceHistoryStatus status;
  final List<MaintenanceHistoryEntry> entries;
  final Failure? failure;
  @override
  List<Object?> get props => [status, entries, failure];
}

@injectable
class MaintenanceHistoryCubit extends Cubit<MaintenanceHistoryState> {
  MaintenanceHistoryCubit(this._getHistory)
    : super(const MaintenanceHistoryState());
  final GetMaintenanceHistory _getHistory;

  Future<void> load(String requestId) async {
    emit(
      const MaintenanceHistoryState(status: MaintenanceHistoryStatus.loading),
    );
    try {
      emit(
        MaintenanceHistoryState(
          status: MaintenanceHistoryStatus.loaded,
          entries: await _getHistory(requestId),
        ),
      );
    } catch (error) {
      emit(
        MaintenanceHistoryState(
          status: MaintenanceHistoryStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
