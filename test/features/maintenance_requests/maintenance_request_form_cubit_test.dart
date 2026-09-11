import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/create_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request_status.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_form_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_request_fakes.dart';

class MockGetRequest extends Mock implements GetMaintenanceRequest {}

class MockGetCategories extends Mock implements GetMaintenanceCategories {}

class MockCreateRequest extends Mock implements CreateMaintenanceRequest {}

class MockUpdateRequest extends Mock implements UpdateMaintenanceRequest {}

class MockUpdateRequestStatus extends Mock
    implements UpdateMaintenanceRequestStatus {}

void main() {
  late MockGetRequest getRequest;
  late MockGetCategories getCategories;
  late MockCreateRequest createRequest;
  late MockUpdateRequest updateRequest;
  late MockUpdateRequestStatus updateStatus;
  late MaintenanceRequestFormCubit cubit;

  setUp(() {
    getRequest = MockGetRequest();
    getCategories = MockGetCategories();
    createRequest = MockCreateRequest();
    updateRequest = MockUpdateRequest();
    updateStatus = MockUpdateRequestStatus();
    cubit = MaintenanceRequestFormCubit(
      getRequest,
      getCategories,
      createRequest,
      updateRequest,
      updateStatus,
    );
  });
  tearDown(() => cubit.close());

  blocTest<MaintenanceRequestFormCubit, MaintenanceRequestFormState>(
    'creates a request successfully',
    build: () {
      when(
        () => createRequest(
          'category-1',
          'Leak',
          'A sufficiently long description',
          MaintenancePriority.medium,
        ),
      ).thenAnswer((_) async => maintenanceRequest);
      return cubit;
    },
    act: (cubit) => cubit.create(
      'category-1',
      'Leak',
      'A sufficiently long description',
      MaintenancePriority.medium,
    ),
    expect: () => [
      const MaintenanceRequestFormState(
        status: MaintenanceRequestFormStatus.submitting,
      ),
      MaintenanceRequestFormState(
        status: MaintenanceRequestFormStatus.success,
        request: maintenanceRequest,
      ),
    ],
  );

  blocTest<MaintenanceRequestFormCubit, MaintenanceRequestFormState>(
    'updates status and maps failures',
    build: () {
      when(
        () => updateStatus('request-1', MaintenanceRequestStatus.cancelled),
      ).thenThrow(
        const Failure(
          kind: FailureKind.validation,
          message: 'Invalid transition',
        ),
      );
      return cubit;
    },
    act: (cubit) =>
        cubit.updateStatus('request-1', MaintenanceRequestStatus.cancelled),
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceRequestFormStatus.failure);
      expect(cubit.state.failure?.message, 'Invalid transition');
    },
  );
}
