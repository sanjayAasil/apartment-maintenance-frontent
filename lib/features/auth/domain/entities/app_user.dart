import 'package:equatable/equatable.dart';

enum UserRole {
  admin('ADMIN'),
  resident('RESIDENT'),
  technician('TECHNICIAN');

  const UserRole(this.apiValue);
  final String apiValue;

  static UserRole fromApi(String value) => UserRole.values.firstWhere(
    (role) => role.apiValue == value.toUpperCase(),
    orElse: () => throw FormatException('Unknown user role: $value'),
  );
}

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
  }) => AppUser(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];
}
