import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/add_maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_comments.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum MaintenanceCommentsStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitSuccess,
  failure,
}

class MaintenanceCommentsState extends Equatable {
  const MaintenanceCommentsState({
    this.status = MaintenanceCommentsStatus.initial,
    this.comments = const [],
    this.failure,
  });
  final MaintenanceCommentsStatus status;
  final List<MaintenanceComment> comments;
  final Failure? failure;
  @override
  List<Object?> get props => [status, comments, failure];
}

@injectable
class MaintenanceCommentsCubit extends Cubit<MaintenanceCommentsState> {
  MaintenanceCommentsCubit(this._getComments, this._addComment)
    : super(const MaintenanceCommentsState());

  final GetMaintenanceComments _getComments;
  final AddMaintenanceComment _addComment;

  Future<void> load(String requestId) async {
    emit(
      MaintenanceCommentsState(
        status: MaintenanceCommentsStatus.loading,
        comments: state.comments,
      ),
    );
    try {
      emit(
        MaintenanceCommentsState(
          status: MaintenanceCommentsStatus.loaded,
          comments: await _getComments(requestId),
        ),
      );
    } catch (error) {
      emit(
        MaintenanceCommentsState(
          status: MaintenanceCommentsStatus.failure,
          comments: state.comments,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<bool> add(String requestId, String message) async {
    final normalized = message.trim();
    if (normalized.isEmpty) {
      emit(
        MaintenanceCommentsState(
          status: MaintenanceCommentsStatus.failure,
          comments: state.comments,
          failure: const Failure(
            kind: FailureKind.validation,
            message: 'Enter a comment before sending.',
          ),
        ),
      );
      return false;
    }
    final previous = state.comments;
    emit(
      MaintenanceCommentsState(
        status: MaintenanceCommentsStatus.submitting,
        comments: previous,
      ),
    );
    try {
      final comment = await _addComment(requestId, normalized);
      emit(
        MaintenanceCommentsState(
          status: MaintenanceCommentsStatus.submitSuccess,
          comments: [...previous, comment],
        ),
      );
      return true;
    } catch (error) {
      emit(
        MaintenanceCommentsState(
          status: MaintenanceCommentsStatus.failure,
          comments: previous,
          failure: mapApiError(error),
        ),
      );
      return false;
    }
  }
}
