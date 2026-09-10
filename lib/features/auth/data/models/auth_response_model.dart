import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/data/models/user_model.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/auth_session.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.accessToken, required this.user});
  factory AuthResponseModel.fromJson(Map<String, dynamic> source) {
    final json = source['data'] is Map<String, dynamic>
        ? source['data'] as Map<String, dynamic>
        : source;
    final token = json['accessToken'] ?? json['access_token'] ?? json['token'];
    final user = json['user'];
    if (token is! String || token.isEmpty || user is! Map) {
      throw const Failure(
        kind: FailureKind.malformedResponse,
        message: 'The authentication response has an unexpected format.',
      );
    }
    return AuthResponseModel(
      accessToken: token,
      user: UserModel.fromJson(Map<String, dynamic>.from(user)),
    );
  }

  final String accessToken;
  final UserModel user;

  AuthSession toEntity() =>
      AuthSession(accessToken: accessToken, user: user.toEntity());
}
