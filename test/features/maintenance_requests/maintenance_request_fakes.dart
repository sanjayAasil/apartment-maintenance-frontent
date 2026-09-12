import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';

import '../../helpers/fakes.dart';
import '../technicians/technician_fakes.dart';

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

MaintenanceAssignment get maintenanceAssignment => MaintenanceAssignment(
  id: 'assignment-1',
  maintenanceRequestId: 'request-1',
  technicianId: technician.id,
  assignedByUserId: adminUser.id,
  assignedAt: DateTime.utc(2026, 9, 2, 10, 30),
  isActive: true,
  technician: technician,
  assignedBy: adminUser,
);

MaintenanceRequest get assignedMaintenanceRequest => MaintenanceRequest(
  id: 'request-1',
  residentId: 'resident-1',
  apartmentId: 'apartment-1',
  categoryId: 'category-1',
  title: 'Leaking kitchen tap',
  description: 'The kitchen tap is leaking continuously.',
  priority: MaintenancePriority.medium,
  status: MaintenanceRequestStatus.assigned,
  createdAt: DateTime.utc(2026, 9),
  updatedAt: DateTime.utc(2026, 9),
  resident: requestResident,
  apartment: requestApartment,
  category: requestCategory,
  activeAssignment: maintenanceAssignment,
);

MaintenanceRequest get inProgressMaintenanceRequest => MaintenanceRequest(
  id: 'request-1',
  residentId: 'resident-1',
  apartmentId: 'apartment-1',
  categoryId: 'category-1',
  title: 'Leaking kitchen tap',
  description: 'The kitchen tap is leaking continuously.',
  priority: MaintenancePriority.medium,
  status: MaintenanceRequestStatus.inProgress,
  createdAt: DateTime.utc(2026, 9),
  updatedAt: DateTime.utc(2026, 9),
  resident: requestResident,
  apartment: requestApartment,
  category: requestCategory,
  activeAssignment: maintenanceAssignment,
);

Map<String, dynamic> get maintenanceAssignmentJson => {
  'id': 'assignment-1',
  'maintenanceRequestId': 'request-1',
  'technicianId': 'technician-1',
  'assignedByUserId': 'admin-1',
  'assignedAt': '2026-09-02T10:30:00.000Z',
  'unassignedAt': null,
  'isActive': true,
  'createdAt': '2026-09-02T10:30:00.000Z',
  'updatedAt': '2026-09-02T10:30:00.000Z',
  'technician': technicianJson,
  'assignedBy': {
    'id': 'admin-1',
    'name': 'Admin User',
    'email': 'admin@example.com',
    'role': 'ADMIN',
    'isActive': true,
  },
};

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
  'assignments': <dynamic>[],
};

final maintenanceComment = MaintenanceComment(
  id: 'comment-1',
  maintenanceRequestId: 'request-1',
  userId: requestUser.id,
  message: 'The leak is getting worse.',
  createdAt: DateTime.utc(2026, 9, 2, 10, 30),
  updatedAt: DateTime.utc(2026, 9, 2, 10, 30),
  author: const MaintenanceActor(
    id: 'user-1',
    name: 'Riya Resident',
    role: UserRole.resident,
  ),
);

final maintenanceHistoryEntry = MaintenanceHistoryEntry(
  id: 'history-1',
  maintenanceRequestId: 'request-1',
  userId: adminUser.id,
  action: MaintenanceHistoryAction.statusChanged,
  oldValue: 'ASSIGNED',
  newValue: 'IN_PROGRESS',
  createdAt: DateTime.utc(2026, 9, 2, 11),
  actor: const MaintenanceActor(
    id: 'admin-1',
    name: 'Admin User',
    role: UserRole.admin,
  ),
);

Map<String, dynamic> get maintenanceCommentJson => {
  'id': 'comment-1',
  'maintenanceRequestId': 'request-1',
  'userId': 'user-1',
  'message': 'The leak is getting worse.',
  'createdAt': '2026-09-02T10:30:00.000Z',
  'updatedAt': '2026-09-02T10:30:00.000Z',
  'user': {'id': 'user-1', 'name': 'Riya Resident', 'role': 'RESIDENT'},
};

Map<String, dynamic> get maintenanceHistoryJson => {
  'id': 'history-1',
  'maintenanceRequestId': 'request-1',
  'userId': 'admin-1',
  'action': 'STATUS_CHANGED',
  'oldValue': 'ASSIGNED',
  'newValue': 'IN_PROGRESS',
  'metadata': null,
  'createdAt': '2026-09-02T11:00:00.000Z',
  'user': {'id': 'admin-1', 'name': 'Admin User', 'role': 'ADMIN'},
};
