import 'package:apartment_maintenance_frontent/core/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders loading, empty, and error states', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoadingView(label: 'Loading users')),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(home: EmptyView(message: 'No users')),
    );
    expect(find.text('No users'), findsOneWidget);

    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ErrorView(message: 'Failed', onRetry: () => retried = true),
      ),
    );
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
