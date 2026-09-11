import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';

const requestUser = AppUser(
  id: 'user-1',
  name: 'Riya Resident',
  email: 'riya@example.com',
  role: UserRole.resident,
  isActive: true,
);
const requestResident = MaintenanceRequestResident(
  id: 'resident-1',
  userId: 'user-1',
  phone: '9876543210',
  isActive: true,
  user: requestUser,
);
const requestApartment = Apartment(
  id: 'apartment-1',
  block: 'A',
  floor: 2,
  unitNumber: '204',
);
const requestCategory = MaintenanceCategory(
  id: 'category-1',
  name: 'Plumbing',
  description: 'Water issues',
  isActive: true,
);

MaintenanceRequest get maintenanceRequest => MaintenanceRequest(
  id: 'request-1',
  residentId: 'resident-1',
  apartmentId: 'apartment-1',
  categoryId: 'category-1',
  title: 'Leaking kitchen tap',
  description: 'The kitchen tap is leaking continuously.',
  priority: MaintenancePriority.medium,
  status: MaintenanceRequestStatus.open,
  createdAt: DateTime.utc(2026, 9),
  updatedAt: DateTime.utc(2026, 9),
  resident: requestResident,
  apartment: requestApartment,
  category: requestCategory,
);

Map<String, dynamic> get maintenanceRequestJson => {
  'id': 'request-1',
  'residentId': 'resident-1',
  'apartmentId': 'apartment-1',
  'categoryId': 'category-1',
  'title': 'Leaking kitchen tap',
  'description': 'The kitchen tap is leaking continuously.',
  'priority': 'MEDIUM',
  'status': 'OPEN',
  'createdAt': '2026-09-01T00:00:00.000Z',
  'updatedAt': '2026-09-01T00:00:00.000Z',
  'resolvedAt': null,
  'closedAt': null,
  'resident': {
    'id': 'resident-1',
    'userId': 'user-1',
    'phone': '9876543210',
    'isActive': true,
    'user': {
      'id': 'user-1',
      'name': 'Riya Resident',
      'email': 'riya@example.com',
      'role': 'RESIDENT',
      'isActive': true,
      'createdAt': '2026-09-01T00:00:00.000Z',
      'updatedAt': '2026-09-01T00:00:00.000Z',
    },
  },
  'apartment': {
    'id': 'apartment-1',
    'block': 'A',
    'floor': 2,
    'unitNumber': '204',
    'createdAt': '2026-09-01T00:00:00.000Z',
    'updatedAt': '2026-09-01T00:00:00.000Z',
  },
  'category': {
    'id': 'category-1',
    'name': 'Plumbing',
    'description': 'Water issues',
    'isActive': true,
    'createdAt': '2026-09-01T00:00:00.000Z',
    'updatedAt': '2026-09-01T00:00:00.000Z',
  },
};
