import 'package:apartment_maintenance_frontent/app/router/app_router.dart';
import 'package:apartment_maintenance_frontent/app/theme/app_theme.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApartmentMaintenanceApp extends StatefulWidget {
  const ApartmentMaintenanceApp({required this.authBloc, super.key});
  final AuthBloc authBloc;
  @override
  State<ApartmentMaintenanceApp> createState() =>
      _ApartmentMaintenanceAppState();
}

class _ApartmentMaintenanceAppState extends State<ApartmentMaintenanceApp> {
  late final router = createRouter(widget.authBloc);
  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: widget.authBloc,
    child: MaterialApp.router(
      title: 'Apartment Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}
