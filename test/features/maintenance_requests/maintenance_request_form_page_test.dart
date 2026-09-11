import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/maintenance_category_query.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/entities/paged_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_categories.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/create_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/update_maintenance_request_status.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_request_form_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/pages/maintenance_request_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetRequest extends Mock implements GetMaintenanceRequest {}

class MockGetCategories extends Mock implements GetMaintenanceCategories {}

class MockCreateRequest extends Mock implements CreateMaintenanceRequest {}

class MockUpdateRequest extends Mock implements UpdateMaintenanceRequest {}

class MockUpdateRequestStatus extends Mock
    implements UpdateMaintenanceRequestStatus {}

void main() {
  setUpAll(() => registerFallbackValue(const MaintenanceCategoryQuery()));
  tearDown(() async => getIt.reset());

  testWidgets('validates required request form fields', (tester) async {
    final getCategories = MockGetCategories();
    when(() => getCategories(any())).thenAnswer(
      (_) async => const PagedMaintenanceCategories(
        items: [],
        total: 0,
        page: 1,
        pageSize: 100,
      ),
    );
    getIt.registerFactory<MaintenanceRequestFormCubit>(
      () => MaintenanceRequestFormCubit(
        MockGetRequest(),
        getCategories,
        MockCreateRequest(),
        MockUpdateRequest(),
        MockUpdateRequestStatus(),
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MaintenanceRequestFormPage())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save request'));
    await tester.pump();
    expect(find.text('Select a category'), findsOneWidget);
    expect(find.text('Enter at least 3 characters'), findsOneWidget);
    expect(find.text('Enter at least 10 characters'), findsOneWidget);
  });
}
