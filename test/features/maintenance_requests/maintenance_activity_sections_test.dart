import 'dart:async';

import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/entities/maintenance_history_entry.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/add_maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_comments.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_history.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_comments_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_history_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/widgets/maintenance_activity_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_request_fakes.dart';

class MockGetComments extends Mock implements GetMaintenanceComments {}

class MockAddComment extends Mock implements AddMaintenanceComment {}

class MockGetHistory extends Mock implements GetMaintenanceHistory {}

void main() {
  Widget app(
    GetMaintenanceComments getComments,
    AddMaintenanceComment addComment,
    GetMaintenanceHistory getHistory,
  ) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => MaintenanceCommentsCubit(getComments, addComment),
      ),
      BlocProvider(create: (_) => MaintenanceHistoryCubit(getHistory)),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MaintenanceActivitySections(requestId: 'request-1'),
        ),
      ),
    ),
  );

  testWidgets('shows comments and history loading states', (tester) async {
    final getComments = MockGetComments();
    final addComment = MockAddComment();
    final getHistory = MockGetHistory();
    when(
      () => getComments('request-1'),
    ).thenAnswer((_) => Completer<List<MaintenanceComment>>().future);
    when(
      () => getHistory('request-1'),
    ).thenAnswer((_) => Completer<List<MaintenanceHistoryEntry>>().future);
    await tester.pumpWidget(app(getComments, addComment, getHistory));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
  });

  testWidgets('renders activity and sends a validated comment', (tester) async {
    final getComments = MockGetComments();
    final addComment = MockAddComment();
    final getHistory = MockGetHistory();
    when(
      () => getComments('request-1'),
    ).thenAnswer((_) async => [maintenanceComment]);
    when(
      () => getHistory('request-1'),
    ).thenAnswer((_) async => [maintenanceHistoryEntry]);
    when(
      () => addComment('request-1', 'Replacement approved.'),
    ).thenAnswer((_) async => maintenanceComment);
    await tester.pumpWidget(app(getComments, addComment, getHistory));
    await tester.pumpAndSettle();
    expect(find.text('The leak is getting worse.'), findsOneWidget);
    expect(
      find.text('Status changed from Assigned to In Progress'),
      findsOneWidget,
    );

    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.text('Enter a comment before sending.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Add a comment'),
      'Replacement approved.',
    );
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    verify(() => addComment('request-1', 'Replacement approved.')).called(1);
  });

  testWidgets('renders empty comments and history', (tester) async {
    final getComments = MockGetComments();
    final addComment = MockAddComment();
    final getHistory = MockGetHistory();
    when(() => getComments('request-1')).thenAnswer((_) async => const []);
    when(() => getHistory('request-1')).thenAnswer((_) async => const []);
    await tester.pumpWidget(app(getComments, addComment, getHistory));
    await tester.pumpAndSettle();
    expect(find.text('No comments yet.'), findsOneWidget);
    expect(find.text('No history recorded yet.'), findsOneWidget);
  });

  testWidgets('renders comments and history failures', (tester) async {
    final getComments = MockGetComments();
    final addComment = MockAddComment();
    final getHistory = MockGetHistory();
    when(() => getComments('request-1')).thenThrow(
      const Failure(kind: FailureKind.server, message: 'Comments failed'),
    );
    when(() => getHistory('request-1')).thenThrow(
      const Failure(kind: FailureKind.server, message: 'History failed'),
    );
    await tester.pumpWidget(app(getComments, addComment, getHistory));
    await tester.pumpAndSettle();
    expect(find.text('Comments failed'), findsOneWidget);
    expect(find.text('History failed'), findsOneWidget);
  });
}
