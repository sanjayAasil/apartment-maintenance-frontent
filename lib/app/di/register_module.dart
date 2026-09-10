import 'package:apartment_maintenance_frontent/core/config/app_config.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  @singleton
  AppConfig get appConfig => AppConfig.fromEnvironment();

  @preResolve
  Future<SharedPreferences> get preferences => SharedPreferences.getInstance();
}
