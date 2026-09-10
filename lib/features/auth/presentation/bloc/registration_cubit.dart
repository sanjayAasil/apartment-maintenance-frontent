import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/register.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum RegistrationStatus { initial, loading, success, failure }

class RegistrationState extends Equatable {
  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.user,
    this.failure,
  });
  final RegistrationStatus status;
  final AppUser? user;
  final Failure? failure;
  @override
  List<Object?> get props => [status, user, failure];
}

@injectable
class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._register) : super(const RegistrationState());
  final Register _register;

  Future<void> submit(String name, String email, String password) async {
    emit(const RegistrationState(status: RegistrationStatus.loading));
    try {
      final session = await _register(name, email, password);
      emit(
        RegistrationState(
          status: RegistrationStatus.success,
          user: session.user,
        ),
      );
    } catch (error) {
      emit(
        RegistrationState(
          status: RegistrationStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
