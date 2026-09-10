import 'package:apartment_maintenance_frontent/core/routing/app_redirector.dart';
import 'package:apartment_maintenance_frontent/core/routing/router_refresh_notifier.dart';
import 'package:apartment_maintenance_frontent/core/widgets/app_shell.dart';
import 'package:apartment_maintenance_frontent/core/widgets/info_pages.dart';
import 'package:apartment_maintenance_frontent/features/apartments/presentation/pages/apartment_form_page.dart';
import 'package:apartment_maintenance_frontent/features/apartments/presentation/pages/apartments_page.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/pages/login_page.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/pages/register_page.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/pages/user_details_page.dart';
import 'package:apartment_maintenance_frontent/features/users/presentation/pages/users_page.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthBloc authBloc) {
  final refresh = RouterRefreshNotifier(authBloc.stream);
  return GoRouter(
    initialLocation: '/startup',
    refreshListenable: refresh,
    redirect: (context, state) => appRedirect(authBloc.state, state.uri),
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(
        path: '/startup',
        builder: (context, state) => const StartupPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const ForbiddenPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
          ),
          GoRoute(
            path: '/users/:id',
            builder: (context, state) =>
                UserDetailsPage(userId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/apartments',
            builder: (context, state) => const ApartmentsPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ApartmentFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (context, state) =>
                    ApartmentFormPage(apartmentId: state.pathParameters['id']),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
