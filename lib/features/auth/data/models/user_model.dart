import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  AppUser toEntity() => AppUser(
    id: id,
    name: name,
    email: email,
    role: UserRole.fromApi(role),
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
