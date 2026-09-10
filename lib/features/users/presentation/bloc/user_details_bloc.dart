import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

sealed class UserDetailsEvent extends Equatable {
  const UserDetailsEvent();
  @override
  List<Object?> get props => [];
}

final class UserDetailsRequested extends UserDetailsEvent {
  const UserDetailsRequested(this.id);
  final String id;
  @override
  List<Object> get props => [id];
}

enum UserDetailsStatus { initial, loading, success, failure }

class UserDetailsState extends Equatable {
  const UserDetailsState({
    this.status = UserDetailsStatus.initial,
    this.user,
    this.failure,
  });
  final UserDetailsStatus status;
  final AppUser? user;
  final Failure? failure;
  @override
  List<Object?> get props => [status, user, failure];
}

@injectable
class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  UserDetailsBloc(this._getUser) : super(const UserDetailsState()) {
    on<UserDetailsRequested>((event, emit) async {
      emit(const UserDetailsState(status: UserDetailsStatus.loading));
      try {
        emit(
          UserDetailsState(
            status: UserDetailsStatus.success,
            user: await _getUser(event.id),
          ),
        );
      } catch (error) {
        emit(
          UserDetailsState(
            status: UserDetailsStatus.failure,
            failure: mapApiError(error),
          ),
        );
      }
    });
  }
  final GetUser _getUser;
}
