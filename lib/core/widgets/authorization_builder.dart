import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:flutter/widgets.dart';

class AuthorizationBuilder extends StatelessWidget {
  const AuthorizationBuilder({
    required this.user,
    required this.roles,
    required this.child,
    this.fallback = const SizedBox.shrink(),
    super.key,
  });
  final AppUser user;
  final Set<UserRole> roles;
  final Widget child;
  final Widget fallback;
  @override
  Widget build(BuildContext context) =>
      roles.contains(user.role) ? child : fallback;
}
