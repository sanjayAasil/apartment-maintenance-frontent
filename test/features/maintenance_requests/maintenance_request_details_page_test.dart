import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/assign_technician.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/create_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_assignment_history.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/reassign_technician.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/unassign_technician.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request_status.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_assignment_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_details_bloc.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_form_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/pages/maintenance_request_details_page.dart';
import 'package:apartment_maintenance_frontent/features/technicians/domain/usecases/get_available_technicians.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';
import '../technicians/technician_fakes.dart';
import 'maintenance_request_fakes.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockGetRequest extends Mock implements GetMaintenanceRequest {}

class MockGetCategories extends Mock implements GetMaintenanceCategories {}

class MockCreateRequest extends Mock implements CreateMaintenanceRequest {}

class MockUpdateRequest extends Mock implements UpdateMaintenanceRequest {}

class MockUpdateRequestStatus extends Mock
    implements UpdateMaintenanceRequestStatus {}

class MockGetAvailable extends Mock implements GetAvailableTechnicians {}

class MockGetHistory extends Mock implements GetAssignmentHistory {}

class MockAssign extends Mock implements AssignTechnician {}

class MockReassign extends Mock implements ReassignTechnician {}

class MockUnassign extends Mock implements UnassignTechnician {}

void main() {
  Widget app(AppUser user, MaintenanceRequest request) {
    final auth = MockAuthBloc();
    when(
      () => auth.state,
    ).thenReturn(AuthState(status: AuthStatus.authenticated, user: user));
    when(() => auth.stream).thenAnswer((_) => const Stream.empty());
    final getRequest = MockGetRequest();
    when(() => getRequest('request-1')).thenAnswer((_) async => request);
    final getAvailable = MockGetAvailable();
    final getHistory = MockGetHistory();
    when(
      () => getAvailable('category-1'),
    ).thenAnswer((_) async => [technician]);
    when(() => getHistory('request-1')).thenAnswer(
      (_) async =>
          request.activeAssignment == null ? [] : [maintenanceAssignment],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: auth),
        BlocProvider(
          create: (_) =>
              MaintenanceRequestDetailsBloc(getRequest)
                ..add(const MaintenanceRequestDetailsRequested('request-1')),
        ),
        BlocProvider(
          create: (_) => MaintenanceRequestFormCubit(
            MockGetRequest(),
            MockGetCategories(),
            MockCreateRequest(),
            MockUpdateRequest(),
            MockUpdateRequestStatus(),
          ),
        ),
        BlocProvider(
          create: (_) => MaintenanceAssignmentCubit(
            getAvailable,
            getHistory,
            MockAssign(),
            MockReassign(),
            MockUnassign(),
          ),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: MaintenanceRequestDetailsView(requestId: 'request-1'),
        ),
      ),
    );
  }

  testWidgets('shows assignment controls only to admins', (tester) async {
    await tester.pumpWidget(app(adminUser, maintenanceRequest));
    await tester.pumpAndSettle();
    expect(find.text('Assign technician'), findsOneWidget);

    await tester.pumpWidget(app(residentUser, maintenanceRequest));
    await tester.pumpAndSettle();
    expect(find.text('Assign technician'), findsNothing);
    expect(find.text('No technician is currently assigned.'), findsOneWidget);
  });

  testWidgets('shows semantic start action to assigned technician', (
    tester,
  ) async {
    await tester.pumpWidget(app(technicianUser, assignedMaintenanceRequest));
    await tester.pumpAndSettle();
    expect(find.text('Tara Technician'), findsOneWidget);
    expect(find.text('Start work'), findsOneWidget);
    expect(find.text('Reassign'), findsNothing);
  });

  testWidgets('shows reassignment and assignment history to admins', (
    tester,
  ) async {
    await tester.pumpWidget(app(adminUser, assignedMaintenanceRequest));
    await tester.pumpAndSettle();
    expect(find.text('Reassign'), findsOneWidget);
    expect(find.text('Unassign'), findsOneWidget);
    expect(find.text('Assignment history'), findsOneWidget);
    expect(find.textContaining('Current'), findsOneWidget);
  });
}
