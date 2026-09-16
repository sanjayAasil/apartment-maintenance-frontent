import 'package:apartment_maintenance_frontent/app/theme/app_colors.dart';
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
      if (RouteAccess.canViewDashboard(user))
        const _Destination('Dashboard', Icons.dashboard_outlined, '/dashboard')
      else
        const _Destination('Overview', Icons.dashboard_outlined, '/'),
      const _Destination('Apartments', Icons.apartment_outlined, '/apartments'),
      if (RouteAccess.canManageResidents(user))
        const _Destination('Residents', Icons.badge_outlined, '/residents'),
      if (RouteAccess.canViewMaintenanceRequests(user))
        _Destination(
          user.role == UserRole.resident
              ? 'My Requests'
              : user.role == UserRole.technician
              ? 'My Jobs'
              : 'Requests',
          Icons.build_circle_outlined,
          user.role == UserRole.technician
              ? '/technician/jobs'
              : '/maintenance-requests',
        ),
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
      if (RouteAccess.canManageParts(user))
        const _Destination('Parts', Icons.inventory_2_outlined, '/parts'),
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
      (item) => item.path == '/technician/jobs'
          ? location == item.path ||
                location.startsWith('/maintenance-requests/')
          : item.path == '/'
          ? location == '/'
          : location.startsWith(item.path),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selected < 0 ? 'Apartment Care' : destinations[selected].label,
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width >= 500)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      user.role.apiValue,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppTone.purple.background,
              foregroundColor: AppTone.purple.foreground,
              child: Text(
                user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(enabled: false, child: Text(user.email)),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: 18,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    const Text('Sign out'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: SafeArea(
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: AppLogo(),
                    ),
                    const Divider(),
                    ...destinations.indexed.map(
                      (entry) => ListTile(
                        selected: selected == entry.$1,
                        selectedColor: AppColors.primary,
                        selectedTileColor: AppTone.blue.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
            SizedBox(
              width: 240,
              child: Material(
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 8,
                      ),
                      child: AppLogo(),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: Text(
                        'WORKSPACE',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...destinations.indexed.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          selected: entry.$1 == selected,
                          selectedColor: AppColors.primary,
                          selectedTileColor: AppTone.blue.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          leading: Icon(entry.$2.icon, size: 21),
                          title: Text(
                            entry.$2.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: entry.$1 == selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          onTap: () => context.go(entry.$2.path),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
