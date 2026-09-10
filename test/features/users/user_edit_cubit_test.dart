import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/set_user_active.dart';
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/update_user.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/user_edit_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockUpdateUser extends Mock implements UpdateUser {}

class MockSetActive extends Mock implements SetUserActive {}

void main() {
  blocTest<UserEditCubit, UserEditState>(
    'updates a user',
    build: () {
      final update = MockUpdateUser();
      when(
        () => update(
          'admin-1',
          'Admin User',
          'admin@example.com',
          UserRole.admin,
        ),
      ).thenAnswer((_) async => adminUser);
      return UserEditCubit(update, MockSetActive());
    },
    act: (cubit) => cubit.update(
      'admin-1',
      'Admin User',
      'admin@example.com',
      UserRole.admin,
    ),
    expect: () => const [
      UserEditState(status: UserEditStatus.loading),
      UserEditState(status: UserEditStatus.success, user: adminUser),
    ],
  );

  blocTest<UserEditCubit, UserEditState>(
    'changes active status',
    build: () {
      final active = MockSetActive();
      when(
        () => active('admin-1', false),
      ).thenAnswer((_) async => adminUser.copyWith(isActive: false));
      return UserEditCubit(MockUpdateUser(), active);
    },
    act: (cubit) => cubit.setActive('admin-1', false),
    verify: (cubit) => expect(cubit.state.user?.isActive, isFalse),
  );
}
