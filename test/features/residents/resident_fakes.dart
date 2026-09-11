import 'package:apartment_maintenance_frontent/features/apartments/data/models/apartment_model.dart';
import 'package:apartment_maintenance_frontent/features/apartments/domain/entities/apartment.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/residents/data/models/resident_model.dart';
import 'package:apartment_maintenance_frontent/features/residents/domain/entities/resident.dart';
import 'package:apartment_maintenance_frontent/features/users/data/models/user_model.dart';

const residentUser = AppUser(
  id: 'user-1',
  name: 'Ravi Resident',
  email: 'ravi@example.com',
  role: UserRole.resident,
  isActive: true,
);

const residentApartment = Apartment(
  id: 'apartment-1',
  block: 'A',
  floor: 2,
  unitNumber: '204',
);

final resident = Resident(
  id: 'resident-1',
  userId: residentUser.id,
  apartmentId: residentApartment.id,
  phone: '9876543210',
  moveInDate: DateTime.utc(2026, 9),
  isActive: true,
  user: residentUser,
  apartment: residentApartment,
);

final residentModel = ResidentModel(
  id: 'resident-1',
  userId: 'user-1',
  apartmentId: 'apartment-1',
  phone: '9876543210',
  moveInDate: DateTime.utc(2026, 9),
  isActive: true,
  user: const UserModel(
    id: 'user-1',
    name: 'Ravi Resident',
    email: 'ravi@example.com',
    role: 'RESIDENT',
    isActive: true,
  ),
  apartment: const ApartmentModel(
    id: 'apartment-1',
    block: 'A',
    floor: 2,
    unitNumber: '204',
  ),
);

Map<String, dynamic> get residentJson => {
  'id': 'resident-1',
  'userId': 'user-1',
  'apartmentId': 'apartment-1',
  'phone': '9876543210',
  'moveInDate': '2026-09-01T00:00:00.000Z',
  'isActive': true,
  'createdAt': '2026-09-01T00:00:00.000Z',
  'updatedAt': '2026-09-01T00:00:00.000Z',
  'user': {
    'id': 'user-1',
    'name': 'Ravi Resident',
    'email': 'ravi@example.com',
    'role': 'RESIDENT',
    'isActive': true,
    'createdAt': '2026-09-01T00:00:00.000Z',
    'updatedAt': '2026-09-01T00:00:00.000Z',
  },
  'apartment': {
    'id': 'apartment-1',
    'block': 'A',
    'floor': 2,
    'unitNumber': '204',
    'createdAt': '2026-09-01T00:00:00.000Z',
    'updatedAt': '2026-09-01T00:00:00.000Z',
  },
};
