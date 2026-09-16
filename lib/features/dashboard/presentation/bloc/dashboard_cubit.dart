import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/usecases/get_dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum DashboardStatus { initial, loading, loaded, refreshing, failure }

class DashboardState {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.data,
    this.range,
    this.failure,
  });
  final DashboardStatus status;
  final DashboardData? data;
  final DashboardRange? range;
  final Failure? failure;
}

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getDashboard) : super(const DashboardState());
  final GetDashboard _getDashboard;
  int _request = 0;
  Future<void> load([DashboardRange? range]) async {
    final selected = range ?? state.range ?? DashboardRange.thisMonth();
    final previous = state;
    final request = ++_request;
    emit(
      DashboardState(
        status: previous.data == null
            ? DashboardStatus.loading
            : DashboardStatus.refreshing,
        data: previous.data,
        range: previous.range,
      ),
    );
    try {
      final data = await _getDashboard(selected);
      if (!isClosed && request == _request) {
        emit(
          DashboardState(
            status: DashboardStatus.loaded,
            data: data,
            range: selected,
          ),
        );
      }
    } catch (error) {
      if (!isClosed && request == _request) {
        emit(
          DashboardState(
            status: DashboardStatus.failure,
            data: previous.data,
            range: previous.range,
            failure: mapApiError(error),
          ),
        );
      }
    }
  }
}
