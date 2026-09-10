// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:apartment_maintenance_frontent/app/di/register_module.dart'
    as _i1014;
import 'package:apartment_maintenance_frontent/core/config/app_config.dart'
    as _i906;
import 'package:apartment_maintenance_frontent/core/network/auth_interceptor.dart'
    as _i352;
import 'package:apartment_maintenance_frontent/core/network/dio_client.dart'
    as _i808;
import 'package:apartment_maintenance_frontent/core/network/session_coordinator.dart'
    as _i696;
import 'package:apartment_maintenance_frontent/core/storage/browser_token_storage.dart'
    as _i106;
import 'package:apartment_maintenance_frontent/core/storage/token_storage.dart'
    as _i747;
import 'package:apartment_maintenance_frontent/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i838;
import 'package:apartment_maintenance_frontent/features/auth/data/repositories/auth_repository_impl.dart'
    as _i384;
import 'package:apartment_maintenance_frontent/features/auth/domain/repositories/auth_repository.dart'
    as _i1059;
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/login.dart'
    as _i930;
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/logout.dart'
    as _i1007;
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/register.dart'
    as _i140;
import 'package:apartment_maintenance_frontent/features/auth/domain/usecases/restore_session.dart'
    as _i203;
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart'
    as _i925;
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/registration_cubit.dart'
    as _i478;
import 'package:apartment_maintenance_frontent/features/users/data/datasources/users_remote_data_source.dart'
    as _i321;
import 'package:apartment_maintenance_frontent/features/users/data/repositories/users_repository_impl.dart'
    as _i243;
import 'package:apartment_maintenance_frontent/features/users/domain/repositories/users_repository.dart'
    as _i846;
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_user.dart'
    as _i865;
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/get_users.dart'
    as _i596;
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/set_user_active.dart'
    as _i940;
import 'package:apartment_maintenance_frontent/features/users/domain/usecases/update_user.dart'
    as _i800;
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/user_details_bloc.dart'
    as _i796;
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/user_edit_cubit.dart'
    as _i799;
import 'package:apartment_maintenance_frontent/features/users/presentation/bloc/users_list_bloc.dart'
    as _i483;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final dioModule = _$DioModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.preferences,
      preResolve: true,
    );
    gh.singleton<_i906.AppConfig>(() => registerModule.appConfig);
    gh.lazySingleton<_i747.TokenStorage>(
      () => _i106.BrowserTokenStorage(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i696.SessionCoordinator>(
      () => _i696.SessionCoordinator(gh<_i747.TokenStorage>()),
    );
    gh.factory<_i352.AuthInterceptor>(
      () => _i352.AuthInterceptor(
        gh<_i747.TokenStorage>(),
        gh<_i696.SessionCoordinator>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => dioModule.dio(gh<_i906.AppConfig>(), gh<_i352.AuthInterceptor>()),
    );
    gh.lazySingleton<_i838.AuthRemoteDataSource>(
      () => _i838.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i321.UsersRemoteDataSource>(
      () => _i321.UsersRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i846.UsersRepository>(
      () => _i243.UsersRepositoryImpl(gh<_i321.UsersRemoteDataSource>()),
    );
    gh.lazySingleton<_i1059.AuthRepository>(
      () => _i384.AuthRepositoryImpl(
        gh<_i838.AuthRemoteDataSource>(),
        gh<_i747.TokenStorage>(),
        gh<_i696.SessionCoordinator>(),
      ),
    );
    gh.factory<_i865.GetUser>(() => _i865.GetUser(gh<_i846.UsersRepository>()));
    gh.factory<_i596.GetUsers>(
      () => _i596.GetUsers(gh<_i846.UsersRepository>()),
    );
    gh.factory<_i940.SetUserActive>(
      () => _i940.SetUserActive(gh<_i846.UsersRepository>()),
    );
    gh.factory<_i800.UpdateUser>(
      () => _i800.UpdateUser(gh<_i846.UsersRepository>()),
    );
    gh.factory<_i796.UserDetailsBloc>(
      () => _i796.UserDetailsBloc(gh<_i865.GetUser>()),
    );
    gh.factory<_i930.Login>(() => _i930.Login(gh<_i1059.AuthRepository>()));
    gh.factory<_i1007.Logout>(() => _i1007.Logout(gh<_i1059.AuthRepository>()));
    gh.factory<_i140.Register>(
      () => _i140.Register(gh<_i1059.AuthRepository>()),
    );
    gh.factory<_i203.RestoreSession>(
      () => _i203.RestoreSession(gh<_i1059.AuthRepository>()),
    );
    gh.lazySingleton<_i925.AuthBloc>(
      () => _i925.AuthBloc(
        gh<_i930.Login>(),
        gh<_i203.RestoreSession>(),
        gh<_i1007.Logout>(),
        gh<_i696.SessionCoordinator>(),
      ),
    );
    gh.factory<_i799.UserEditCubit>(
      () => _i799.UserEditCubit(
        gh<_i800.UpdateUser>(),
        gh<_i940.SetUserActive>(),
      ),
    );
    gh.factory<_i483.UsersListBloc>(
      () => _i483.UsersListBloc(gh<_i596.GetUsers>()),
    );
    gh.factory<_i478.RegistrationCubit>(
      () => _i478.RegistrationCubit(gh<_i140.Register>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i1014.RegisterModule {}

class _$DioModule extends _i808.DioModule {}
