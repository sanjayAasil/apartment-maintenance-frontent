import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.accessToken, required this.user});
  final String accessToken;
  final AppUser user;

  @override
  List<Object> get props => [accessToken, user];
}
