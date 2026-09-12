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
import 'package:apartment_maintenance_frontent/features/apartments/data/datasources/apartments_remote_data_source.dart'
    as _i147;
import 'package:apartment_maintenance_frontent/features/apartments/data/repositories/apartments_repository_impl.dart'
    as _i381;
import 'package:apartment_maintenance_frontent/features/apartments/domain/repositories/apartments_repository.dart'
    as _i779;
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/create_apartment.dart'
    as _i580;
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartment.dart'
    as _i557;
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/get_apartments.dart'
    as _i443;
import 'package:apartment_maintenance_frontent/features/apartments/domain/usecases/update_apartment.dart'
    as _i647;
import 'package:apartment_maintenance_frontent/features/apartments/presentation/bloc/apartment_form_cubit.dart'
    as _i345;
import 'package:apartment_maintenance_frontent/features/apartments/presentation/bloc/apartments_list_bloc.dart'
    as _i874;
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
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/datasources/maintenance_categories_remote_data_source.dart'
    as _i809;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/data/repositories/maintenance_categories_repository_impl.dart'
    as _i818;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/repositories/maintenance_categories_repository.dart'
    as _i295;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/create_maintenance_category.dart'
    as _i299;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart'
    as _i99;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_category.dart'
    as _i102;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category.dart'
    as _i640;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category_status.dart'
    as _i1010;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_categories_list_bloc.dart'
    as _i140;
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_category_form_cubit.dart'
    as _i333;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/datasources/maintenance_requests_remote_data_source.dart'
    as _i152;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/repositories/maintenance_requests_repository_impl.dart'
    as _i212;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/repositories/maintenance_requests_repository.dart'
    as _i1061;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/add_maintenance_comment.dart'
    as _i996;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/assign_technician.dart'
    as _i215;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/create_maintenance_request.dart'
    as _i186;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_assignment_history.dart'
    as _i838;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_current_assignment.dart'
    as _i674;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_comments.dart'
    as _i703;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_history.dart'
    as _i446;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_request.dart'
    as _i230;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_requests.dart'
    as _i376;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/reassign_technician.dart'
    as _i434;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/unassign_technician.dart'
    as _i27;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request.dart'
    as _i301;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request_status.dart'
    as _i628;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_assignment_cubit.dart'
    as _i130;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_comments_cubit.dart'
    as _i435;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_history_cubit.dart'
    as _i1018;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_details_bloc.dart'
    as _i1036;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_form_cubit.dart'
    as _i466;
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_requests_list_bloc.dart'
    as _i469;
import 'package:apartment_maintenance_frontent/features/residents/data/datasources/residents_remote_data_source.dart'
    as _i370;
import 'package:apartment_maintenance_frontent/features/residents/data/repositories/residents_repository_impl.dart'
    as _i284;
import 'package:apartment_maintenance_frontent/features/residents/domain/repositories/residents_repository.dart'
    as _i985;
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/change_resident_apartment.dart'
    as _i1024;
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/create_resident.dart'
    as _i617;
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_current_resident.dart'
    as _i673;
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_resident.dart'
    as _i800;
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/get_residents.dart'
    as _i792;
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/update_resident.dart'
    as _i536;
import 'package:apartment_maintenance_frontent/features/residents/domain/usecases/update_resident_status.dart'
    as _i115;
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/current_resident_bloc.dart'
    as _i766;
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_details_bloc.dart'
    as _i734;
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/resident_mutation_cubit.dart'
    as _i933;
import 'package:apartment_maintenance_frontent/features/residents/presentation/bloc/residents_list_bloc.dart'
    as _i487;
import 'package:apartment_maintenance_frontent/features/technicians/data/datasources/technicians_remote_data_source.dart'
    as _i23;
import 'package:apartment_maintenance_frontent/features/technicians/data/repositories/technicians_repository_impl.dart'
    as _i653;
import 'package:apartment_maintenance_frontent/features/technicians/domain/repositories/technicians_repository.dart'
    as _i704;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/add_technician_skill.dart'
    as _i52;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/create_technician.dart'
    as _i750;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_available_technicians.dart'
    as _i298;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_current_technician.dart'
    as _i720;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_technician.dart'
    as _i1046;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_technician_skills.dart'
    as _i852;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_technicians.dart'
    as _i201;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/remove_technician_skill.dart'
    as _i663;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician.dart'
    as _i554;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_availability.dart'
    as _i1056;
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/update_technician_status.dart'
    as _i972;
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/current_technician_cubit.dart'
    as _i659;
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_details_bloc.dart'
    as _i161;
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technician_mutation_cubit.dart'
    as _i464;
