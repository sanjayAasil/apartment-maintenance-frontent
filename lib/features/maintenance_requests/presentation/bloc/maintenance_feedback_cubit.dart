import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_feedback.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/maintenance_feedback_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum MaintenanceFeedbackStatus {
  initial,
  loading,
  loaded,
  noFeedback,
  submitting,
  submitSuccess,
  failure,
}

class MaintenanceFeedbackState extends Equatable {
  const MaintenanceFeedbackState({
    this.status = MaintenanceFeedbackStatus.initial,
    this.feedback,
    this.failure,
  });

  final MaintenanceFeedbackStatus status;
  final MaintenanceFeedback? feedback;
  final Failure? failure;

  @override
  List<Object?> get props => [status, feedback, failure];
}

@injectable
class MaintenanceFeedbackCubit extends Cubit<MaintenanceFeedbackState> {
  MaintenanceFeedbackCubit(this._getFeedback, this._submitFeedback)
    : super(const MaintenanceFeedbackState());

  final GetMaintenanceFeedback _getFeedback;
  final SubmitMaintenanceFeedback _submitFeedback;

  Future<void> load(String requestId) async {
    emit(
      const MaintenanceFeedbackState(status: MaintenanceFeedbackStatus.loading),
    );
    try {
      final feedback = await _getFeedback(requestId);
      emit(
        MaintenanceFeedbackState(
          status: feedback == null
              ? MaintenanceFeedbackStatus.noFeedback
              : MaintenanceFeedbackStatus.loaded,
          feedback: feedback,
        ),
      );
    } catch (error) {
      emit(
        MaintenanceFeedbackState(
          status: MaintenanceFeedbackStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<bool> submit(String requestId, int rating, String? comment) async {
    if (rating < 1 || rating > 5) {
      emit(
        const MaintenanceFeedbackState(
          status: MaintenanceFeedbackStatus.failure,
          failure: Failure(
            kind: FailureKind.validation,
            message: 'Select a rating from 1 to 5 stars.',
          ),
        ),
      );
      return false;
    }
    emit(
      const MaintenanceFeedbackState(
        status: MaintenanceFeedbackStatus.submitting,
      ),
    );
    try {
      final feedback = await _submitFeedback(requestId, rating, comment);
      emit(
        MaintenanceFeedbackState(
          status: MaintenanceFeedbackStatus.submitSuccess,
          feedback: feedback,
        ),
      );
      return true;
    } catch (error) {
      emit(
        MaintenanceFeedbackState(
          status: MaintenanceFeedbackStatus.failure,
          failure: mapApiError(error),
        ),
      );
      return false;
    }
  }
}
