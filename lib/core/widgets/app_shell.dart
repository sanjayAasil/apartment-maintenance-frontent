import 'package:apartment_maintenance_frontent/core/routing/route_access.dart';
import 'package:apartment_maintenance_frontent/core/widgets/app_logo.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final location = GoRouterState.of(context).uri.path;
    final user = context.select((AuthBloc bloc) => bloc.state.user);

    // The auth state is cleared before GoRouter completes its redirect to the
    // login page. Avoid building protected shell content during that frame.
    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final destinations = <_Destination>[
      const _Destination('Overview', Icons.dashboard_outlined, '/'),
      const _Destination('Apartments', Icons.apartment_outlined, '/apartments'),
      if (RouteAccess.canManageResidents(user))
        const _Destination('Residents', Icons.badge_outlined, '/residents'),
      if (RouteAccess.canManageMaintenanceCategories(user))
        const _Destination(
          'Categories',
          Icons.home_repair_service_outlined,
          '/maintenance-categories',
        ),
      if (RouteAccess.canManageTechnicians(user))
        const _Destination(
          'Technicians',
          Icons.engineering_outlined,
          '/technicians',
        ),
      if (RouteAccess.canViewMaintenanceRequests(user))
        _Destination(
          user.role == UserRole.resident ? 'My Requests' : 'Requests',
          Icons.build_circle_outlined,
          '/maintenance-requests',
        ),
      if (RouteAccess.canViewOwnResidentProfile(user))
        const _Destination(
          'My Apartment',
          Icons.home_outlined,
          '/resident/profile',
        ),
      if (RouteAccess.canViewOwnTechnicianProfile(user))
        const _Destination(
          'My Profile',
          Icons.engineering_outlined,
          '/technician/profile',
        ),
      if (RouteAccess.canManageUsers(user))
        const _Destination('Users', Icons.people_outline, '/users'),
    ];
    final selected = destinations.indexWhere(
      (item) =>
          item.path == '/' ? location == '/' : location.startsWith(item.path),
    );

    return Scaffold(
      appBar: AppBar(
        title: wide ? null : const AppLogo(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text(user.name)),
          ),
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(enabled: false, child: Text(user.email)),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: AppLogo(),
                    ),
                    const Divider(),
                    ...destinations.indexed.map(
                      (entry) => ListTile(
                        selected: selected == entry.$1,
                        leading: Icon(entry.$2.icon),
                        title: Text(entry.$2.label),
                        onTap: () {
                          Navigator.pop(context);
                          context.go(entry.$2.path);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1180,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: AppLogo(compact: true),
              ),
              selectedIndex: selected < 0 ? 0 : selected,
              onDestinationSelected: (index) =>
                  context.go(destinations[index].path),
              destinations: destinations
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
            ),
          if (wide) const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}