import 'package:apartment_maintenance_frontent/features/technicians/presentation/bloc/technicians_list_bloc.dart'
    as _i567;
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
    gh.lazySingleton<_i152.MaintenanceRequestsRemoteDataSource>(
      () => _i152.MaintenanceRequestsRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i809.MaintenanceCategoriesRemoteDataSource>(
      () => _i809.MaintenanceCategoriesRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i370.ResidentsRemoteDataSource>(
      () => _i370.ResidentsRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i321.UsersRemoteDataSource>(
      () => _i321.UsersRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i23.TechniciansRemoteDataSource>(
      () => _i23.TechniciansRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i147.ApartmentsRemoteDataSource>(
      () => _i147.ApartmentsRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i985.ResidentsRepository>(
      () =>
          _i284.ResidentsRepositoryImpl(gh<_i370.ResidentsRemoteDataSource>()),
    );
    gh.lazySingleton<_i846.UsersRepository>(
      () => _i243.UsersRepositoryImpl(gh<_i321.UsersRemoteDataSource>()),
    );
    gh.lazySingleton<_i1061.MaintenanceRequestsRepository>(
      () => _i212.MaintenanceRequestsRepositoryImpl(
        gh<_i152.MaintenanceRequestsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i295.MaintenanceCategoriesRepository>(
      () => _i818.MaintenanceCategoriesRepositoryImpl(
        gh<_i809.MaintenanceCategoriesRemoteDataSource>(),
      ),
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
    gh.lazySingleton<_i779.ApartmentsRepository>(
      () => _i381.ApartmentsRepositoryImpl(
        gh<_i147.ApartmentsRemoteDataSource>(),
      ),
    );
    gh.factory<_i1024.ChangeResidentApartment>(
      () => _i1024.ChangeResidentApartment(gh<_i985.ResidentsRepository>()),
    );
    gh.factory<_i617.CreateResident>(
      () => _i617.CreateResident(gh<_i985.ResidentsRepository>()),
    );
    gh.factory<_i673.GetCurrentResident>(
      () => _i673.GetCurrentResident(gh<_i985.ResidentsRepository>()),
    );
    gh.factory<_i800.GetResident>(
      () => _i800.GetResident(gh<_i985.ResidentsRepository>()),
    );
    gh.factory<_i792.GetResidents>(
      () => _i792.GetResidents(gh<_i985.ResidentsRepository>()),
    );
    gh.factory<_i536.UpdateResident>(
      () => _i536.UpdateResident(gh<_i985.ResidentsRepository>()),
    );
    gh.factory<_i115.UpdateResidentStatus>(
      () => _i115.UpdateResidentStatus(gh<_i985.ResidentsRepository>()),
    );
    gh.factory<_i996.AddMaintenanceComment>(
      () => _i996.AddMaintenanceComment(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i215.AssignTechnician>(
      () => _i215.AssignTechnician(gh<_i1061.MaintenanceRequestsRepository>()),
    );
    gh.factory<_i186.CreateMaintenanceRequest>(
      () => _i186.CreateMaintenanceRequest(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i838.GetAssignmentHistory>(
      () => _i838.GetAssignmentHistory(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i674.GetCurrentAssignment>(
      () => _i674.GetCurrentAssignment(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i703.GetMaintenanceComments>(
      () => _i703.GetMaintenanceComments(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i446.GetMaintenanceHistory>(
      () => _i446.GetMaintenanceHistory(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i230.GetMaintenanceRequest>(
      () => _i230.GetMaintenanceRequest(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i376.GetMaintenanceRequests>(
      () => _i376.GetMaintenanceRequests(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i434.ReassignTechnician>(
      () =>
          _i434.ReassignTechnician(gh<_i1061.MaintenanceRequestsRepository>()),
    );
    gh.factory<_i27.UnassignTechnician>(
      () => _i27.UnassignTechnician(gh<_i1061.MaintenanceRequestsRepository>()),
    );
    gh.factory<_i301.UpdateMaintenanceRequest>(
      () => _i301.UpdateMaintenanceRequest(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.factory<_i628.UpdateMaintenanceRequestStatus>(
      () => _i628.UpdateMaintenanceRequestStatus(
        gh<_i1061.MaintenanceRequestsRepository>(),
      ),
    );
    gh.lazySingleton<_i704.TechniciansRepository>(
      () => _i653.TechniciansRepositoryImpl(
        gh<_i23.TechniciansRemoteDataSource>(),
      ),
    );
    gh.factory<_i435.MaintenanceCommentsCubit>(
      () => _i435.MaintenanceCommentsCubit(
        gh<_i703.GetMaintenanceComments>(),
        gh<_i996.AddMaintenanceComment>(),
      ),
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
    gh.factory<_i299.CreateMaintenanceCategory>(
      () => _i299.CreateMaintenanceCategory(
        gh<_i295.MaintenanceCategoriesRepository>(),
      ),
    );
    gh.factory<_i99.GetMaintenanceCategories>(
      () => _i99.GetMaintenanceCategories(
        gh<_i295.MaintenanceCategoriesRepository>(),
      ),
    );
    gh.factory<_i102.GetMaintenanceCategory>(
      () => _i102.GetMaintenanceCategory(
        gh<_i295.MaintenanceCategoriesRepository>(),
      ),
    );
    gh.factory<_i640.UpdateMaintenanceCategory>(
      () => _i640.UpdateMaintenanceCategory(
        gh<_i295.MaintenanceCategoriesRepository>(),
      ),
    );
    gh.factory<_i1010.UpdateMaintenanceCategoryStatus>(
      () => _i1010.UpdateMaintenanceCategoryStatus(
        gh<_i295.MaintenanceCategoriesRepository>(),
      ),
    );
    gh.factory<_i580.CreateApartment>(
      () => _i580.CreateApartment(gh<_i779.ApartmentsRepository>()),
    );
    gh.factory<_i557.GetApartment>(
      () => _i557.GetApartment(gh<_i779.ApartmentsRepository>()),
    );
    gh.factory<_i443.GetApartments>(
      () => _i443.GetApartments(gh<_i779.ApartmentsRepository>()),
    );
    gh.factory<_i647.UpdateApartment>(
      () => _i647.UpdateApartment(gh<_i779.ApartmentsRepository>()),
    );
    gh.factory<_i874.ApartmentsListBloc>(
      () => _i874.ApartmentsListBloc(gh<_i443.GetApartments>()),
    );
    gh.factory<_i487.ResidentsListBloc>(
      () => _i487.ResidentsListBloc(gh<_i792.GetResidents>()),
    );
    gh.factory<_i52.AddTechnicianSkill>(
      () => _i52.AddTechnicianSkill(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i750.CreateTechnician>(
      () => _i750.CreateTechnician(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i298.GetAvailableTechnicians>(
      () => _i298.GetAvailableTechnicians(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i720.GetCurrentTechnician>(
      () => _i720.GetCurrentTechnician(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i1046.GetTechnician>(
      () => _i1046.GetTechnician(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i852.GetTechnicianSkills>(
      () => _i852.GetTechnicianSkills(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i201.GetTechnicians>(
      () => _i201.GetTechnicians(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i663.RemoveTechnicianSkill>(
      () => _i663.RemoveTechnicianSkill(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i554.UpdateTechnician>(
      () => _i554.UpdateTechnician(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i1056.UpdateTechnicianAvailability>(
      () => _i1056.UpdateTechnicianAvailability(
        gh<_i704.TechniciansRepository>(),
      ),
    );
    gh.factory<_i972.UpdateTechnicianStatus>(
      () => _i972.UpdateTechnicianStatus(gh<_i704.TechniciansRepository>()),
    );
    gh.factory<_i161.TechnicianDetailsBloc>(
      () => _i161.TechnicianDetailsBloc(gh<_i1046.GetTechnician>()),
    );
    gh.factory<_i130.MaintenanceAssignmentCubit>(
      () => _i130.MaintenanceAssignmentCubit(
        gh<_i298.GetAvailableTechnicians>(),
        gh<_i838.GetAssignmentHistory>(),
        gh<_i215.AssignTechnician>(),
        gh<_i434.ReassignTechnician>(),
        gh<_i27.UnassignTechnician>(),
      ),
    );
    gh.lazySingleton<_i925.AuthBloc>(
      () => _i925.AuthBloc(
        gh<_i930.Login>(),
        gh<_i203.RestoreSession>(),
        gh<_i1007.Logout>(),
        gh<_i696.SessionCoordinator>(),
      ),
    );
    gh.factory<_i567.TechniciansListBloc>(
      () => _i567.TechniciansListBloc(gh<_i201.GetTechnicians>()),
    );
    gh.factory<_i659.CurrentTechnicianCubit>(
      () => _i659.CurrentTechnicianCubit(
        gh<_i720.GetCurrentTechnician>(),
        gh<_i1056.UpdateTechnicianAvailability>(),
      ),
    );
    gh.factory<_i140.MaintenanceCategoriesListBloc>(
      () => _i140.MaintenanceCategoriesListBloc(
        gh<_i99.GetMaintenanceCategories>(),
      ),
    );
    gh.factory<_i799.UserEditCubit>(
      () => _i799.UserEditCubit(
        gh<_i800.UpdateUser>(),
        gh<_i940.SetUserActive>(),
      ),
    );
    gh.factory<_i464.TechnicianMutationCubit>(
      () => _i464.TechnicianMutationCubit(
        gh<_i596.GetUsers>(),
        gh<_i99.GetMaintenanceCategories>(),
        gh<_i750.CreateTechnician>(),
        gh<_i554.UpdateTechnician>(),
        gh<_i972.UpdateTechnicianStatus>(),
        gh<_i1056.UpdateTechnicianAvailability>(),
        gh<_i52.AddTechnicianSkill>(),
        gh<_i663.RemoveTechnicianSkill>(),
      ),
    );
    gh.factory<_i1018.MaintenanceHistoryCubit>(
      () => _i1018.MaintenanceHistoryCubit(gh<_i446.GetMaintenanceHistory>()),
    );
    gh.factory<_i466.MaintenanceRequestFormCubit>(
      () => _i466.MaintenanceRequestFormCubit(
        gh<_i230.GetMaintenanceRequest>(),
        gh<_i99.GetMaintenanceCategories>(),
        gh<_i186.CreateMaintenanceRequest>(),
        gh<_i301.UpdateMaintenanceRequest>(),
        gh<_i628.UpdateMaintenanceRequestStatus>(),
      ),
    );
    gh.factory<_i483.UsersListBloc>(
      () => _i483.UsersListBloc(gh<_i596.GetUsers>()),
    );
    gh.factory<_i469.MaintenanceRequestsListBloc>(
      () =>
          _i469.MaintenanceRequestsListBloc(gh<_i376.GetMaintenanceRequests>()),
    );
    gh.factory<_i734.ResidentDetailsBloc>(
      () => _i734.ResidentDetailsBloc(gh<_i800.GetResident>()),
    );
    gh.factory<_i933.ResidentMutationCubit>(
      () => _i933.ResidentMutationCubit(
        gh<_i596.GetUsers>(),
        gh<_i443.GetApartments>(),
        gh<_i617.CreateResident>(),
        gh<_i536.UpdateResident>(),
        gh<_i1024.ChangeResidentApartment>(),
        gh<_i115.UpdateResidentStatus>(),
      ),
    );
    gh.factory<_i1036.MaintenanceRequestDetailsBloc>(
      () => _i1036.MaintenanceRequestDetailsBloc(
        gh<_i230.GetMaintenanceRequest>(),
      ),
    );
    gh.factory<_i766.CurrentResidentBloc>(
      () => _i766.CurrentResidentBloc(gh<_i673.GetCurrentResident>()),
    );
    gh.factory<_i345.ApartmentFormCubit>(
      () => _i345.ApartmentFormCubit(
        gh<_i557.GetApartment>(),
        gh<_i580.CreateApartment>(),
        gh<_i647.UpdateApartment>(),
      ),
    );
    gh.factory<_i478.RegistrationCubit>(
      () => _i478.RegistrationCubit(gh<_i140.Register>()),
    );
    gh.factory<_i333.MaintenanceCategoryFormCubit>(
      () => _i333.MaintenanceCategoryFormCubit(
        gh<_i102.GetMaintenanceCategory>(),
        gh<_i299.CreateMaintenanceCategory>(),
        gh<_i640.UpdateMaintenanceCategory>(),
        gh<_i1010.UpdateMaintenanceCategoryStatus>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i1014.RegisterModule {}

class _$DioModule extends _i808.DioModule {}
