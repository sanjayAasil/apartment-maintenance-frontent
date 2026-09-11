import 'package:apartment_maintenance_frontent/core/routing/route_access.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';

String? appRedirect(AuthState auth, Uri uri) {
  final path = uri.path;
  final public = path == '/login' || path == '/register';
  if (auth.status == AuthStatus.initial ||
      auth.status == AuthStatus.restoring) {
    return path == '/startup'
        ? null
        : _withDestination('/startup', uri.toString());
  }
  if (!auth.isAuthenticated) {
    if (path == '/startup') {
      final destination = _safeDestination(uri.queryParameters['from']);
      if (destination == null) return '/login';
      final destinationPath = Uri.parse(destination).path;
      if (destinationPath == '/login' || destinationPath == '/register') {
        return destination;
      }
      return _withDestination('/login', destination);
    }
    if (public) return null;
    return _withDestination('/login', uri.toString());
  }
  if (path == '/startup' || public) {
    return _safeDestination(uri.queryParameters['from']) ?? '/';
  }
  if (path.startsWith('/users') && !RouteAccess.canManageUsers(auth.user)) {
    return '/forbidden';
  }
  final isApartmentMutation =
      path == '/apartments/new' ||
      (path.startsWith('/apartments/') && path.endsWith('/edit'));
  if (isApartmentMutation && !RouteAccess.canManageApartments(auth.user)) {
    return '/forbidden';
  }
  if (path.startsWith('/residents') &&
      !RouteAccess.canManageResidents(auth.user)) {
    return '/forbidden';
  }
  if (path == '/resident/profile' &&
      !RouteAccess.canViewOwnResidentProfile(auth.user)) {
    return '/forbidden';
  }
  return null;
}

String _withDestination(String path, String destination) =>
    Uri(path: path, queryParameters: {'from': destination}).toString();

String? _safeDestination(String? value) =>
    value != null && value.startsWith('/') && !value.startsWith('//')
    ? value
    : null;
