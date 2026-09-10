import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';

const adminUser = AppUser(
  id: 'admin-1',
  name: 'Admin User',
  email: 'admin@example.com',
  role: UserRole.admin,
  isActive: true,
);

const residentUser = AppUser(
  id: 'resident-1',
  name: 'Resident User',
  email: 'resident@example.com',
  role: UserRole.resident,
  isActive: true,
);
