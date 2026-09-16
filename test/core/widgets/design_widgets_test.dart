import 'package:apartment_maintenance_frontent/app/theme/app_theme.dart';
import 'package:apartment_maintenance_frontent/core/widgets/design_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('status, priority and stock remain explicit text labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Wrap(
            children: [
              StatusChip('Open'),
              StatusChip('Assigned'),
              StatusChip('In Progress'),
              StatusChip('Resolved'),
              StatusChip('Cancelled'),
              PriorityChip('Urgent'),
              StockChip(quantity: 0, minimumStock: 5),
              StockChip(quantity: 3, minimumStock: 5),
              StockChip(quantity: 10, minimumStock: 5),
            ],
          ),
        ),
      ),
    );
    for (final label in [
      'Open',
      'Assigned',
      'In Progress',
      'Resolved',
      'Cancelled',
      'Urgent',
      'Out of stock',
      'Low stock',
      'In stock',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
  for (final width in [320.0, 768.0, 1440.0]) {
    testWidgets('page header adapts at $width without dropping action', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: SectionHeader(
                title: 'Maintenance Categories',
                subtitle: 'Organize the types of maintenance service.',
                action: FilledButton(
                  onPressed: () => tapped = true,
                  child: const Text('Add category'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Add category'));
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
