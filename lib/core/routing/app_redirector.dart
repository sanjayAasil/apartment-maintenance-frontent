import 'package:apartment_maintenance_frontent/core/routing/route_access.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';

String? appRedirect(AuthState auth, Uri uri) {
  final path = uri.path;
  final public = path == '/login' || path == '/register';
  if (auth.status == AuthStatus.initial ||
      auth.status == AuthStatus.restoring) {
    return path == '/startup' ? null : '/startup';
  }
  if (!auth.isAuthenticated) {
    if (public) return null;
    return '/login?from=${Uri.encodeComponent(uri.toString())}';
  }
  if (path == '/startup' || public) {
    final from = uri.queryParameters['from'];
    return from != null && from.startsWith('/') ? from : '/';
  }
  if (path.startsWith('/users') && !RouteAccess.canManageUsers(auth.user)) {
    return '/forbidden';
  }
  return null;
}
