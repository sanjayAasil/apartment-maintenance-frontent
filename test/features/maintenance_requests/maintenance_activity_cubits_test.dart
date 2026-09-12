import 'package:apartment_maintenance_frontent/core/error/failure.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/add_maintenance_comment.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_comments.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/domain/usecases/get_maintenance_history.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_comments_cubit.dart';
import 'package:apartment_maintenance_frontent/features/maintenance_requests/presentation/bloc/maintenance_history_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'maintenance_request_fakes.dart';

class MockGetComments extends Mock implements GetMaintenanceComments {}

class MockAddComment extends Mock implements AddMaintenanceComment {}

class MockGetHistory extends Mock implements GetMaintenanceHistory {}

void main() {
  late MockGetComments getComments;
  late MockAddComment addComment;
  late MockGetHistory getHistory;

  setUp(() {
    getComments = MockGetComments();
    addComment = MockAddComment();
    getHistory = MockGetHistory();
  });

  blocTest<MaintenanceCommentsCubit, MaintenanceCommentsState>(
    'loads comments successfully',
    build: () {
      when(
        () => getComments('request-1'),
      ).thenAnswer((_) async => [maintenanceComment]);
      return MaintenanceCommentsCubit(getComments, addComment);
    },
    act: (cubit) => cubit.load('request-1'),
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceCommentsStatus.loaded);
      expect(cubit.state.comments, [maintenanceComment]);
    },
  );

  blocTest<MaintenanceCommentsCubit, MaintenanceCommentsState>(
    'supports empty and failure comment results',
    build: () {
      when(() => getComments('request-1')).thenAnswer((_) async => const []);
      when(() => getComments('request-2')).thenThrow(
        const Failure(kind: FailureKind.forbidden, message: 'No access'),
      );
      return MaintenanceCommentsCubit(getComments, addComment);
    },
    act: (cubit) async {
      await cubit.load('request-1');
      await cubit.load('request-2');
    },
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceCommentsStatus.failure);
      expect(cubit.state.failure?.kind, FailureKind.forbidden);
    },
  );

  blocTest<MaintenanceCommentsCubit, MaintenanceCommentsState>(
    'validates and appends a submitted comment',
    build: () {
      when(
        () => addComment('request-1', 'Update'),
      ).thenAnswer((_) async => maintenanceComment);
      return MaintenanceCommentsCubit(getComments, addComment);
    },
    act: (cubit) async {
      expect(await cubit.add('request-1', '   '), isFalse);
      expect(await cubit.add('request-1', ' Update '), isTrue);
    },
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceCommentsStatus.submitSuccess);
      expect(cubit.state.comments, [maintenanceComment]);
    },
  );

  blocTest<MaintenanceCommentsCubit, MaintenanceCommentsState>(
    'preserves comments when submission fails',
    seed: () => MaintenanceCommentsState(
      status: MaintenanceCommentsStatus.loaded,
      comments: [maintenanceComment],
    ),
    build: () {
      when(() => addComment('request-1', 'Update')).thenThrow(
        const Failure(kind: FailureKind.server, message: 'Send failed'),
      );
      return MaintenanceCommentsCubit(getComments, addComment);
    },
    act: (cubit) => cubit.add('request-1', 'Update'),
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceCommentsStatus.failure);
      expect(cubit.state.comments, [maintenanceComment]);
    },
  );

  blocTest<MaintenanceHistoryCubit, MaintenanceHistoryState>(
    'loads chronological history',
    build: () {
      when(
        () => getHistory('request-1'),
      ).thenAnswer((_) async => [maintenanceHistoryEntry]);
      return MaintenanceHistoryCubit(getHistory);
    },
    act: (cubit) => cubit.load('request-1'),
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceHistoryStatus.loaded);
      expect(cubit.state.entries, [maintenanceHistoryEntry]);
    },
  );

  blocTest<MaintenanceHistoryCubit, MaintenanceHistoryState>(
    'maps history failures',
    build: () {
      when(() => getHistory('request-1')).thenThrow(
        const Failure(kind: FailureKind.server, message: 'History failed'),
      );
      return MaintenanceHistoryCubit(getHistory);
    },
    act: (cubit) => cubit.load('request-1'),
    verify: (cubit) {
      expect(cubit.state.status, MaintenanceHistoryStatus.failure);
      expect(cubit.state.failure?.message, 'History failed');
    },
  );
}
