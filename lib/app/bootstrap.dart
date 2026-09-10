import 'package:apartment_maintenance_frontent/app/app.dart';
import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await configureDependencies();
  final authBloc = getIt<AuthBloc>()..add(const AuthRestoreRequested());
  runApp(ApartmentMaintenanceApp(authBloc: authBloc));
}
