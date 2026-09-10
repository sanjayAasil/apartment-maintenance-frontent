import 'package:apartment_maintenance_frontent/core/error/api_error_mapper.dart';
import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/set_user_active.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/update_user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

enum UserEditStatus { initial, loading, success, failure }

class UserEditState extends Equatable {
  const UserEditState({
    this.status = UserEditStatus.initial,
    this.user,
    this.failure,
  });
  final UserEditStatus status;
  final AppUser? user;
  final Failure? failure;
  @override
  List<Object?> get props => [status, user, failure];
}

@injectable
class UserEditCubit extends Cubit<UserEditState> {
  UserEditCubit(this._updateUser, this._setActive)
    : super(const UserEditState());
  final UpdateUser _updateUser;
  final SetUserActive _setActive;

  Future<void> update(
    String id,
    String name,
    String email,
    UserRole role,
  ) async {
    emit(const UserEditState(status: UserEditStatus.loading));
    try {
      emit(
        UserEditState(
          status: UserEditStatus.success,
          user: await _updateUser(id, name, email, role),
        ),
      );
    } catch (error) {
      emit(
        UserEditState(
          status: UserEditStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }

  Future<void> setActive(String id, bool isActive) async {
    emit(const UserEditState(status: UserEditStatus.loading));
    try {
      emit(
        UserEditState(
          status: UserEditStatus.success,
          user: await _setActive(id, isActive),
        ),
      );
    } catch (error) {
      emit(
        UserEditState(
          status: UserEditStatus.failure,
          failure: mapApiError(error),
        ),
      );
    }
  }
}
