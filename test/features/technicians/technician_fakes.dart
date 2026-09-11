import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/entities/technician_skill.dart';

const technicianUser = AppUser(
  id: 'user-1',
  name: 'Tara Technician',
  email: 'tara@example.com',
  role: UserRole.technician,
  isActive: true,
);
const technicianCategory = MaintenanceCategory(
  id: 'category-1',
  name: 'Plumbing',
  isActive: true,
);
const technicianSkill = TechnicianSkill(
  id: 'skill-1',
  technicianId: 'technician-1',
  categoryId: 'category-1',
  category: technicianCategory,
);
const technician = Technician(
  id: 'technician-1',
  userId: 'user-1',
  phone: '9876543210',
  experienceYears: 3,
  isAvailable: true,
  isActive: true,
  user: technicianUser,
  skills: [technicianSkill],
);

Map<String, dynamic> get technicianJson => {
  'id': 'technician-1',
  'userId': 'user-1',
  'phone': '9876543210',
  'experienceYears': 3,
  'isAvailable': true,
  'isActive': true,
  'createdAt': '2026-09-01T00:00:00.000Z',
  'updatedAt': '2026-09-01T00:00:00.000Z',
  'user': {
    'id': 'user-1',
    'name': 'Tara Technician',
    'email': 'tara@example.com',
    'role': 'TECHNICIAN',
    'isActive': true,
  },
  'skills': [skillJson],
};

Map<String, dynamic> get skillJson => {
  'id': 'skill-1',
  'technicianId': 'technician-1',
  'categoryId': 'category-1',
  'createdAt': '2026-09-01T00:00:00.000Z',
  'category': {
    'id': 'category-1',
    'name': 'Plumbing',
    'description': null,
    'isActive': true,
  },
};
