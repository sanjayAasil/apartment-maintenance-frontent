import 'package:apartment_maintenance_frontent/app/di/injection.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/create_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/get_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/domain/usecases/update_maintenance_category_status.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/bloc/maintenance_category_form_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_categories/presentation/pages/maintenance_category_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCategory extends Mock implements GetMaintenanceCategory {}

class MockCreateCategory extends Mock implements CreateMaintenanceCategory {}

class MockUpdateCategory extends Mock implements UpdateMaintenanceCategory {}

class MockUpdateCategoryStatus extends Mock
    implements UpdateMaintenanceCategoryStatus {}

void main() {
  tearDown(() async => getIt.reset());

  testWidgets('validates a required category name', (tester) async {
    getIt.registerFactory<MaintenanceCategoryFormCubit>(
      () => MaintenanceCategoryFormCubit(
        MockGetCategory(),
        MockCreateCategory(),
        MockUpdateCategory(),
        MockUpdateCategoryStatus(),
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MaintenanceCategoryFormPage())),
    );
    await tester.tap(find.byKey(const Key('saveCategoryButton')));
    await tester.pump();
    expect(find.text('Category name is required.'), findsOneWidget);
  });
}
