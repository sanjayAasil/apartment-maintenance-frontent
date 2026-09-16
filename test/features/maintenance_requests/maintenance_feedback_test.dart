import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/auth/domain/entities/app_user.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/data/models/maintenance_feedback_model.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_feedback.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/maintenance_feedback_usecases.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_feedback_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/widgets/maintenance_feedback_section.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';

class MockGetFeedback extends Mock implements GetMaintenanceFeedback {}

class MockSubmitFeedback extends Mock implements SubmitMaintenanceFeedback {}

final feedback = MaintenanceFeedback(
  id: 'feedback-1',
  maintenanceRequestId: 'request-1',
  residentId: 'resident-1',
  rating: 5,
  comment: 'Issue fixed properly.',
  createdAt: _feedbackDate,
  updatedAt: _feedbackDate,
  resident: MaintenanceFeedbackResident(
    id: 'resident-1',
    name: 'Resident User',
  ),
);
final _feedbackDate = DateTime.utc(2026, 9, 10);

void main() {
  late MockGetFeedback getFeedback;
  late MockSubmitFeedback submitFeedback;

  setUp(() {
    getFeedback = MockGetFeedback();
    submitFeedback = MockSubmitFeedback();
  });

  test('parses feedback with public resident display information', () {
    final model = MaintenanceFeedbackModel.fromJson({
      'id': 'feedback-1',
      'maintenanceRequestId': 'request-1',
      'residentId': 'resident-1',
      'rating': 5,
      'comment': 'Issue fixed properly.',
      'createdAt': '2026-09-10T00:00:00.000Z',
      'updatedAt': '2026-09-10T00:00:00.000Z',
      'resident': {
        'id': 'resident-1',
        'user': {'id': 'user-1', 'name': 'Resident User'},
      },
    });
    expect(model.toEntity(), feedback);
  });

  blocTest<MaintenanceFeedbackCubit, MaintenanceFeedbackState>(
    'loads the no-feedback state',
    build: () {
      when(() => getFeedback('request-1')).thenAnswer((_) async => null);
      return MaintenanceFeedbackCubit(getFeedback, submitFeedback);
    },
    act: (cubit) => cubit.load('request-1'),
    verify: (cubit) =>
        expect(cubit.state.status, MaintenanceFeedbackStatus.noFeedback),
  );

  blocTest<MaintenanceFeedbackCubit, MaintenanceFeedbackState>(
    'submits feedback and exposes failures',
    build: () {
      when(
        () => submitFeedback('request-1', 5, 'Excellent'),
      ).thenAnswer((_) async => feedback);
      when(() => submitFeedback('request-2', 4, null)).thenThrow(
        const Failure(kind: FailureKind.conflict, message: 'Already submitted'),
      );
      return MaintenanceFeedbackCubit(getFeedback, submitFeedback);
    },
    act: (cubit) async {
      expect(await cubit.submit('request-1', 0, null), isFalse);
      expect(await cubit.submit('request-1', 5, 'Excellent'), isTrue);
      expect(await cubit.submit('request-2', 4, null), isFalse);
    },
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceFeedbackStatus.failure);
      expect(cubit.state.failure?.kind, FailureKind.conflict);
    },
  );

  testWidgets('resident can rate and submit when feedback is missing', (
    tester,
  ) async {
    when(() => getFeedback('request-1')).thenAnswer((_) async => null);
    when(
      () => submitFeedback('request-1', 5, 'Excellent repair'),
    ).thenAnswer((_) async => feedback);
    await tester.pumpWidget(
      _app(residentUser, MaintenanceFeedbackCubit(getFeedback, submitFeedback)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rate Maintenance Service'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.star_border).last);
    await tester.enterText(
      find.widgetWithText(TextField, 'Comment (optional)'),
      'Excellent repair',
    );
    await tester.tap(find.text('Submit feedback'));
    await tester.pumpAndSettle();
    expect(find.text('Issue fixed properly.'), findsOneWidget);
    verify(() => submitFeedback('request-1', 5, 'Excellent repair')).called(1);
  });

  testWidgets('admin and technician see existing feedback read-only', (
    tester,
  ) async {
    when(() => getFeedback('request-1')).thenAnswer((_) async => feedback);
    await tester.pumpWidget(
      _app(adminUser, MaintenanceFeedbackCubit(getFeedback, submitFeedback)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Resident feedback'), findsOneWidget);
    expect(find.text('Issue fixed properly.'), findsOneWidget);
    expect(find.text('Submit feedback'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _app(
        adminUser.copyWith(role: UserRole.technician),
        MaintenanceFeedbackCubit(getFeedback, submitFeedback),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Issue fixed properly.'), findsOneWidget);
    expect(find.text('Submit feedback'), findsNothing);
  });
}

Widget _app(AppUser user, MaintenanceFeedbackCubit cubit) => MaterialApp(
  home: Scaffold(
    body: BlocProvider.value(
      value: cubit,
      child: MaintenanceFeedbackSection(requestId: 'request-1', user: user),
    ),
  ),
);
